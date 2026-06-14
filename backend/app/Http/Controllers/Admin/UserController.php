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
        return Inertia::render('parkirgo/Users', [
            'users' => $this->applySort(
                $this->applySearch(User::with('assignedZone'), $request, ['name', 'email', 'nik', 'phone', 'role']),
                $request,
                ['name', 'email', 'role', 'status', 'created_at']
            )->paginate($this->perPage($request)),
            'zones' => Zone::where('status', 'active')->orderBy('name')->get(['id', 'name', 'code']),
        ]);
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'name' => ['required', 'string', 'max:100'],
            'email' => ['required', 'email', 'max:100', 'unique:users,email'],
            'nik' => ['nullable', 'string', 'max:30', 'unique:users,nik'],
            'phone' => ['nullable', 'string', 'max:20'],
            'role' => ['required', 'in:admin,supervisor,jukir'],
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
            'role' => ['required', 'in:admin,supervisor,jukir'],
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

    public function destroy(User $user)
    {
        if ($user->parkingSessions()->exists() || $user->settlements()->exists()) {
            return back()->with('error', 'Pengguna tidak bisa dihapus karena masih memiliki data transaksi.');
        }

        $user->delete();

        return back()->with('success', 'Pengguna berhasil dihapus.');
    }
}
