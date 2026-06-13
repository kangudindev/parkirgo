<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class VehicleType extends Model
{
    use HasFactory;

    public const STATUS_ACTIVE = 'active';
    public const STATUS_INACTIVE = 'inactive';

    protected $fillable = [
        'code',
        'name',
        'icon',
        'sort_order',
        'status',
    ];

    public function zoneTariffs()
    {
        return $this->hasMany(ZoneTariff::class);
    }

    public function parkingSessions()
    {
        return $this->hasMany(ParkingSession::class);
    }
}
