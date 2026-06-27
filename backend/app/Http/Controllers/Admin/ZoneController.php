<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Zone;
use App\Models\ZoneTariff;
use App\Models\VehicleType;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Inertia\Inertia;

class ZoneController extends Controller
{
    use HasAdvancedFilter;

    private function handleQrisImage(Request $request, string $prefix = 'zone-'): ?string
    {
        if (! $request->hasFile('qris_image')) {
            return null;
        }

        $path = $request->file('qris_image')->store("parkirgo/qris/{$prefix}", 'public');
        $fullPath = Storage::disk('public')->path($path);

        if (class_exists(\Zxing\QrReader::class)) {
            try {
                $reader = new \Zxing\QrReader($fullPath);
                $decoded = $reader->text();
                if ($decoded) {
                    session()->flash('qris_payload', $decoded);
                }
            } catch (\Exception $e) {
                report($e);
            }
        }

        return $path;
    }

    public function index(Request $request)
    {
        $zones = $this->applySort(
            $this->applySearch(Zone::with(['tariffs.vehicleTypeMaster', 'vehicleTypes'])->withCount('jukirs'), $request, ['code', 'name', 'city']),
            $request,
            ['created_at', 'code', 'name', 'city', 'status']
        )->paginate($this->perPage($request));

        $tariffs = ZoneTariff::with(['zone', 'vehicleTypeMaster'])->latest()->get();
        $vehicleTypes = VehicleType::where('status', VehicleType::STATUS_ACTIVE)
            ->orderBy('sort_order')
            ->orderBy('name')
            ->get();

        return Inertia::render('parkirgo/Zones', [
            'zones' => $zones,
            'tariffs' => $tariffs,
            'vehicleTypes' => $vehicleTypes,
        ]);
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'code' => ['required', 'string', 'max:20', 'unique:zones,code'],
            'name' => ['required', 'string', 'max:100'],
            'city' => ['nullable', 'string', 'max:100'],
            'center_lat' => ['nullable', 'numeric', 'min:-90', 'max:90'],
            'center_lng' => ['nullable', 'numeric', 'min:-180', 'max:180'],
            'radius_meters' => ['nullable', 'integer', 'min:50', 'max:5000'],
            'qris_payload' => ['nullable', 'string'],
            'qris_image' => ['nullable', 'image', 'max:1024'],
            'status' => ['nullable', 'in:active,inactive'],
            'capacities' => ['nullable', 'array'],
            'capacities.*.vehicle_type_id' => ['required', 'exists:vehicle_types,id'],
            'capacities.*.capacity' => ['required', 'integer', 'min:0'],
        ]);

        $payload = array_merge($data, ['status' => $data['status'] ?? 'active']);
        unset($payload['qris_image'], $payload['capacities']);

        $payload['qris_image_path'] = $this->handleQrisImage($request, 'zone-');
        if ($request->hasFile('qris_image') && ! $payload['qris_payload']) {
            $payload['qris_payload'] = session()->pull('qris_payload', '');
        }

        $zone = Zone::create($payload);

        $this->syncCapacities($zone, $data['capacities'] ?? []);

        return back()->with('success', 'Zona berhasil ditambahkan.');
    }

    public function update(Request $request, Zone $zone)
    {
        $data = $request->validate([
            'code' => ['required', 'string', 'max:20', 'unique:zones,code,' . $zone->id],
            'name' => ['required', 'string', 'max:100'],
            'city' => ['nullable', 'string', 'max:100'],
            'center_lat' => ['nullable', 'numeric', 'min:-90', 'max:90'],
            'center_lng' => ['nullable', 'numeric', 'min:-180', 'max:180'],
            'radius_meters' => ['nullable', 'integer', 'min:50', 'max:5000'],
            'qris_payload' => ['nullable', 'string'],
            'qris_image' => ['nullable', 'image', 'max:1024'],
            'status' => ['required', 'in:active,inactive'],
            'capacities' => ['nullable', 'array'],
            'capacities.*.vehicle_type_id' => ['required', 'exists:vehicle_types,id'],
            'capacities.*.capacity' => ['required', 'integer', 'min:0'],
        ]);

        $payload = $data;
        unset($payload['qris_image'], $payload['capacities']);

        if ($request->hasFile('qris_image')) {
            if ($zone->qris_image_path) {
                Storage::disk('public')->delete($zone->qris_image_path);
            }
            $payload['qris_image_path'] = $this->handleQrisImage($request, "zone-{$zone->id}-");
            if (! $payload['qris_payload']) {
                $payload['qris_payload'] = session()->pull('qris_payload', '');
            }
        }

        $zone->update($payload);

        $this->syncCapacities($zone, $data['capacities'] ?? []);

        return back()->with('success', 'Zona berhasil diperbarui.');
    }

    private function syncCapacities(Zone $zone, array $capacities): void
    {
        $pivot = [];
        foreach ($capacities as $cap) {
            if (($cap['capacity'] ?? 0) > 0) {
                $pivot[$cap['vehicle_type_id']] = ['capacity' => $cap['capacity']];
            }
        }
        $zone->vehicleTypes()->sync($pivot);
    }

    public function show(Zone $zone)
    {
        $zone->load([
            'tariffs.vehicleTypeMaster',
            'vehicleTypes',
            'jukirs',
        ]);

        $zone->loadCount([
            'jukirs',
            'parkingSessions',
            'transactions',
        ]);

        return Inertia::render('parkirgo/ZoneDetail', [
            'zone' => $zone,
        ]);
    }

    public function decodeQris(Request $request)
    {
        $request->validate([
            'qris_image' => ['required', 'image', 'max:2048'],
        ]);

        if (! $request->hasFile('qris_image')) {
            return response()->json(['error' => 'No image file uploaded'], 400);
        }

        $tempPath = $request->file('qris_image')->store('temp', 'public');
        $fullPath = Storage::disk('public')->path($tempPath);

        $decoded = null;
        if (class_exists(\Zxing\QrReader::class)) {
            try {
                $reader = new \Zxing\QrReader($fullPath);
                $decoded = $reader->text();
            } catch (\Exception $e) {
                report($e);
            }
        }

        // Clean up temp file
        Storage::disk('public')->delete($tempPath);

        return response()->json([
            'success' => (bool)$decoded,
            'payload' => $decoded ?? '',
        ]);
    }

    public function destroy(Zone $zone)
    {
        if ($zone->parkingSessions()->exists() || $zone->jukirs()->exists()) {
            return back()->with('error', 'Zona tidak bisa dihapus karena masih memiliki data parkir atau jukir.');
        }

        $zone->delete();

        return back()->with('success', 'Zona berhasil dihapus.');
    }
}
