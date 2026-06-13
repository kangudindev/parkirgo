<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Transaction extends Model
{
    use HasFactory;

    protected $fillable = [
        'parking_session_id',
        'zone_id',
        'jukir_id',
        'transaction_number',
        'payment_method',
        'amount',
        'status',
        'qris_payload',
        'proof_image_path',
        'verified_by',
        'verified_at',
        'verification_note',
        'sync_status',
        'local_id',
        'idempotency_key',
        'metadata',
    ];

    protected $casts = [
        'verified_at' => 'datetime',
        'metadata' => 'array',
    ];

    public function parkingSession()
    {
        return $this->belongsTo(ParkingSession::class);
    }

    public function zone()
    {
        return $this->belongsTo(Zone::class);
    }

    public function jukir()
    {
        return $this->belongsTo(User::class, 'jukir_id');
    }

    public function verifier()
    {
        return $this->belongsTo(User::class, 'verified_by');
    }
}
