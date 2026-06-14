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
use Illuminate\Support\Facades\DB;

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
                'settlements_today' => Settlement::whereBetween('created_at', [$today->startOfDay(), $today->endOfDay()])->count(),
            ];

            $zones = Zone::withCount(['parkingSessions as active_sessions_count' => fn ($query) => $query->where('status', 'active')])
                ->withSum(['transactions as revenue_sum' => fn ($query) => $query->whereBetween('created_at', [$today->startOfDay(), $today->endOfDay()])], 'amount')
                ->with('vehicleTypes')
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
                'settlements_today' => 0,
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

    public function reports(Request $request)
    {
        $dateFrom = $request->input('date_from', now()->startOfMonth()->toDateString());
        $dateTo = $request->input('date_to', now()->toDateString());

        try {
            $revenuePerUser = Transaction::select('jukir_id', DB::raw('SUM(amount) as total_amount'), DB::raw('COUNT(*) as transaction_count'))
                ->with('jukir:id,name')
                ->whereBetween('created_at', [$dateFrom.' 00:00:00', $dateTo.' 23:59:59'])
                ->groupBy('jukir_id')
                ->get()
                ->map(fn($item) => [
                    'jukir_id' => $item->jukir_id,
                    'jukir_name' => $item->jukir?->name ?? 'Unknown',
                    'total_amount' => (int) $item->total_amount,
                    'transaction_count' => $item->transaction_count,
                ])
                ->sortByDesc('total_amount')
                ->values();

            $settlementPerUser = Settlement::select('jukir_id', DB::raw('SUM(total_amount) as total_settlement'))
                ->whereBetween('created_at', [$dateFrom.' 00:00:00', $dateTo.' 23:59:59'])
                ->groupBy('jukir_id')
                ->get()
                ->keyBy('jukir_id');

            $revenuePerUser = $revenuePerUser->map(function($item) use ($settlementPerUser) {
                $item['total_settlement'] = (int) ($settlementPerUser[$item['jukir_id']]['total_settlement'] ?? 0);
                return $item;
            });

            $revenuePerShift = Settlement::with(['shift.user:id,name', 'shift.zone:id,name', 'jukir:id,name', 'zone:id,name'])
                ->whereBetween('created_at', [$dateFrom.' 00:00:00', $dateTo.' 23:59:59'])
                ->get()
                ->map(fn($item) => [
                    'id' => $item->id,
                    'settlement_number' => $item->settlement_number,
                    'shift_code' => $item->shift?->code,
                    'shift_date' => $item->shift?->shift_date?->toDateString(),
                    'jukir_name' => $item->jukir?->name ?? 'Unknown',
                    'zone_name' => $item->zone?->name ?? 'Unknown',
                    'cash_amount' => (int) $item->cash_amount,
                    'qris_amount' => (int) $item->qris_amount,
                    'total_amount' => (int) $item->total_amount,
                    'status' => $item->status,
                ])
                ->sortByDesc(fn($s) => $s['total_amount'])
                ->values();

            $revenuePerZone = Transaction::select('zone_id', DB::raw('SUM(amount) as total_amount'), DB::raw('COUNT(*) as transaction_count'))
                ->with('zone:id,name,code,city')
                ->whereBetween('created_at', [$dateFrom.' 00:00:00', $dateTo.' 23:59:59'])
                ->groupBy('zone_id')
                ->get()
                ->map(fn($item) => [
                    'zone_id' => $item->zone_id,
                    'zone_name' => $item->zone?->name ?? 'Unknown',
                    'zone_code' => $item->zone?->code ?? '',
                    'city' => $item->zone?->city ?? '',
                    'total_amount' => (int) $item->total_amount,
                    'transaction_count' => $item->transaction_count,
                ])
                ->sortByDesc('total_amount')
                ->values();

            $settlementPerZone = Settlement::select('zone_id', DB::raw('SUM(total_amount) as total_settlement'))
                ->whereBetween('created_at', [$dateFrom.' 00:00:00', $dateTo.' 23:59:59'])
                ->groupBy('zone_id')
                ->get()
                ->keyBy('zone_id');

            $revenuePerZone = $revenuePerZone->map(function($item) use ($settlementPerZone) {
                $item['total_settlement'] = (int) ($settlementPerZone[$item['zone_id']]['total_settlement'] ?? 0);
                return $item;
            });
        } catch (\Exception $e) {
            report($e);
            $revenuePerUser = collect();
            $revenuePerShift = collect();
            $revenuePerZone = collect();
        }

        return Inertia::render('parkirgo/Reports', [
            'revenuePerUser' => $revenuePerUser,
            'revenuePerShift' => $revenuePerShift,
            'revenuePerZone' => $revenuePerZone,
            'filters' => ['date_from' => $dateFrom, 'date_to' => $dateTo],
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
