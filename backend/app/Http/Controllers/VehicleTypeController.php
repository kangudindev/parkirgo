<?php

namespace App\Http\Controllers;

use App\Http\Controllers\Admin\HasAdvancedFilter;
use App\Models\VehicleType;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;
use Inertia\Inertia;

class VehicleTypeController extends Controller
{
    use HasAdvancedFilter;

    public function index(Request $request)
    {
        $query = VehicleType::orderBy('sort_order')->orderBy('name');

        if ($search = $request->input('search')) {
            $query->where(function ($q) use ($search) {
                $q->where('name', 'like', "%{$search}%")
                  ->orWhere('code', 'like', "%{$search}%");
            });
        }

        return Inertia::render('parkirgo/VehicleTypes', [
            'vehicleTypes' => $query->get(),
        ]);
    }

    public function store(Request $request)
    {
        VehicleType::create($this->validated($request));

        return back()->with('success', 'Jenis kendaraan berhasil ditambahkan.');
    }

    public function update(Request $request, VehicleType $vehicleType)
    {
        $vehicleType->update($this->validated($request, $vehicleType));

        return back()->with('success', 'Jenis kendaraan berhasil diperbarui.');
    }

    public function destroy(VehicleType $vehicleType)
    {
        if ($vehicleType->zoneTariffs()->exists() || $vehicleType->parkingSessions()->exists()) {
            return back()->with('error', 'Jenis kendaraan masih dipakai oleh tarif atau sesi parkir. Nonaktifkan statusnya jika tidak ingin digunakan.');
        }

        $vehicleType->delete();

        return back()->with('success', 'Jenis kendaraan berhasil dihapus.');
    }

    private function validated(Request $request, ?VehicleType $vehicleType = null): array
    {
        return $request->validate([
            'code' => [
                'required',
                'string',
                'max:30',
                Rule::unique('vehicle_types', 'code')->ignore($vehicleType),
            ],
            'name' => ['required', 'string', 'max:100'],
            'icon' => ['nullable', 'string', 'max:80'],
            'sort_order' => ['nullable', 'integer', 'min:0'],
            'status' => ['required', Rule::in([VehicleType::STATUS_ACTIVE, VehicleType::STATUS_INACTIVE])],
        ]);
    }
}
