<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Zone;
use App\Models\ZonePenalty;
use Illuminate\Http\Request;
use Inertia\Inertia;

class PenaltyController extends Controller
{
    public function index()
    {
        $penalties = ZonePenalty::with('zone')->latest()->get();
        $zones = Zone::where('status', 'active')->get(['id', 'name', 'code']);

        return Inertia::render('parkirgo/Penalties', [
            'penalties' => $penalties,
            'zones' => $zones,
        ]);
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'zone_id' => ['required', 'exists:zones,id'],
            'vehicle_type' => ['nullable', 'string', 'max:30'],
            'penalty_type' => ['required', 'in:card_lost,unregistered'],
            'amount' => ['required', 'integer', 'min:0'],
        ]);

        ZonePenalty::updateOrCreate(
            [
                'zone_id' => $data['zone_id'],
                'vehicle_type' => $data['vehicle_type'] ?? null,
                'penalty_type' => $data['penalty_type'],
            ],
            [
                'amount' => $data['amount'],
                'status' => 'active',
            ]
        );

        return back()->with('success', 'Denda berhasil disimpan.');
    }

    public function update(Request $request, ZonePenalty $penalty)
    {
        $data = $request->validate([
            'amount' => ['required', 'integer', 'min:0'],
            'vehicle_type' => ['nullable', 'string', 'max:30'],
            'penalty_type' => ['nullable', 'in:card_lost,unregistered'],
            'zone_id' => ['nullable', 'exists:zones,id'],
            'status' => ['nullable', 'in:active,inactive'],
        ]);

        $penalty->update($data);

        return back()->with('success', 'Denda berhasil diperbarui.');
    }

    public function destroy(ZonePenalty $penalty)
    {
        $penalty->delete();

        return back()->with('success', 'Denda berhasil dihapus.');
    }
}
