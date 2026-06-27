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
        'center_lat',
        'center_lng',
        'radius_meters',
        'qris_payload',
        'qris_image_path',
        'status',
    ];

    protected $casts = [
        'polygon' => 'array',
        'center_lat' => 'float',
        'center_lng' => 'float',
    ];

    protected $appends = [
        'qris_merchant_name',
    ];

    public function getQrisMerchantNameAttribute()
    {
        if (!$this->qris_payload) {
            return null;
        }

        $payload = $this->qris_payload;
        $len = strlen($payload);
        $i = 0;
        while ($i < $len - 4) {
            $tag = substr($payload, $i, 2);
            $lengthStr = substr($payload, $i + 2, 2);
            if (!is_numeric($lengthStr)) {
                break;
            }
            $length = (int)$lengthStr;
            $value = substr($payload, $i + 4, $length);
            
            if ($tag === '59') {
                return $value;
            }
            $i += 4 + $length;
        }
        return null;
    }

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
