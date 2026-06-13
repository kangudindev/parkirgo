<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;

class MeController extends Controller
{
    public function __invoke(Request $request)
    {
        return response()->json([
            'user' => $request->user()->load('assignedZone'),
            'capabilities' => [
                'offline_sync' => true,
                'static_qris' => true,
                'vehicle_auto_detect' => false,
            ],
        ]);
    }
}
