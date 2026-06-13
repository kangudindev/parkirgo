<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Settlement extends Model
{
    use HasFactory;

    protected $fillable = [
        'shift_id',
        'zone_id',
        'jukir_id',
        'settlement_number',
        'settlement_date',
        'cash_amount',
        'qris_amount',
        'total_amount',
        'proof_image_path',
        'status',
        'approved_by',
        'approved_at',
        'approval_note',
        'sync_status',
        'local_id',
        'idempotency_key',
    ];

    protected $casts = [
        'settlement_date' => 'date',
        'approved_at' => 'datetime',
    ];

    public function shift()
    {
        return $this->belongsTo(Shift::class);
    }

    public function zone()
    {
        return $this->belongsTo(Zone::class);
    }

    public function jukir()
    {
        return $this->belongsTo(User::class, 'jukir_id');
    }

    public function approver()
    {
        return $this->belongsTo(User::class, 'approved_by');
    }
}
