<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Shift;
use App\Models\User;
use App\Models\Zone;
use Illuminate\Http\Request;
use Inertia\Inertia;

class ShiftController extends Controller
{
    public function index()
    {
        $shifts = Shift::with(['zone', 'user'])->latest()->paginate(50);
        $zones = Zone::where('status', 'active')->orderBy('name')->get(['id', 'name', 'code']);
        $users = User::whereIn('role', ['jukir', 'supervisor'])
            ->where('status', 'active')
            ->orderBy('name')
            ->get(['id', 'name', 'role']);

        return Inertia::render('parkirgo/Shifts', [
            'shifts' => $shifts,
            'zones' => $zones,
            'users' => $users,
        ]);
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'zone_id' => ['required', 'exists:zones,id'],
            'user_id' => ['required', 'exists:users,id'],
            'shift_date' => ['required', 'date'],
            'start_time' => ['required', 'date_format:H:i'],
            'end_time' => ['required', 'date_format:H:i', 'after:start_time'],
            'status' => ['nullable', 'in:active,inactive'],
        ]);

        $date = $data['shift_date'];
        $code = 'SFT-' . strtoupper(Zone::find($data['zone_id'])->code) . '-' . date('ymd', strtotime($date)) . '-' . User::find($data['user_id'])->id;

        Shift::create([
            'code' => $code,
            'zone_id' => $data['zone_id'],
            'user_id' => $data['user_id'],
            'shift_date' => $date,
            'start_time' => $data['start_time'],
            'end_time' => $data['end_time'],
            'status' => $data['status'] ?? 'active',
        ]);

        return back()->with('success', 'Shift berhasil ditambahkan.');
    }

    public function update(Request $request, Shift $shift)
    {
        $data = $request->validate([
            'zone_id' => ['required', 'exists:zones,id'],
            'user_id' => ['required', 'exists:users,id'],
            'shift_date' => ['required', 'date'],
            'start_time' => ['required', 'date_format:H:i'],
            'end_time' => ['required', 'date_format:H:i', 'after:start_time'],
            'status' => ['required', 'in:active,inactive'],
        ]);

        $shift->update($data);

        return back()->with('success', 'Shift berhasil diperbarui.');
    }

    public function destroy(Shift $shift)
    {
        if ($shift->attendances()->exists() || $shift->settlements()->exists()) {
            return back()->with('error', 'Shift tidak bisa dihapus karena sudah ada absensi atau setoran.');
        }

        $shift->delete();

        return back()->with('success', 'Shift berhasil dihapus.');
    }
}
