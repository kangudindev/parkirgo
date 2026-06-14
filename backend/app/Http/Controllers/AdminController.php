<?php

namespace App\Http\Controllers;

use App\Http\Controllers\Admin\HasAdvancedFilter;
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
    use HasAdvancedFilter;

    public function dashboard(Request $request)
    {
        $period = $request->input('period', 'today');
        
        if ($period === 'custom' && $request->filled('date_from') && $request->filled('date_to')) {
            $dateFrom = $request->date_from . ' 00:00:00';
            $dateTo = $request->date_to . ' 23:59:59';
        } else {
            $dates = $this->getPeriodRange($period);
            $dateFrom = $dates['from'];
            $dateTo = $dates['to'];
        }

        try {
            $summary = [
                'revenue_period' => Transaction::whereBetween('created_at', [$dateFrom, $dateTo])->sum('amount'),
                'active_sessions' => ParkingSession::where('status', 'active')->count(),
                'zones_active' => Zone::where('status', 'active')->count(),
                'jukirs_online' => User::where('role', 'jukir')->where('status', 'active')->count(),
                'pending_qris' => Transaction::where('payment_method', 'qris')->where('status', 'recorded')->count(),
                'settlements_period' => Settlement::whereBetween('created_at', [$dateFrom, $dateTo])->count(),
            ];

            $zones = Zone::with('vehicleTypes')
                ->withCount(['jukirs'])
                ->withCount(['parkingSessions as parkir_out_count' => fn ($q) => $q->whereBetween('exit_at', [$dateFrom, $dateTo])])
                ->withCount(['parkingSessions as active_sessions_count' => fn ($q) => $q->where('status', 'active')])
                ->withSum(['transactions as revenue_sum' => fn ($q) => $q->whereBetween('created_at', [$dateFrom, $dateTo])], 'amount')
                ->latest()
                ->get();

            $zoneIds = $zones->pluck('id');
            
            // Per-type active count for gauges
            $activeByZoneType = ParkingSession::where('status', 'active')
                ->whereIn('zone_id', $zoneIds)
                ->groupBy('zone_id', 'vehicle_type_id')
                ->selectRaw('zone_id, vehicle_type_id, COUNT(*) as count')
                ->get()
                ->groupBy('zone_id');

            $zones->each(function ($zone) use ($activeByZoneType) {
                $typeCounts = $activeByZoneType->get($zone->id, collect())->keyBy('vehicle_type_id');
                $zone->vehicleTypes->each(function ($vt) use ($typeCounts) {
                    $vt->active_count = (int) ($typeCounts[$vt->id]['count'] ?? 0);
                });
            });

            // Multi-line Chart Data (Per Zone)
            $chartData = $this->prepareRevenueChartData($period, $zones);

            $recentSessions = ParkingSession::with(['zone', 'jukir', 'vehicleTypeMaster'])->latest()->limit(8)->get();
            $recentTransactions = Transaction::with(['zone', 'jukir', 'parkingSession'])->latest()->limit(8)->get();
        } catch (\Exception $e) {
            report($e);
            $summary = [
                'revenue_period' => 0,
                'active_sessions' => 0,
                'zones_active' => 0,
                'jukirs_online' => 0,
                'pending_qris' => 0,
                'settlements_period' => 0,
            ];
            $zones = collect();
            $chartData = ['labels' => [], 'series' => []];
            $recentSessions = collect();
            $recentTransactions = collect();
        }

        return Inertia::render('parkirgo/Dashboard', [
            'summary' => $summary,
            'zones' => $zones,
            'chartData' => $chartData,
            'recentSessions' => $recentSessions,
            'recentTransactions' => $recentTransactions,
            'period' => $period,
            'filters' => [
                'date_from' => $request->date_from,
                'date_to' => $request->date_to,
            ]
        ]);
    }

    private function prepareRevenueChartData(string $period, $zones): array
    {
        $dates = $this->getPeriodRange($period);
        $start = Carbon::parse($dates['from']);
        $end = Carbon::parse($dates['to']);

        $format = match ($period) {
            'today' => 'H:00',
            'week' => 'D',
            'month' => 'd M',
            'year' => 'M Y',
            default => 'Y-m-d'
        };

        $sqlFormat = match ($period) {
            'today' => '%H:00',
            'week' => '%a',
            'month' => '%d %b',
            'year' => '%b %Y',
            default => '%Y-%m-%d'
        };

        // Get all labels first to ensure continuity
        $labels = [];
        $current = $start->copy();
        while ($current <= $end) {
            $labels[] = $current->format($format);
            match ($period) {
                'today' => $current->addHour(),
                'week', 'month' => $current->addDay(),
                'year' => $current->addMonth(),
                default => $current->addDay()
            };
        }

        $series = [];
        foreach ($zones as $zone) {
            $data = Transaction::where('zone_id', $zone->id)
                ->whereBetween('created_at', [$dates['from'], $dates['to']])
                ->selectRaw("DATE_FORMAT(created_at, '$sqlFormat') as time_label")
                ->selectRaw("SUM(amount) as total")
                ->groupBy('time_label')
                ->pluck('total', 'time_label');

            $zoneSeries = [];
            foreach ($labels as $label) {
                $zoneSeries[] = (int) ($data[$label] ?? 0);
            }

            $series[] = [
                'name' => $zone->name,
                'data' => $zoneSeries
            ];
        }

        return [
            'labels' => $labels,
            'series' => $series
        ];
    }

    private function getPeriodRange(string $period): array
    {
        $now = now();
        return match ($period) {
            'today' => ['from' => $now->copy()->startOfDay()->toDateTimeString(), 'to' => $now->copy()->endOfDay()->toDateTimeString()],
            'yesterday' => ['from' => $now->copy()->subDay()->startOfDay()->toDateTimeString(), 'to' => $now->copy()->subDay()->endOfDay()->toDateTimeString()],
            'week' => ['from' => $now->copy()->subDays(6)->startOfDay()->toDateTimeString(), 'to' => $now->copy()->endOfDay()->toDateTimeString()],
            'month' => ['from' => $now->copy()->startOfMonth()->toDateTimeString(), 'to' => $now->copy()->endOfDay()->toDateTimeString()],
            'year' => ['from' => $now->copy()->startOfYear()->toDateTimeString(), 'to' => $now->copy()->endOfDay()->toDateTimeString()],
            default => ['from' => $now->copy()->startOfDay()->toDateTimeString(), 'to' => $now->copy()->endOfDay()->toDateTimeString()],
        };
    }

    public function operations(Request $request)
    {
        try {
            $query = ParkingSession::with(['zone', 'jukir', 'tariff.vehicleTypeMaster', 'vehicleTypeMaster']);

            if ($request->filled('zone_id')) {
                $query->where('zone_id', $request->zone_id);
            }

            if ($request->filled('vehicle_type_id')) {
                $query->where('vehicle_type_id', $request->vehicle_type_id);
            }

            if ($request->filled('date_from')) {
                $query->whereDate('entry_at', '>=', $request->date_from);
            }
            if ($request->filled('date_to')) {
                $query->whereDate('entry_at', '<=', $request->date_to);
            }

            $sessions = $this->applySort(
                $this->applySearch($query, $request, ['ticket_number', 'plate_number']),
                $request,
                ['created_at', 'ticket_number', 'plate_number', 'status', 'payment_status']
            )->paginate($this->perPage($request));

            $attendances = Attendance::with(['zone', 'user', 'shift'])
                ->latest()
                ->limit(10)
                ->get();

            $zones = Zone::where('status', 'active')->orderBy('name')->get(['id', 'name']);
            $vehicleTypes = \App\Models\VehicleType::where('status', 'active')->orderBy('sort_order')->get(['id', 'name']);
        } catch (\Exception $e) {
            report($e);
            $sessions = collect();
            $attendances = collect();
            $zones = collect();
            $vehicleTypes = collect();
        }

        return Inertia::render('parkirgo/Operations', [
            'sessions' => $sessions,
            'attendances' => $attendances,
            'zones' => $zones,
            'vehicleTypes' => $vehicleTypes,
            'filters' => [
                'zone_id' => $request->zone_id,
                'vehicle_type_id' => $request->vehicle_type_id,
                'date_from' => $request->date_from,
                'date_to' => $request->date_to,
            ]
        ]);
    }

    public function finance(Request $request)
    {
        try {
            $transactions = $this->applySort(
                $this->applySearch(Transaction::with(['zone', 'jukir', 'parkingSession']), $request, ['transaction_number', 'payment_method', 'status']),
                $request,
                ['created_at', 'transaction_number', 'amount', 'payment_method', 'status']
            )->paginate($this->perPage($request));

            $settlements = $this->applySort(
                $this->applySearch(Settlement::with(['zone', 'jukir', 'shift']), $request, ['settlement_number']),
                $request,
                ['created_at', 'settlement_number', 'total_amount', 'status']
            )->paginate($this->perPage($request));
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

    public function audit(Request $request)
    {
        try {
            $logs = $this->applySort(
                $this->applySearch(AuditLog::with('user'), $request, ['action', 'entity_type', 'ip_address']),
                $request,
                ['created_at', 'action', 'entity_type', 'entity_id']
            )->paginate($this->perPage($request));
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

    public function attendances(Request $request)
    {
        try {
            $query = Attendance::with(['user', 'zone', 'shift']);

            if ($request->filled('date_from')) {
                $query->whereDate('created_at', '>=', $request->date_from);
            }
            if ($request->filled('date_to')) {
                $query->whereDate('created_at', '<=', $request->date_to);
            }

            $attendances = $this->applySort(
                $this->applySearch($query, $request, ['user.name', 'zone.name', 'shift.code']),
                $request,
                ['created_at', 'check_in_at', 'check_out_at', 'sync_status']
            )->paginate($this->perPage($request));

            $zones = Zone::where('status', 'active')->orderBy('name')->get(['id', 'name']);
        } catch (\Exception $e) {
            report($e);
            $attendances = collect();
            $zones = collect();
        }

        return Inertia::render('parkirgo/Attendances', [
            'attendances' => $attendances,
            'zones' => $zones,
            'filters' => [
                'date_from' => $request->date_from,
                'date_to' => $request->date_to,
            ],
            'sortField' => $request->sort_field ?? 'created_at',
            'sortDir' => $request->sort_dir ?? 'desc',
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
