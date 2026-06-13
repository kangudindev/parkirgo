<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Carbon;
use Illuminate\Validation\ValidationException;

class AuthController extends Controller
{
    public function loginQr(Request $request)
    {
        $data = $request->validate([
            'qr_token' => ['required', 'string', 'max:64'],
        ]);

        $user = User::where('qr_auth_token', $data['qr_token'])->first();

        if (! $user || $user->status !== 'active') {
            throw ValidationException::withMessages([
                'qr_token' => ['Kartu tidak valid atau tidak aktif.'],
            ]);
        }

        if (in_array($user->role, ['admin'])) {
            throw ValidationException::withMessages([
                'qr_token' => ['Akun admin tidak bisa login melalui mobile.'],
            ]);
        }

        $user->update(['last_seen_at' => now()]);

        $tokenExpiry = Carbon::now()->addHours(8);

        $token = $user->createToken('mobile-' . $user->role, ['*'], $tokenExpiry);

        return response()->json([
            'token' => $token->plainTextToken,
            'expires_at' => $tokenExpiry->toISOString(),
            'user' => $user->load('assignedZone'),
        ]);
    }
}
