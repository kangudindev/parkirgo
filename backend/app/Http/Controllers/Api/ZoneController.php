<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\VehicleType;
use App\Models\Zone;

class ZoneController extends Controller
{
    public function index()
    {
        return response()->json([
            'zones' => Zone::with('tariffs.vehicleTypeMaster')->where('status', 'active')->paginate(50),
            'vehicle_types' => VehicleType::where('status', VehicleType::STATUS_ACTIVE)
                ->orderBy('sort_order')
                ->orderBy('name')
                ->get(),
        ]);
    }
}
