<?php

namespace App\Services;

use App\Models\SubscriptionVehicle;
use App\Models\UserSubscription;
use App\Models\UserWallet;
use Illuminate\Support\Facades\DB;

class SubscriptionService
{
    /**
     * Membersihkan plat nomor dari spasi dan karakter non-alphanumeric untuk pencocokan presisi.
     */
    public static function cleanPlate(string $plate): string
    {
        return strtoupper(preg_replace('/[^A-Z0-9]/', '', $plate));
    }

    /**
     * Memeriksa apakah plat nomor memiliki langganan aktif atau saldo yang cukup.
     * Mengembalikan informasi tipe pembayaran: 'pass', 'quota', 'wallet', atau 'none'.
     */
    public static function checkSubscriptionForPlate(string $plateNumber, string $vehicleType): array
    {
        $cleanPlate = self::cleanPlate($plateNumber);
        $today = now()->toDateString();

        // 1. Cari kendaraan berlangganan yang terdaftar dan aktif
        $vehicles = SubscriptionVehicle::whereRaw("REPLACE(REPLACE(UPPER(license_plate), ' ', ''), '-', '') = ?", [$cleanPlate])
            ->whereHas('userSubscription', function ($query) use ($today, $vehicleType) {
                $query->where('status', 'active')
                    ->whereDate('start_date', '<=', $today)
                    ->whereDate('end_date', '>=', $today)
                    ->whereHas('package', function ($qp) use ($vehicleType) {
                        $qp->where('status', 'active')
                           ->whereHas('vehicleType', function ($qvt) use ($vehicleType) {
                               $qvt->where('code', $vehicleType);
                           });
                    });
            })
            ->with(['userSubscription.package'])
            ->get();

        // 2. Prioritas 1: Unlimited Pass
        $passSub = $vehicles->first(fn($v) => $v->userSubscription->type === 'pass');
        if ($passSub) {
            return [
                'type' => 'pass',
                'subscription_id' => $passSub->userSubscription->id,
                'message' => 'Langganan Unlimited Pass Aktif',
                'user_id' => $passSub->userSubscription->user_id,
            ];
        }

        // 3. Prioritas 2: Kuota Sesi Parkir
        $quotaSub = $vehicles->first(fn($v) => $v->userSubscription->type === 'quota' && $v->userSubscription->value_remaining > 0);
        if ($quotaSub) {
            return [
                'type' => 'quota',
                'subscription_id' => $quotaSub->userSubscription->id,
                'value_remaining' => $quotaSub->userSubscription->value_remaining,
                'message' => "Langganan Kuota Aktif (Sisa: {$quotaSub->userSubscription->value_remaining} Sesi)",
                'user_id' => $quotaSub->userSubscription->user_id,
            ];
        }

        // 4. Prioritas 3: Saldo Dompet (Prepaid Balance)
        // Cari user_id dari data pendaftaran kendaraan sebelumnya (baik aktif maupun expired)
        $anySub = SubscriptionVehicle::whereRaw("REPLACE(REPLACE(UPPER(license_plate), ' ', ''), '-', '') = ?", [$cleanPlate])
            ->whereHas('userSubscription')
            ->with(['userSubscription'])
            ->latest()
            ->first();

        if ($anySub && $anySub->userSubscription->user_id) {
            $wallet = UserWallet::where('user_id', $anySub->userSubscription->user_id)->first();
            if ($wallet && $wallet->balance > 0) {
                return [
                    'type' => 'wallet',
                    'wallet_id' => $wallet->id,
                    'balance' => $wallet->balance,
                    'message' => "Saldo Dompet Tersedia (Rp " . number_format($wallet->balance, 0, ',', '.') . ")",
                    'user_id' => $anySub->userSubscription->user_id,
                ];
            }
        }

        return [
            'type' => 'none',
            'message' => 'Tidak ada langganan atau saldo aktif',
            'user_id' => null,
        ];
    }

    /**
     * Memotong kuota sesi atau saldo dompet prabayar.
     */
    public static function deductQuotaOrBalance(array $checkResult, float $amount): bool
    {
        if ($checkResult['type'] === 'quota' && isset($checkResult['subscription_id'])) {
            $sub = UserSubscription::find($checkResult['subscription_id']);
            if ($sub && $sub->value_remaining > 0) {
                $sub->decrement('value_remaining');
                if ($sub->value_remaining <= 0) {
                    $sub->update(['status' => 'used_up']);
                }
                return true;
            }
        }

        if ($checkResult['type'] === 'wallet' && isset($checkResult['wallet_id']) && $amount > 0) {
            $wallet = UserWallet::find($checkResult['wallet_id']);
            if ($wallet && $wallet->balance >= $amount) {
                $wallet->decrement('balance', $amount);
                return true;
            }
        }

        return false;
    }
}
