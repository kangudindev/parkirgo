<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Attendance;
use App\Models\ParkingSession;
use App\Models\Settlement;
use App\Models\Transaction;
use App\Models\ZoneTariff;
use App\Support\TariffCalculator;
use Illuminate\Http\Request;
use Illuminate\Support\Carbon;
use Illuminate\Support\Str;

class SyncController extends Controller
{
    public function __invoke(Request $request)
    {
        $data = $request->validate([
            'client_batch_id' => ['nullable', 'string'],
            'device_id' => ['nullable', 'string'],
            'items' => ['required', 'array'],
            'items.*.type' => ['required', 'in:attendance,parking_session,transaction,settlement'],
            'items.*.local_id' => ['required', 'string'],
            'items.*.idempotency_key' => ['required', 'string'],
            'items.*.payload' => ['required', 'array'],
        ]);

        $results = [];

        foreach ($data['items'] as $item) {
            $result = $this->processItem($item, $request->user());
            $results[] = $result;
        }

        return response()->json([
            'client_batch_id' => $data['client_batch_id'] ?? null,
            'device_id' => $data['device_id'] ?? $request->user()->device_id,
            'accepted_count' => count($results),
            'results' => $results,
            'server_time' => now()->toISOString(),
        ]);
    }

    private function processItem(array $item, $user): array
    {
        $idempotencyKey = $item['idempotency_key'];
        $type = $item['type'];
        $payload = $item['payload'];

        try {
            return match ($type) {
                'attendance' => $this->syncAttendance($payload, $user, $idempotencyKey),
                'parking_session' => $this->syncParkingSession($payload, $user, $idempotencyKey),
                'transaction' => $this->syncTransaction($payload, $user, $idempotencyKey),
                'settlement' => $this->syncSettlement($payload, $user, $idempotencyKey),
                default => [
                    'type' => $type,
                    'local_id' => $item['local_id'],
                    'idempotency_key' => $idempotencyKey,
                    'status' => 'skipped',
                    'reason' => 'Unknown type',
                ],
            };
        } catch (\Exception $e) {
            return [
                'type' => $type,
                'local_id' => $item['local_id'],
                'idempotency_key' => $idempotencyKey,
                'status' => 'failed',
                'reason' => $e->getMessage(),
            ];
        }
    }

    private function syncAttendance(array $payload, $user, string $key): array
    {
        $attendance = Attendance::updateOrCreate(
            ['idempotency_key' => $key],
            [
                'user_id' => $user->id,
                'zone_id' => $payload['zone_id'] ?? 1,
                'shift_id' => $payload['shift_id'] ?? null,
                'check_in_at' => $payload['check_in_at'] ?? now(),
                'check_out_at' => $payload['check_out_at'] ?? null,
                'check_in_latitude' => $payload['check_in_latitude'] ?? null,
                'check_in_longitude' => $payload['check_in_longitude'] ?? null,
                'check_out_latitude' => $payload['check_out_latitude'] ?? null,
                'check_out_longitude' => $payload['check_out_longitude'] ?? null,
                'selfie_path' => $payload['selfie_path'] ?? null,
                'local_id' => $payload['local_id'] ?? null,
                'sync_status' => 'synced',
            ]
        );

        return [
            'type' => 'attendance',
            'local_id' => $payload['local_id'] ?? null,
            'idempotency_key' => $attendance->idempotency_key,
            'status' => 'synced',
            'server_id' => $attendance->id,
        ];
    }

    private function syncParkingSession(array $payload, $user, string $key): array
    {
        $tariff = null;
        if (isset($payload['tariff_id'])) {
            $tariff = ZoneTariff::find($payload['tariff_id']);
        }

        $entryAt = isset($payload['entry_at']) ? Carbon::parse($payload['entry_at']) : now();
        $calculation = $tariff ? TariffCalculator::calculate($tariff, $entryAt) : ['amount' => 0];

        $session = ParkingSession::updateOrCreate(
            ['idempotency_key' => $key],
            [
                'zone_id' => $payload['zone_id'] ?? 1,
                'tariff_id' => $tariff?->id,
                'jukir_id' => $user->id,
                'ticket_number' => $payload['ticket_number'] ?? ('TMR-' . now()->format('ymd') . '-' . Str::upper(Str::random(6))),
                'plate_number' => $payload['plate_number'] ?? '-',
                'vehicle_type' => $payload['vehicle_type'] ?? 'motor',
                'entry_at' => $entryAt,
                'exit_at' => $payload['exit_at'] ?? null,
                'entry_photo_path' => $payload['entry_photo_path'] ?? null,
                'exit_photo_path' => $payload['exit_photo_path'] ?? null,
                'estimated_amount' => $calculation['amount'],
                'status' => $payload['status'] ?? 'active',
                'payment_status' => $payload['payment_status'] ?? 'unpaid',
                'local_id' => $payload['local_id'] ?? null,
                'sync_status' => 'synced',
            ]
        );

        return [
            'type' => 'parking_session',
            'local_id' => $payload['local_id'] ?? null,
            'idempotency_key' => $session->idempotency_key,
            'status' => 'synced',
            'server_id' => $session->id,
        ];
    }

    private function syncTransaction(array $payload, $user, string $key): array
    {
        $transaction = Transaction::updateOrCreate(
            ['idempotency_key' => $key],
            [
                'parking_session_id' => $payload['parking_session_id'] ?? null,
                'zone_id' => $payload['zone_id'] ?? 1,
                'jukir_id' => $user->id,
                'transaction_number' => $payload['transaction_number'] ?? ('TRX-' . now()->format('Ymd') . '-' . Str::upper(Str::random(6))),
                'payment_method' => $payload['payment_method'] ?? 'cash',
                'amount' => $payload['amount'] ?? 0,
                'status' => $payload['payment_method'] === 'qris' ? 'recorded' : 'verified',
                'qris_payload' => $payload['qris_payload'] ?? null,
                'proof_image_path' => $payload['proof_image_path'] ?? null,
                'local_id' => $payload['local_id'] ?? null,
                'sync_status' => 'synced',
            ]
        );

        if (! empty($payload['parking_session_id'])) {
            ParkingSession::where('id', $payload['parking_session_id'])
                ->update(['payment_status' => 'paid']);
        }

        return [
            'type' => 'transaction',
            'local_id' => $payload['local_id'] ?? null,
            'idempotency_key' => $transaction->idempotency_key,
            'status' => 'synced',
            'server_id' => $transaction->id,
        ];
    }

    private function syncSettlement(array $payload, $user, string $key): array
    {
        $settlement = Settlement::updateOrCreate(
            ['idempotency_key' => $key],
            [
                'shift_id' => $payload['shift_id'] ?? null,
                'zone_id' => $payload['zone_id'] ?? 1,
                'jukir_id' => $user->id,
                'settlement_number' => $payload['settlement_number'] ?? ('SET-' . now()->format('Ymd') . '-' . Str::upper(Str::random(6))),
                'settlement_date' => $payload['settlement_date'] ?? now(),
                'cash_amount' => $payload['cash_amount'] ?? 0,
                'qris_amount' => $payload['qris_amount'] ?? 0,
                'total_amount' => ($payload['cash_amount'] ?? 0) + ($payload['qris_amount'] ?? 0),
                'proof_image_path' => $payload['proof_image_path'] ?? null,
                'status' => 'approved',
                'local_id' => $payload['local_id'] ?? null,
                'sync_status' => 'synced',
            ]
        );

        return [
            'type' => 'settlement',
            'local_id' => $payload['local_id'] ?? null,
            'idempotency_key' => $settlement->idempotency_key,
            'status' => 'synced',
            'server_id' => $settlement->id,
        ];
    }
}
