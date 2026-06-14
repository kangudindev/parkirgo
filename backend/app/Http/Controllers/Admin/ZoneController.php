<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Zone;
use App\Models\ZoneTariff;
use App\Models\VehicleType;
use Illuminate\Http\Request;
use Inertia\Inertia;

class ZoneController extends Controller
{
    public function index()
    {
        $zones = Zone::with(['tariffs.vehicleTypeMaster', 'vehicleTypes'])
            ->withCount('jukirs')
            ->latest()
            ->get();

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
            'qris_payload' => ['nullable', 'string'],
            'status' => ['nullable', 'in:active,inactive'],
            'capacities' => ['nullable', 'array'],
            'capacities.*.vehicle_type_id' => ['required', 'exists:vehicle_types,id'],
            'capacities.*.capacity' => ['required', 'integer', 'min:0'],
        ]);

        $zone = Zone::create(array_merge($data, ['status' => $data['status'] ?? 'active']));

        $this->syncCapacities($zone, $data['capacities'] ?? []);

        return back()->with('success', 'Zona berhasil ditambahkan.');
    }

    public function update(Request $request, Zone $zone)
    {
        $data = $request->validate([
            'code' => ['required', 'string', 'max:20', 'unique:zones,code,' . $zone->id],
            'name' => ['required', 'string', 'max:100'],
            'city' => ['nullable', 'string', 'max:100'],
            'qris_payload' => ['nullable', 'string'],
            'status' => ['required', 'in:active,inactive'],
            'capacities' => ['nullable', 'array'],
            'capacities.*.vehicle_type_id' => ['required', 'exists:vehicle_types,id'],
            'capacities.*.capacity' => ['required', 'integer', 'min:0'],
        ]);

        $zone->update($data);

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

    public function destroy(Zone $zone)
    {
        if ($zone->parkingSessions()->exists() || $zone->jukirs()->exists()) {
            return back()->with('error', 'Zona tidak bisa dihapus karena masih memiliki data parkir atau jukir.');
        }

        $zone->delete();

        return back()->with('success', 'Zona berhasil dihapus.');
    }
}
