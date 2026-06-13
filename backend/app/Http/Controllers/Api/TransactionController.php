<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\ParkingSession;
use App\Models\Transaction;
use Illuminate\Http\Request;
use Illuminate\Support\Str;

class TransactionController extends Controller
{
    public function index(Request $request)
    {
        $transactions = Transaction::with(['zone', 'jukir', 'parkingSession'])
            ->where('jukir_id', $request->user()->id)
            ->latest()
            ->limit(50)
            ->get();

        return response()->json(['transactions' => $transactions]);
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'parking_session_id' => ['nullable', 'exists:parking_sessions,id'],
            'zone_id' => ['required', 'exists:zones,id'],
            'payment_method' => ['required', 'in:cash,qris'],
            'amount' => ['required', 'integer', 'min:0'],
            'qris_payload' => ['nullable', 'string'],
            'proof_image_path' => ['nullable', 'string'],
            'local_id' => ['nullable', 'string'],
            'idempotency_key' => ['nullable', 'string'],
            'metadata' => ['nullable', 'array'],
        ]);

        $payload = array_merge($data, [
            'jukir_id' => $request->user()->id,
            'transaction_number' => 'TRX-' . now()->format('Ymd') . '-' . Str::upper(Str::random(6)),
            'status' => $data['payment_method'] === 'qris' ? 'recorded' : 'verified',
            'sync_status' => 'synced',
        ]);

        $transaction = $this->createOrUpdateByIdempotency($data['idempotency_key'] ?? null, $payload);

        if (! empty($data['parking_session_id'])) {
            ParkingSession::whereKey($data['parking_session_id'])->update(['payment_status' => 'paid']);
        }

        return response()->json(['transaction' => $transaction->load(['zone', 'parkingSession'])], 201);
    }

    private function createOrUpdateByIdempotency(?string $key, array $payload): Transaction
    {
        if ($key) {
            return Transaction::updateOrCreate(['idempotency_key' => $key], $payload);
        }

        return Transaction::create($payload);
    }
}
