<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\SubscriptionPackage;
use App\Models\VehicleType;
use Illuminate\Http\Request;
use Inertia\Inertia;

class SubscriptionPackageController extends Controller
{
    use HasAdvancedFilter;

    public function index(Request $request)
    {
        $packages = $this->applySort(
            $this->applySearch(SubscriptionPackage::with('vehicleType'), $request, ['name', 'type']),
            $request,
            ['created_at', 'name', 'price', 'status']
        )->paginate($this->perPage($request));

        $vehicleTypes = VehicleType::where('status', 'active')->orderBy('name')->get();

        return Inertia::render('parkirgo/SubscriptionPackages', [
            'packages' => $packages,
            'vehicleTypes' => $vehicleTypes,
        ]);
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'name' => ['required', 'string', 'max:100'],
            'type' => ['required', 'in:pass,quota,balance'],
            'price' => ['required', 'numeric', 'min:0'],
            'duration_days' => ['required', 'integer', 'min:1'],
            'max_vehicles' => ['required', 'integer', 'min:1'],
            'value' => ['nullable', 'numeric', 'min:0'],
            'vehicle_type_id' => ['required', 'exists:vehicle_types,id'],
            'status' => ['required', 'in:active,inactive'],
            'description' => ['nullable', 'string'],
        ]);

        SubscriptionPackage::create($data);

        return back()->with('success', 'Paket langganan berhasil ditambahkan.');
    }

    public function update(Request $request, SubscriptionPackage $subscriptionPackage)
    {
        $data = $request->validate([
            'name' => ['required', 'string', 'max:100'],
            'type' => ['required', 'in:pass,quota,balance'],
            'price' => ['required', 'numeric', 'min:0'],
            'duration_days' => ['required', 'integer', 'min:1'],
            'max_vehicles' => ['required', 'integer', 'min:1'],
            'value' => ['nullable', 'numeric', 'min:0'],
            'vehicle_type_id' => ['required', 'exists:vehicle_types,id'],
            'status' => ['required', 'in:active,inactive'],
            'description' => ['nullable', 'string'],
        ]);

        $subscriptionPackage->update($data);

        return back()->with('success', 'Paket langganan berhasil diperbarui.');
    }

    public function destroy(SubscriptionPackage $subscriptionPackage)
    {
        if ($subscriptionPackage->userSubscriptions()->exists()) {
            return back()->with('error', 'Paket tidak bisa dihapus karena masih digunakan oleh pelanggan.');
        }

        $subscriptionPackage->delete();

        return back()->with('success', 'Paket langganan berhasil dihapus.');
    }
}
