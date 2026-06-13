<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class ZonePenalty extends Model
{
    protected $fillable = [
        'zone_id',
        'vehicle_type',
        'penalty_type',
        'amount',
        'status',
    ];

    const TYPE_CARD_LOST = 'card_lost';
    const TYPE_UNREGISTERED = 'unregistered';

    public function zone()
    {
        return $this->belongsTo(Zone::class);
    }
}
