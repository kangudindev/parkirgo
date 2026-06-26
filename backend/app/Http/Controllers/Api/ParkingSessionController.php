<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\ParkingSession;
use App\Models\Zone;
use App\Models\ZoneTariff;
use App\Models\ZonePenalty;
use App\Support\TariffCalculator;
use Illuminate\Http\Request;
use Illuminate\Support\Carbon;

class ParkingSessionController extends Controller
{
    public function index(Request $request)
    {
        $query = ParkingSession::with(['zone', 'tariff']);

        if ($request->filled('status')) {
            $query->where('status', $request->status);
        }

        if ($request->filled('zone_id')) {
            $query->where('zone_id', $request->zone_id);
        } else {
            $query->where('zone_id', $request->user()->assigned_zone_id);
        }

        return response()->json([
            'sessions' => $query->latest()->limit(50)->get(),
        ]);
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'zone_id' => ['required', 'exists:zones,id'],
            'tariff_id' => ['nullable', 'exists:zone_tariffs,id'],
            'plate_number' => ['required', 'string', 'max:20'],
            'vehicle_type' => ['required', 'string', 'max:30'],
            'entry_at' => ['nullable', 'date'],
            'entry_photo_path' => ['nullable', 'string'],
            'local_id' => ['nullable', 'string'],
            'idempotency_key' => ['nullable', 'string'],
        ]);

        $tariff = isset($data['tariff_id'])
            ? ZoneTariff::find($data['tariff_id'])
            : ZoneTariff::where('zone_id', $data['zone_id'])
                ->where('vehicle_type', $data['vehicle_type'])
                ->where('status', 'active')
                ->first();

        // Cek Langganan Aktif
        $subCheck = \App\Services\SubscriptionService::checkSubscriptionForPlate($data['plate_number'], $data['vehicle_type']);
        $isSubActive = in_array($subCheck['type'], ['pass', 'quota']);

        $entryAt = isset($data['entry_at']) ? Carbon::parse($data['entry_at']) : now();
        
        if ($isSubActive) {
            $calculation = ['amount' => 0];
        } else {
            $calculation = $tariff ? TariffCalculator::calculate($tariff, $entryAt) : ['amount' => 0];
        }

        $zone = Zone::find($data['zone_id']);
        $zoneCode = $zone?->code ?? 'XXX';
        $today = now()->format('ymd');
        $lastToday = ParkingSession::where('zone_id', $data['zone_id'])
            ->whereDate('created_at', today())
            ->count();
        $sequence = str_pad($lastToday + 1, 4, '0', STR_PAD_LEFT);

        $metadata = [];
        $paymentStatus = 'unpaid';
        $finalAmount = null;

        if ($isSubActive) {
            $paymentStatus = 'paid';
            $finalAmount = 0;
            $metadata['subscription_type'] = $subCheck['type'];
            $metadata['subscription_id'] = $subCheck['subscription_id'];

            // Jika tipe kuota dan bayar di muka, kurangi kuota langsung
            if ($subCheck['type'] === 'quota' && $tariff?->payment_timing === ZoneTariff::PAYMENT_ENTRY) {
                \App\Services\SubscriptionService::deductQuotaOrBalance($subCheck, 0);
            }
        } elseif ($tariff?->payment_timing === ZoneTariff::PAYMENT_ENTRY) {
            $finalAmount = $calculation['amount'];
            $paymentStatus = 'paid';
        }

        $payload = array_merge($data, [
            'tariff_id' => $tariff?->id,
            'jukir_id' => $request->user()->id,
            'ticket_number' => "{$zoneCode}-{$today}-{$sequence}",
            'entry_at' => $entryAt,
            'estimated_amount' => $calculation['amount'],
            'final_amount' => $finalAmount,
            'payment_status' => $paymentStatus,
            'sync_status' => 'synced',
            'status' => 'active',
            'metadata' => $metadata,
        ]);

        $session = $this->createOrUpdateByIdempotency($data['idempotency_key'] ?? null, $payload);

        return response()->json(['session' => $session->load(['zone', 'tariff'])], 201);
    }

    public function showByTicket(Request $request, string $ticket)
    {
        $session = ParkingSession::with(['zone', 'tariff'])
            ->where('ticket_number', $ticket)
            ->first();

        if (! $session) {
            return response()->json(['message' => 'Tiket tidak ditemukan'], 404);
        }

        return response()->json(['session' => $session]);
    }

    public function close(Request $request, ParkingSession $parkingSession)
    {
        $data = $request->validate([
            'exit_at' => ['nullable', 'date'],
            'exit_photo_path' => ['nullable', 'string'],
        ]);

        $exitAt = isset($data['exit_at']) ? Carbon::parse($data['exit_at']) : now();
        $tariff = $parkingSession->tariff;
        $calculation = $tariff ? TariffCalculator::calculate($tariff, $parkingSession->entry_at, $exitAt) : ['amount' => $parkingSession->estimated_amount, 'duration_minutes' => null];

        $finalAmount = $calculation['amount'];
        $paymentStatus = 'unpaid';
        $metadata = $parkingSession->metadata ?? [];

        // Cek jika sudah lunas saat masuk lewat langganan
        $alreadyPaidBySub = isset($metadata['subscription_type']) && in_array($metadata['subscription_type'], ['pass', 'quota']);

        if ($alreadyPaidBySub) {
            $finalAmount = 0;
            $paymentStatus = 'paid';
        } else {
            // Cek langganan baru saat keluar
            $subCheck = \App\Services\SubscriptionService::checkSubscriptionForPlate($parkingSession->plate_number, $parkingSession->vehicle_type);

            if ($subCheck['type'] === 'pass') {
                $finalAmount = 0;
                $paymentStatus = 'paid';
                $metadata['subscription_type'] = 'pass';
                $metadata['subscription_id'] = $subCheck['subscription_id'];
            } elseif ($subCheck['type'] === 'quota') {
                // Potong kuota sesi
                if (\App\Services\SubscriptionService::deductQuotaOrBalance($subCheck, 0)) {
                    $finalAmount = 0;
                    $paymentStatus = 'paid';
                    $metadata['subscription_type'] = 'quota';
                    $metadata['subscription_id'] = $subCheck['subscription_id'];
                }
            } elseif ($subCheck['type'] === 'wallet' && $finalAmount > 0) {
                // Potong saldo prabayar
                if (\App\Services\SubscriptionService::deductQuotaOrBalance($subCheck, $finalAmount)) {
                    $paymentStatus = 'paid';
                    $metadata['payment_method'] = 'wallet';
                    $metadata['wallet_id'] = $subCheck['wallet_id'];

                    // Catat transaksi lunas otomatis via dompet prabayar
                    \App\Models\Transaction::create([
                        'transaction_number' => 'TRX-WAL-' . now()->format('Ymd') . '-' . $parkingSession->zone_id . '-' . rand(1000, 9999),
                        'parking_session_id' => $parkingSession->id,
                        'zone_id' => $parkingSession->zone_id,
                        'jukir_id' => $request->user()->id,
                        'payment_method' => 'wallet',
                        'amount' => $finalAmount,
                        'status' => 'recorded',
                        'created_at' => $exitAt,
                    ]);
                }
            }
        }

        $parkingSession->update([
            'exit_at' => $exitAt,
            'exit_photo_path' => $data['exit_photo_path'] ?? null,
            'duration_minutes' => $calculation['duration_minutes'] ?? null,
            'final_amount' => $finalAmount,
            'payment_status' => $paymentStatus,
            'status' => 'exited',
            'metadata' => $metadata,
        ]);

        if (! $parkingSession->closed_by) {
            $parkingSession->update(['closed_by' => $request->user()->id]);
        }

        return response()->json(['session' => $parkingSession->fresh(['zone', 'tariff'])]);
    }

    public function forceExit(Request $request, ParkingSession $parkingSession)
    {
        $data = $request->validate([
            'owner_name' => ['required', 'string', 'max:100'],
            'owner_nik' => ['required', 'string', 'max:30'],
            'owner_address' => ['nullable', 'string'],
            'owner_ktp_photo' => ['required', 'string'],
            'owner_stnk_photo' => ['required', 'string'],
            'exit_vehicle_photo' => ['required', 'string'],
            'driver_photo' => ['required', 'string'],
            'jukir_note' => ['nullable', 'string', 'max:500'],
        ]);

        $tariff = $parkingSession->tariff;
        $exitAt = now();
        $calculation = $tariff ? TariffCalculator::calculate($tariff, $parkingSession->entry_at, $exitAt) : ['amount' => $parkingSession->estimated_amount, 'duration_minutes' => null];
        $parkingFee = $calculation['amount'];

        // Hitung denda karcis hilang
        $penalty = ZonePenalty::where('zone_id', $parkingSession->zone_id)
            ->where('penalty_type', ZonePenalty::TYPE_CARD_LOST)
            ->where(function ($q) use ($parkingSession) {
                $q->where('vehicle_type', $parkingSession->vehicle_type)
                  ->orWhereNull('vehicle_type');
            })
            ->where('status', 'active')
            ->orderByRaw("CASE WHEN vehicle_type = ? THEN 0 ELSE 1 END", [$parkingSession->vehicle_type])
            ->first();
        $penaltyFee = $penalty?->amount ?? 0;

        $parkingSession->update(array_merge($data, [
            'exit_at' => $exitAt,
            'duration_minutes' => $calculation['duration_minutes'] ?? null,
            'final_amount' => $parkingFee,
            'penalty_fee' => $penaltyFee,
            'is_card_lost' => true,
            'closed_by' => $request->user()->id,
            'status' => 'exited',
            'payment_status' => 'unpaid',
        ]));

        return response()->json([
            'session' => $parkingSession->fresh(['zone', 'tariff']),
            'parking_fee' => $parkingFee,
            'penalty_fee' => $penaltyFee,
            'total_fee' => $parkingFee + $penaltyFee,
        ]);
    }

    public function unregisteredExit(Request $request)
    {
        $data = $request->validate([
            'zone_id' => ['required', 'exists:zones,id'],
            'plate_number' => ['required', 'string', 'max:20'],
            'vehicle_type' => ['required', 'string', 'max:30'],
            'owner_name' => ['required', 'string', 'max:100'],
            'owner_nik' => ['required', 'string', 'max:30'],
            'owner_address' => ['nullable', 'string'],
            'owner_ktp_photo' => ['required', 'string'],
            'owner_stnk_photo' => ['required', 'string'],
            'exit_vehicle_photo' => ['required', 'string'],
            'driver_photo' => ['required', 'string'],
            'jukir_note' => ['nullable', 'string', 'max:500'],
        ]);

        $zone = Zone::find($data['zone_id']);
        $zoneCode = $zone?->code ?? 'XXX';
        $today = now()->format('ymd');
        $lastToday = ParkingSession::where('zone_id', $data['zone_id'])
            ->whereDate('created_at', today())
            ->count();
        $sequence = str_pad($lastToday + 1, 4, '0', STR_PAD_LEFT);

        // Cari tarif untuk dapat max daily rate
        $tariff = ZoneTariff::where('zone_id', $data['zone_id'])
            ->where('vehicle_type', $data['vehicle_type'])
            ->where('status', 'active')
            ->first();
        $maxDailyFee = $tariff?->daily_max_rate ?? ($tariff?->base_rate ?? 0);

        // Denda tidak tercatat
        $penalty = ZonePenalty::where('zone_id', $data['zone_id'])
            ->where('penalty_type', ZonePenalty::TYPE_UNREGISTERED)
            ->where(function ($q) use ($data) {
                $q->where('vehicle_type', $data['vehicle_type'])
                  ->orWhereNull('vehicle_type');
            })
            ->where('status', 'active')
            ->orderByRaw("CASE WHEN vehicle_type = ? THEN 0 ELSE 1 END", [$data['vehicle_type']])
            ->first();
        $penaltyFee = $penalty?->amount ?? 0;

        $session = ParkingSession::create([
            'zone_id' => $data['zone_id'],
            'jukir_id' => $request->user()->id,
            'closed_by' => $request->user()->id,
            'ticket_number' => "{$zoneCode}-{$today}-{$sequence}",
            'plate_number' => $data['plate_number'],
            'vehicle_type' => $data['vehicle_type'],
            'entry_at' => now(),
            'exit_at' => now(),
            'duration_minutes' => 0,
            'estimated_amount' => $maxDailyFee,
            'final_amount' => $maxDailyFee,
            'penalty_fee' => $penaltyFee,
            'is_card_lost' => false,
            'owner_name' => $data['owner_name'],
            'owner_nik' => $data['owner_nik'],
            'owner_address' => $data['owner_address'],
            'owner_ktp_photo' => $data['owner_ktp_photo'],
            'owner_stnk_photo' => $data['owner_stnk_photo'],
            'exit_vehicle_photo' => $data['exit_vehicle_photo'],
            'driver_photo' => $data['driver_photo'],
            'jukir_note' => $data['jukir_note'],
            'status' => 'exited',
            'payment_status' => 'unpaid',
            'sync_status' => 'synced',
        ]);

        return response()->json([
            'session' => $session->load(['zone', 'tariff']),
            'parking_fee' => $maxDailyFee,
            'penalty_fee' => $penaltyFee,
            'total_fee' => $maxDailyFee + $penaltyFee,
        ], 201);
    }

    private function createOrUpdateByIdempotency(?string $key, array $payload): ParkingSession
    {
        if ($key) {
            return ParkingSession::updateOrCreate(['idempotency_key' => $key], $payload);
        }

        return ParkingSession::create($payload);
    }
}
