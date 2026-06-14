<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Zone extends Model
{
    use HasFactory;

    protected $fillable = [
        'code',
        'name',
        'city',
        'polygon',
        'qris_payload',
        'qris_image_path',
        'status',
    ];

    protected $casts = [
        'polygon' => 'array',
    ];

    public function tariffs()
    {
        return $this->hasMany(ZoneTariff::class);
    }

    public function vehicleTypes()
    {
        return $this->belongsToMany(VehicleType::class, 'zone_vehicle_types')
            ->withPivot('capacity')
            ->withTimestamps();
    }

    public function jukirs()
    {
        return $this->hasMany(User::class, 'assigned_zone_id');
    }

    public function shifts()
    {
        return $this->hasMany(Shift::class);
    }

    public function parkingSessions()
    {
        return $this->hasMany(ParkingSession::class);
    }

    public function transactions()
    {
        return $this->hasMany(Transaction::class);
    }
}
