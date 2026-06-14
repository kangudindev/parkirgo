<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Attendance;
use App\Models\Zone;
use Illuminate\Http\Request;

class AttendanceController extends Controller
{
    public function store(Request $request)
    {
        $data = $request->validate([
            'shift_id' => ['nullable', 'exists:shifts,id'],
            'zone_id' => ['required', 'exists:zones,id'],
            'check_in_at' => ['nullable', 'date'],
            'check_out_at' => ['nullable', 'date'],
            'check_in_latitude' => ['nullable', 'numeric'],
            'check_in_longitude' => ['nullable', 'numeric'],
            'check_out_latitude' => ['nullable', 'numeric'],
            'check_out_longitude' => ['nullable', 'numeric'],
            'selfie_path' => ['nullable', 'string'],
            'local_id' => ['nullable', 'string'],
            'idempotency_key' => ['nullable', 'string'],
        ]);

        $zone = Zone::findOrFail($data['zone_id']);
        $user = $request->user();

        $lat = $data['check_in_latitude'] ?? $data['check_out_latitude'] ?? null;
        $lng = $data['check_in_longitude'] ?? $data['check_out_longitude'] ?? null;

        if ($lat && $lng && $zone->center_lat && $zone->center_lng) {
            $distance = $this->haversine(
                (float) $lat,
                (float) $lng,
                (float) $zone->center_lat,
                (float) $zone->center_lng
            );

            $radius = $zone->radius_meters ?: 150;

            if ($distance > $radius) {
                return response()->json([
                    'error' => 'Lokasi anda diluar zona parkir.',
                    'distance_meters' => round($distance, 1),
                    'max_radius_meters' => $radius,
                ], 422);
            }
        }

        $data['user_id'] = $user->id;
        $data['sync_status'] = 'synced';

        $attendance = $this->createOrUpdateByIdempotency($data['idempotency_key'] ?? null, $data);

        return response()->json(['attendance' => $attendance->load(['zone', 'shift'])], 201);
    }

    private function haversine(float $lat1, float $lng1, float $lat2, float $lng2): float
    {
        $earthRadius = 6371000;
        $dLat = deg2rad($lat2 - $lat1);
        $dLng = deg2rad($lng2 - $lng1);
        $a = sin($dLat / 2) ** 2 + cos(deg2rad($lat1)) * cos(deg2rad($lat2)) * sin($dLng / 2) ** 2;
        return $earthRadius * 2 * atan2(sqrt($a), sqrt(1 - $a));
    }

    private function createOrUpdateByIdempotency(?string $key, array $payload): Attendance
    {
        if ($key) {
            return Attendance::updateOrCreate(['idempotency_key' => $key], $payload);
        }

        return Attendance::create($payload);
    }
}
