<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Zone;
use App\Models\ZoneTariff;
use App\Models\VehicleType;
use Illuminate\Http\Request;

class TariffController extends Controller
{
    public function index(Request $request)
    {
        $query = ZoneTariff::with(['zone', 'vehicleTypeMaster']);

        if ($request->filled('zone_id')) {
            $query->where('zone_id', $request->zone_id);
        }

        $tariffs = $query->latest()->get();
        $zones = Zone::where('status', 'active')->get(['id', 'name', 'code']);
        $vehicleTypes = VehicleType::where('status', VehicleType::STATUS_ACTIVE)
            ->orderBy('sort_order')
            ->get(['id', 'code', 'name']);

        return inertia('parkirgo/Zones', [
            'zones' => Zone::with(['tariffs.vehicleTypeMaster'])->withCount('jukirs')->latest()->get(),
            'tariffs' => ZoneTariff::with(['zone', 'vehicleTypeMaster'])->latest()->get(),
            'vehicleTypes' => $vehicleTypes,
            'tariffZones' => $zones,
        ]);
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'zone_id' => ['required', 'exists:zones,id'],
            'vehicle_type_id' => ['required', 'exists:vehicle_types,id'],
            'pricing_type' => ['required', 'in:flat,progressive'],
            'payment_timing' => ['required', 'in:entry,exit'],
            'base_minutes' => ['nullable', 'integer', 'min:0'],
            'base_rate' => ['required', 'integer', 'min:0'],
            'increment_minutes' => ['nullable', 'integer', 'min:0'],
            'increment_rate' => ['nullable', 'integer', 'min:0'],
            'daily_max_rate' => ['nullable', 'integer', 'min:0'],
            'grace_period_minutes' => ['nullable', 'integer', 'min:0'],
            'rounding_minutes' => ['nullable', 'integer', 'min:0'],
        ]);

        ZoneTariff::create($data);

        return back()->with('success', 'Tarif berhasil ditambahkan.');
    }

    public function update(Request $request, ZoneTariff $tariff)
    {
        $data = $request->validate([
            'vehicle_type_id' => ['required', 'exists:vehicle_types,id'],
            'pricing_type' => ['required', 'in:flat,progressive'],
            'payment_timing' => ['required', 'in:entry,exit'],
            'base_minutes' => ['nullable', 'integer', 'min:0'],
            'base_rate' => ['required', 'integer', 'min:0'],
            'increment_minutes' => ['nullable', 'integer', 'min:0'],
            'increment_rate' => ['nullable', 'integer', 'min:0'],
            'daily_max_rate' => ['nullable', 'integer', 'min:0'],
            'grace_period_minutes' => ['nullable', 'integer', 'min:0'],
            'rounding_minutes' => ['nullable', 'integer', 'min:0'],
        ]);

        $tariff->update($data);

        return back()->with('success', 'Tarif berhasil diperbarui.');
    }

    public function destroy(ZoneTariff $tariff)
    {
        if ($tariff->parkingSessions()->exists()) {
            return back()->with('error', 'Tarif tidak bisa dihapus karena masih memiliki sesi parkir.');
        }

        $tariff->delete();

        return back()->with('success', 'Tarif berhasil dihapus.');
    }
}
