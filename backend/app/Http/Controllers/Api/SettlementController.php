<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Settlement;
use Illuminate\Http\Request;
use Illuminate\Support\Str;

class SettlementController extends Controller
{
    public function store(Request $request)
    {
        $data = $request->validate([
            'shift_id' => ['nullable', 'exists:shifts,id'],
            'zone_id' => ['required', 'exists:zones,id'],
            'settlement_date' => ['nullable', 'date'],
            'cash_amount' => ['required', 'integer', 'min:0'],
            'qris_amount' => ['required', 'integer', 'min:0'],
            'proof_image_path' => ['nullable', 'string'],
            'local_id' => ['nullable', 'string'],
            'idempotency_key' => ['nullable', 'string'],
        ]);

        $payload = array_merge($data, [
            'jukir_id' => $request->user()->id,
            'settlement_number' => 'SET-' . now()->format('Ymd') . '-' . Str::upper(Str::random(6)),
            'settlement_date' => $data['settlement_date'] ?? now()->toDateString(),
            'total_amount' => (int) $data['cash_amount'] + (int) $data['qris_amount'],
            'status' => 'approved',
            'sync_status' => 'synced',
        ]);

        $settlement = $this->createOrUpdateByIdempotency($data['idempotency_key'] ?? null, $payload);

        return response()->json(['settlement' => $settlement->load(['zone', 'shift'])], 201);
    }

    private function createOrUpdateByIdempotency(?string $key, array $payload): Settlement
    {
        if ($key) {
            return Settlement::updateOrCreate(['idempotency_key' => $key], $payload);
        }

        return Settlement::create($payload);
    }
}
