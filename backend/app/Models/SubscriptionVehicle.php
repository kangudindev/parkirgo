<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class SubscriptionVehicle extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_subscription_id',
        'license_plate',
        'label',
    ];

    public function userSubscription()
    {
        return $this->belongsTo(UserSubscription::class, 'user_subscription_id');
    }
}
