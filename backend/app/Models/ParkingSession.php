<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class ParkingSession extends Model
{
    use HasFactory;

    protected $fillable = [
        'zone_id',
        'tariff_id',
        'jukir_id',
        'ticket_number',
        'plate_number',
        'vehicle_type_id',
        'vehicle_type',
        'entry_at',
        'exit_at',
        'duration_minutes',
        'estimated_amount',
        'final_amount',
        'entry_photo_path',
        'exit_photo_path',
        'status',
        'payment_status',
        'sync_status',
        'local_id',
        'idempotency_key',
        'metadata',
        // Denda & Verifikasi
        'owner_name',
        'owner_nik',
        'owner_address',
        'owner_ktp_photo',
        'owner_stnk_photo',
        'exit_vehicle_photo',
        'driver_photo',
        'is_card_lost',
        'penalty_fee',
        'jukir_note',
    ];

    protected $casts = [
        'entry_at' => 'datetime',
        'exit_at' => 'datetime',
        'metadata' => 'array',
        'is_card_lost' => 'boolean',
    ];

    public function zone()
    {
        return $this->belongsTo(Zone::class);
    }

    public function vehicleTypeMaster()
    {
        return $this->belongsTo(VehicleType::class, 'vehicle_type_id');
    }

    public function tariff()
    {
        return $this->belongsTo(ZoneTariff::class, 'tariff_id');
    }

    public function jukir()
    {
        return $this->belongsTo(User::class, 'jukir_id');
    }

    public function transaction()
    {
        return $this->hasOne(Transaction::class);
    }
}
