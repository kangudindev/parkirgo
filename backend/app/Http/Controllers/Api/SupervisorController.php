<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Attendance;
use App\Models\Settlement;
use App\Models\Transaction;
use App\Models\User;
use Illuminate\Http\Request;

class SupervisorController extends Controller
{
    public function monitoring(Request $request)
    {
        $user = $request->user();
        $zoneId = $user->assigned_zone_id;

        $attendances = Attendance::with('user')
            ->where('zone_id', $zoneId)
            ->whereDate('created_at', today())
            ->latest()
            ->get();

        $jukirs = User::where('role', 'jukir')
            ->where('assigned_zone_id', $zoneId)
            ->get(['id', 'name', 'nik', 'status', 'last_seen_at', 'profile_photo_url']);

        $jukirStatus = $jukirs->map(fn ($jukir) => [
            'id' => $jukir->id,
            'name' => $jukir->name,
            'nik' => $jukir->nik,
            'photo' => $jukir->profile_photo_url,
            'status' => $jukir->status,
            'last_seen' => $jukir->last_seen_at,
            'has_attendance' => $attendances->where('user_id', $jukir->id)->isNotEmpty(),
            'attendance' => $attendances->where('user_id', $jukir->id)->first(),
        ]);

        return response()->json(['jukirs' => $jukirStatus]);
    }

    public function pendingQris(Request $request)
    {
        $transactions = Transaction::with(['zone', 'jukir', 'parkingSession'])
            ->where('payment_method', 'qris')
            ->where('status', 'recorded')
            ->latest()
            ->paginate(50);

        return response()->json(['transactions' => $transactions]);
    }

    public function verifyQris(Request $request)
    {
        $data = $request->validate([
            'transaction_id' => ['required', 'exists:transactions,id'],
            'action' => ['required', 'in:verify,reject'],
            'note' => ['nullable', 'string', 'max:255'],
        ]);

        $transaction = Transaction::findOrFail($data['transaction_id']);
        $transaction->update([
            'status' => $data['action'] === 'verify' ? 'verified' : 'rejected',
            'verified_by' => $request->user()->id,
            'verified_at' => now(),
            'verification_note' => $data['note'] ?? null,
        ]);

        return response()->json(['transaction' => $transaction->fresh()]);
    }

    public function pendingSettlements(Request $request)
    {
        $settlements = Settlement::with(['zone', 'jukir', 'shift'])
            ->where('status', 'submitted')
            ->latest()
            ->paginate(50);

        return response()->json(['settlements' => $settlements]);
    }

    public function approveSettlement(Request $request)
    {
        $data = $request->validate([
            'settlement_id' => ['required', 'exists:settlements,id'],
            'action' => ['required', 'in:approve,reject'],
            'note' => ['nullable', 'string', 'max:255'],
        ]);

        $settlement = Settlement::findOrFail($data['settlement_id']);
        $settlement->update([
            'status' => $data['action'] === 'approve' ? 'approved' : 'rejected',
            'approved_by' => $request->user()->id,
            'approved_at' => now(),
            'approval_note' => $data['note'] ?? null,
        ]);

        return response()->json(['settlement' => $settlement->fresh()]);
    }
}
