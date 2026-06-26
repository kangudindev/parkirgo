<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class SubscriptionPackage extends Model
{
    use HasFactory;

    protected $fillable = [
        'name',
        'type',
        'price',
        'duration_days',
        'max_vehicles',
        'value',
        'vehicle_type_id',
        'status',
        'description',
    ];

    public function vehicleType()
    {
        return $this->belongsTo(VehicleType::class, 'vehicle_type_id');
    }

    public function userSubscriptions()
    {
        return $this->hasMany(UserSubscription::class);
    }
}
