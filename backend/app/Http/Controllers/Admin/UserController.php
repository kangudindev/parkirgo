<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Models\Zone;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Inertia\Inertia;

class UserController extends Controller
{
    use HasAdvancedFilter;

    public function index(Request $request)
    {
        $tab = $request->input('tab', 'staff');

        $query = User::query();
        if ($tab === 'customer') {
            $query->where('role', 'customer');
        } else {
            $query->whereIn('role', ['admin', 'supervisor', 'jukir'])->with('assignedZone');
        }

        return Inertia::render('parkirgo/Users', [
            'users' => $this->applySort(
                $this->applySearch($query, $request, ['name', 'email', 'nik', 'phone', 'role']),
                $request,
                ['name', 'email', 'role', 'status', 'created_at']
            )->paginate($this->perPage($request)),
            'zones' => Zone::where('status', 'active')->orderBy('name')->get(['id', 'name', 'code']),
            'currentTab' => $tab,
        ]);
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'name' => ['required', 'string', 'max:100'],
            'email' => ['required', 'email', 'max:100', 'unique:users,email'],
            'nik' => ['nullable', 'string', 'max:30', 'unique:users,nik'],
            'phone' => ['nullable', 'string', 'max:20'],
            'role' => ['required', 'in:admin,supervisor,jukir,customer'],
            'status' => ['required', 'in:active,inactive'],
            'assigned_zone_id' => ['nullable', 'exists:zones,id'],
            'password' => ['required', 'string', 'min:6'],
        ]);

        User::create([
            'name' => $data['name'],
            'email' => $data['email'],
            'nik' => $data['nik'] ?? null,
            'phone' => $data['phone'] ?? null,
            'role' => $data['role'],
            'status' => $data['status'],
            'assigned_zone_id' => $data['assigned_zone_id'] ?? null,
            'password' => Hash::make($data['password']),
            'email_verified_at' => now(),
        ]);

        return back()->with('success', 'Pengguna berhasil ditambahkan.');
    }

    public function update(Request $request, User $user)
    {
        $data = $request->validate([
            'name' => ['required', 'string', 'max:100'],
            'email' => ['required', 'email', 'max:100', 'unique:users,email,' . $user->id],
            'nik' => ['nullable', 'string', 'max:30', 'unique:users,nik,' . $user->id],
            'phone' => ['nullable', 'string', 'max:20'],
            'role' => ['required', 'in:admin,supervisor,jukir,customer'],
            'status' => ['required', 'in:active,inactive'],
            'assigned_zone_id' => ['nullable', 'exists:zones,id'],
            'password' => ['nullable', 'string', 'min:6'],
        ]);

        $payload = array_merge($data, [
            'password' => $data['password'] ? Hash::make($data['password']) : $user->password,
        ]);

        $user->update($payload);

        return back()->with('success', 'Pengguna berhasil diperbarui.');
    }

    public function show(User $user)
    {
        if ($user->role === 'jukir') {
            $user->load(['assignedZone']);
            
            // Ambil histori shift terbaru
            $shifts = \App\Models\Shift::where('user_id', $user->id)
                ->with(['zone', 'settlement'])
                ->orderBy('shift_date', 'desc')
                ->orderBy('start_time', 'desc')
                ->take(10)
                ->get();
                
            // Ambil histori absensi terbaru
            $attendance = \App\Models\Attendance::where('user_id', $user->id)
                ->with(['zone'])
                ->orderBy('check_in_at', 'desc')
                ->take(10)
                ->get();

            return Inertia::render('parkirgo/UserDetail', [
                'user' => $user,
                'shifts' => $shifts,
                'attendance' => $attendance,
            ]);
        }

        if ($user->role === 'customer') {
            $user->load([
                'wallet', 
                'userSubscriptions' => function($q) {
                    $q->with(['package', 'vehicles'])->orderBy('created_at', 'desc');
                }
            ]);

            // Ambil histori parkir berdasarkan kendaraan terdaftar pelanggan
            $plates = \App\Models\SubscriptionVehicle::whereHas('userSubscription', function($q) use ($user) {
                $q->where('user_id', $user->id);
            })->pluck('license_plate')->toArray();
            
            $parkingHistory = [];
            if (!empty($plates)) {
                $parkingHistory = \App\Models\ParkingSession::whereIn('plate_number', $plates)
                    ->with(['zone', 'vehicleType'])
                    ->orderBy('entry_at', 'desc')
                    ->take(10)
                    ->get();
            }

            return Inertia::render('parkirgo/UserDetail', [
                'user' => $user,
                'parkingHistory' => $parkingHistory,
            ]);
        }

        // Fallback untuk admin / supervisor
        return Inertia::render('parkirgo/UserDetail', [
            'user' => $user,
        ]);
    }

    public function destroy(User $user)
    {
        if ($user->parkingSessions()->exists() || $user->settlements()->exists()) {
            return back()->with('error', 'Pengguna tidak bisa dihapus karena masih memiliki data transaksi.');
        }

        $user->delete();

        return back()->with('success', 'Pengguna berhasil dihapus.');
    }
}
