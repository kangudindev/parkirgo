<?php

namespace App\Http\Controllers;

use App\Models\Attendance;
use App\Models\AuditLog;
use App\Models\ParkingSession;
use App\Models\Settlement;
use App\Models\Transaction;
use App\Models\User;
use App\Models\Zone;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\Cache;
use Illuminate\Http\Request;
use Inertia\Inertia;

class AdminController extends Controller
{
    public function dashboard()
    {
        $today = Carbon::today();

        try {
            $summary = [
                'revenue_today' => Transaction::whereBetween('created_at', [$today->startOfDay(), $today->endOfDay()])->sum('amount'),
                'active_sessions' => ParkingSession::where('status', 'active')->count(),
                'zones_active' => Zone::where('status', 'active')->count(),
                'jukirs_online' => User::where('role', 'jukir')->where('status', 'active')->count(),
                'pending_qris' => Transaction::where('payment_method', 'qris')->where('status', 'recorded')->count(),
                'pending_settlements' => Settlement::where('status', 'submitted')->count(),
            ];

            $zones = Zone::withCount(['parkingSessions as active_sessions_count' => fn ($query) => $query->where('status', 'active')])
                ->withSum(['transactions as revenue_sum' => fn ($query) => $query->whereBetween('created_at', [$today->startOfDay(), $today->endOfDay()])], 'amount')
                ->latest()
                ->get();

            $recentSessions = ParkingSession::with(['zone', 'jukir', 'vehicleTypeMaster'])->latest()->limit(8)->get();
            $recentTransactions = Transaction::with(['zone', 'jukir', 'parkingSession'])->latest()->limit(8)->get();
        } catch (\Exception $e) {
            report($e);
            $summary = [
                'revenue_today' => 0,
                'active_sessions' => 0,
                'zones_active' => 0,
                'jukirs_online' => 0,
                'pending_qris' => 0,
                'pending_settlements' => 0,
            ];
            $zones = collect();
            $recentSessions = collect();
            $recentTransactions = collect();
        }

        return Inertia::render('parkirgo/Dashboard', [
            'summary' => $summary,
            'zones' => $zones,
            'recentSessions' => $recentSessions,
            'recentTransactions' => $recentTransactions,
        ]);
    }

    public function operations()
    {
        try {
            $sessions = ParkingSession::with(['zone', 'jukir', 'tariff', 'vehicleTypeMaster'])
                ->latest()
                ->limit(30)
                ->get();

            $attendances = Attendance::with(['zone', 'user', 'shift'])
                ->latest()
                ->limit(20)
                ->get();
        } catch (\Exception $e) {
            report($e);
            $sessions = collect();
            $attendances = collect();
        }

        return Inertia::render('parkirgo/Operations', [
            'sessions' => $sessions,
            'attendances' => $attendances,
        ]);
    }

    public function finance()
    {
        try {
            $transactions = Transaction::with(['zone', 'jukir', 'parkingSession'])
                ->latest()
                ->limit(30)
                ->get();

            $settlements = Settlement::with(['zone', 'jukir', 'shift'])
                ->latest()
                ->limit(20)
                ->get();
        } catch (\Exception $e) {
            report($e);
            $transactions = collect();
            $settlements = collect();
        }

        return Inertia::render('parkirgo/Finance', [
            'transactions' => $transactions,
            'settlements' => $settlements,
        ]);
    }

    public function audit()
    {
        try {
            $logs = AuditLog::with('user')
                ->latest()
                ->paginate(50);
        } catch (\Exception $e) {
            report($e);
            $logs = new \stdClass();
            $logs->data = [];
            $logs->total = 0;
            $logs->links = '';
        }

        return Inertia::render('parkirgo/Audit', [
            'logs' => $logs,
        ]);
    }

    public function generateQrToken(Request $request, User $user)
    {
        if (in_array($user->role, ['admin'])) {
            return back()->with('error', 'Akun admin tidak memerlukan QR ID Card.');
        }

        $user->update([
            'qr_auth_token' => 'QR-' . strtoupper(bin2hex(random_bytes(12))),
        ]);

        AuditLog::create([
            'user_id' => $request->user()->id,
            'action' => $user->wasRecentlyCreated ? 'created' : 'regenerated',
            'entity_type' => 'qr_auth_token',
            'entity_id' => $user->id,
            'new_values' => ['qr_auth_token' => $user->qr_auth_token],
        ]);

        return back()->with('success', "QR ID Card untuk {$user->name} berhasil di-generate.");
    }

    public function revokeQrToken(Request $request, User $user)
    {
        $user->update(['qr_auth_token' => null]);

        AuditLog::create([
            'user_id' => $request->user()->id,
            'action' => 'revoked',
            'entity_type' => 'qr_auth_token',
            'entity_id' => $user->id,
            'old_values' => ['qr_auth_token' => $user->qr_auth_token],
        ]);

        return back()->with('success', "QR ID Card untuk {$user->name} berhasil dicabut.");
    }
}
