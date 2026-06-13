<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Attendance;
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

        $data['user_id'] = $request->user()->id;
        $data['sync_status'] = 'synced';

        $attendance = $this->createOrUpdateByIdempotency($data['idempotency_key'] ?? null, $data);

        return response()->json(['attendance' => $attendance->load(['zone', 'shift'])], 201);
    }

    private function createOrUpdateByIdempotency(?string $key, array $payload): Attendance
    {
        if ($key) {
            return Attendance::updateOrCreate(['idempotency_key' => $key], $payload);
        }

        return Attendance::create($payload);
    }
}
