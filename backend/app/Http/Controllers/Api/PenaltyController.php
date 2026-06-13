<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\ZonePenalty;
use Illuminate\Http\Request;

class PenaltyController extends Controller
{
    public function index(Request $request)
    {
        $query = ZonePenalty::with('zone');

        if ($request->filled('zone_id')) {
            $query->where('zone_id', $request->zone_id);
        }

        return response()->json([
            'penalties' => $query->latest()->get(),
        ]);
    }

    public function byZoneAndType(Request $request)
    {
        $data = $request->validate([
            'zone_id' => ['required', 'exists:zones,id'],
            'vehicle_type' => ['required', 'string'],
            'penalty_type' => ['required', 'in:card_lost,unregistered'],
        ]);

        // Cari denda spesifik untuk tipe kendaraan, fallback ke null (semua jenis)
        $penalty = ZonePenalty::where('zone_id', $data['zone_id'])
            ->where('penalty_type', $data['penalty_type'])
            ->where(function ($q) use ($data) {
                $q->where('vehicle_type', $data['vehicle_type'])
                  ->orWhereNull('vehicle_type');
            })
            ->where('status', 'active')
            ->orderByRaw("CASE WHEN vehicle_type = ? THEN 0 ELSE 1 END", [$data['vehicle_type']])
            ->first();

        return response()->json([
            'penalty' => $penalty,
            'amount' => $penalty?->amount ?? 0,
        ]);
    }
}
