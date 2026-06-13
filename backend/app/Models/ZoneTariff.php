<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class ZoneTariff extends Model
{
    use HasFactory;

    public const TYPE_FLAT = 'flat';
    public const TYPE_PROGRESSIVE = 'progressive';
    public const PAYMENT_ENTRY = 'entry';
    public const PAYMENT_EXIT = 'exit';

    protected $fillable = [
        'zone_id',
        'vehicle_type_id',
        'vehicle_type',
        'pricing_type',
        'payment_timing',
        'base_minutes',
        'base_rate',
        'increment_minutes',
        'increment_rate',
        'daily_max_rate',
        'grace_period_minutes',
        'rounding_minutes',
        'status',
    ];

    public function zone()
    {
        return $this->belongsTo(Zone::class);
    }

    public function vehicleTypeMaster()
    {
        return $this->belongsTo(VehicleType::class, 'vehicle_type_id');
    }

    public function parkingSessions()
    {
        return $this->hasMany(ParkingSession::class, 'tariff_id');
    }

    public function isProgressive(): bool
    {
        return $this->pricing_type === self::TYPE_PROGRESSIVE;
    }
}
