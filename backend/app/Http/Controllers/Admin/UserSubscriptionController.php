<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\SubscriptionPackage;
use App\Models\User;
use App\Models\UserSubscription;
use App\Models\UserWallet;
use Illuminate\Http\Request;
use Inertia\Inertia;

class UserSubscriptionController extends Controller
{
    use HasAdvancedFilter;

    public function index(Request $request)
    {
        $subscriptions = $this->applySort(
            $this->applySearch(UserSubscription::with(['user', 'package', 'vehicles']), $request, ['status']),
            $request,
            ['created_at', 'start_date', 'end_date', 'status']
        )->paginate($this->perPage($request));

        $packages = SubscriptionPackage::where('status', 'active')->with('vehicleType')->get();
        
        $users = User::where('role', 'customer')->orderBy('name')->get(['id', 'name', 'email']);
        
        $wallets = UserWallet::with('user')->paginate($this->perPage($request), ['*'], 'wallet_page');

        return Inertia::render('parkirgo/UserSubscriptions', [
            'subscriptions' => $subscriptions,
            'packages' => $packages,
            'users' => $users,
            'wallets' => $wallets,
        ]);
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'user_id' => ['nullable', 'exists:users,id'],
            'subscription_package_id' => ['required', 'exists:subscription_packages,id'],
            'vehicles' => ['nullable', 'array'],
            'vehicles.*.license_plate' => ['nullable', 'string', 'max:20'],
            'vehicles.*.label' => ['nullable', 'string', 'max:50'],
        ]);

        $package = SubscriptionPackage::findOrFail($data['subscription_package_id']);

        // Jika bertipe saldo/balance, lakukan top up wallet
        if ($package->type === 'balance') {
            if (empty($data['user_id'])) {
                return back()->with('error', 'Top Up Saldo memerlukan pilihan Pengguna (User).');
            }

            $wallet = UserWallet::firstOrCreate(
                ['user_id' => $data['user_id']],
                ['balance' => 0]
            );
            $wallet->increment('balance', $package->value ?? $package->price);

            return back()->with('success', 'Top Up Saldo berhasil ditambahkan.');
        }

        // Validasi kendaraan untuk pass dan quota
        if (empty($data['vehicles']) || count($data['vehicles']) === 0) {
            return back()->with('error', 'Pendaftaran langganan pass/kuota memerlukan minimal 1 kendaraan.');
        }

        if (count($data['vehicles']) > $package->max_vehicles) {
            return back()->with('error', "Maksimal kendaraan untuk paket ini adalah {$package->max_vehicles}.");
        }

        $sub = UserSubscription::create([
            'user_id' => $data['user_id'] ?? null,
            'subscription_package_id' => $package->id,
            'type' => $package->type === 'quota' ? 'quota' : 'pass',
            'value_remaining' => $package->type === 'quota' ? ($package->value ?? 0) : null,
            'start_date' => now()->toDateString(),
            'end_date' => now()->addDays($package->duration_days)->toDateString(),
            'status' => 'active',
        ]);

        foreach ($data['vehicles'] as $v) {
            if (!empty($v['license_plate'])) {
                $sub->vehicles()->create([
                    'license_plate' => strtoupper(preg_replace('/\s+/', '', $v['license_plate'])),
                    'label' => $v['label'] ?? null,
                ]);
            }
        }

        return back()->with('success', 'Langganan pelanggan berhasil diaktifkan.');
    }

    public function update(Request $request, UserSubscription $userSubscription)
    {
        $data = $request->validate([
            'status' => ['required', 'in:active,expired,used_up'],
            'value_remaining' => ['nullable', 'integer', 'min:0'],
        ]);

        $userSubscription->update($data);

        return back()->with('success', 'Langganan pelanggan berhasil diperbarui.');
    }

    public function destroy(UserSubscription $userSubscription)
    {
        $userSubscription->delete();

        return back()->with('success', 'Langganan pelanggan berhasil dihapus.');
    }
}
