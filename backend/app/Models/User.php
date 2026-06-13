<?php

namespace App\Models;

use Illuminate\Contracts\Auth\MustVerifyEmail;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Fortify\TwoFactorAuthenticatable;
use Laravel\Jetstream\HasProfilePhoto;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable implements MustVerifyEmail
{
    use HasApiTokens;
    use HasFactory;
    use HasProfilePhoto;
    use Notifiable;
    use TwoFactorAuthenticatable;

    /**
     * The attributes that are mass assignable.
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'name',
        'email',
        'password',
        'role',
        'nik',
        'phone',
        'status',
        'device_id',
        'qr_auth_token',
        'assigned_zone_id',
        'last_seen_at',
    ];

    /**
     * The attributes that should be hidden for serialization.
     *
     * @var array<int, string>
     */
    protected $hidden = [
        'password',
        'remember_token',
        'two_factor_recovery_codes',
        'two_factor_secret',
    ];

    /**
     * The attributes that should be cast.
     *
     * @var array<string, string>
     */
    protected $casts = [
        'email_verified_at' => 'datetime',
        'last_seen_at' => 'datetime',
    ];

    /**
     * The accessors to append to the model's array form.
     *
     * @var array<int, string>
     */
    protected $appends = [
        'profile_photo_url',
        'has_qr_token',
    ];

    public function getHasQrTokenAttribute(): bool
    {
        return ! is_null($this->qr_auth_token);
    }

    public function assignedZone()
    {
        return $this->belongsTo(Zone::class, 'assigned_zone_id');
    }

    public function shifts()
    {
        return $this->hasMany(Shift::class);
    }

    public function attendances()
    {
        return $this->hasMany(Attendance::class);
    }

    public function parkingSessions()
    {
        return $this->hasMany(ParkingSession::class, 'jukir_id');
    }

    public function transactions()
    {
        return $this->hasMany(Transaction::class, 'jukir_id');
    }

    public function settlements()
    {
        return $this->hasMany(Settlement::class, 'jukir_id');
    }

    public function auditLogs()
    {
        return $this->hasMany(AuditLog::class);
    }
}
