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
        $zones = Zone::with(['tariffs.vehicleTypeMaster'])
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
            'capacity_motor' => ['nullable', 'integer', 'min:0'],
            'capacity_car' => ['nullable', 'integer', 'min:0'],
            'qris_payload' => ['nullable', 'string'],
            'status' => ['nullable', 'in:active,inactive'],
        ]);

        Zone::create(array_merge($data, ['status' => $data['status'] ?? 'active']));

        return back()->with('success', 'Zona berhasil ditambahkan.');
    }

    public function update(Request $request, Zone $zone)
    {
        $data = $request->validate([
            'code' => ['required', 'string', 'max:20', 'unique:zones,code,' . $zone->id],
            'name' => ['required', 'string', 'max:100'],
            'city' => ['nullable', 'string', 'max:100'],
            'capacity_motor' => ['nullable', 'integer', 'min:0'],
            'capacity_car' => ['nullable', 'integer', 'min:0'],
            'qris_payload' => ['nullable', 'string'],
            'status' => ['required', 'in:active,inactive'],
        ]);

        $zone->update($data);

        return back()->with('success', 'Zona berhasil diperbarui.');
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
