<?php

namespace App\Support;

use App\Models\ZoneTariff;
use Carbon\CarbonInterface;

class TariffCalculator
{
    public static function calculate(ZoneTariff $tariff, CarbonInterface $entryAt, ?CarbonInterface $exitAt = null): array
    {
        $exitAt ??= now();
        $durationMinutes = max(1, $entryAt->diffInMinutes($exitAt));

        if ($durationMinutes <= $tariff->grace_period_minutes) {
            return [
                'duration_minutes' => $durationMinutes,
                'amount' => 0,
                'payment_timing' => $tariff->payment_timing,
            ];
        }

        if (! $tariff->isProgressive()) {
            return [
                'duration_minutes' => $durationMinutes,
                'amount' => $tariff->base_rate,
                'payment_timing' => ZoneTariff::PAYMENT_ENTRY,
            ];
        }

        $remainingMinutes = max(0, $durationMinutes - $tariff->base_minutes);
        $incrementMinutes = max(1, (int) ($tariff->increment_minutes ?: $tariff->rounding_minutes));
        $incrementBlocks = (int) ceil($remainingMinutes / $incrementMinutes);
        $amount = $tariff->base_rate + ($incrementBlocks * (int) $tariff->increment_rate);

        if ($tariff->daily_max_rate) {
            $amount = min($amount, $tariff->daily_max_rate);
        }

        return [
            'duration_minutes' => $durationMinutes,
            'amount' => $amount,
            'payment_timing' => ZoneTariff::PAYMENT_EXIT,
        ];
    }
}
