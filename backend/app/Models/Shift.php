<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Shift extends Model
{
    use HasFactory;

    protected $fillable = [
        'zone_id',
        'user_id',
        'code',
        'shift_date',
        'start_time',
        'end_time',
        'status',
    ];

    protected $casts = [
        'shift_date' => 'date',
    ];

    public function zone()
    {
        return $this->belongsTo(Zone::class);
    }

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function attendances()
    {
        return $this->hasMany(Attendance::class);
    }

    public function settlements()
    {
        return $this->hasMany(Settlement::class);
    }
}
