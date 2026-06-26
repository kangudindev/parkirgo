<?php

namespace Database\Seeders;

use App\Models\SubscriptionPackage;
use App\Models\SubscriptionVehicle;
use App\Models\User;
use App\Models\UserSubscription;
use App\Models\UserWallet;
use App\Models\VehicleType;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class SubscriptionSeeder extends Seeder
{
    public function run(): void
    {
        // 1. Dapatkan jenis kendaraan
        $motor = VehicleType::where('code', 'motor')->first();
        $mobil = VehicleType::where('code', 'mobil')->first();

        if (!$motor || !$mobil) {
            return;
        }

        // 2. Buat Paket Langganan Default
        $pkgPassMotor = SubscriptionPackage::updateOrCreate(
            ['name' => 'Monthly Pass Motor (Single)'],
            [
                'type' => 'pass',
                'price' => 50000.00,
                'duration_days' => 30,
                'max_vehicles' => 1,
                'vehicle_type_id' => $motor->id,
                'status' => 'active',
                'description' => 'Bebas parkir motor sepuasnya selama 30 hari untuk 1 kendaraan.',
            ]
        );

        $pkgPassMobilSingle = SubscriptionPackage::updateOrCreate(
            ['name' => 'Monthly Pass Mobil (Single)'],
            [
                'type' => 'pass',
                'price' => 150000.00,
                'duration_days' => 30,
                'max_vehicles' => 1,
                'vehicle_type_id' => $mobil->id,
                'status' => 'active',
                'description' => 'Bebas parkir mobil sepuasnya selama 30 hari untuk 1 kendaraan.',
            ]
        );

        $pkgPassMobilMulti = SubscriptionPackage::updateOrCreate(
            ['name' => 'Monthly Pass Mobil (Multi-Slot)'],
            [
                'type' => 'pass',
                'price' => 250000.00,
                'duration_days' => 30,
                'max_vehicles' => 2,
                'vehicle_type_id' => $mobil->id,
                'status' => 'active',
                'description' => 'Bebas parkir mobil sepuasnya selama 30 hari untuk maksimal 2 kendaraan terdaftar.',
            ]
        );

        $pkgQuotaMobil = SubscriptionPackage::updateOrCreate(
            ['name' => 'Paket 15x Sesi Mobil'],
            [
                'type' => 'quota',
                'price' => 60000.00,
                'duration_days' => 30,
                'max_vehicles' => 1,
                'value' => 15,
                'vehicle_type_id' => $mobil->id,
                'status' => 'active',
                'description' => 'Paket hemat parkir mobil sebanyak 15 kali sesi dalam masa aktif 30 hari.',
            ]
        );

        $pkgTopup50 = SubscriptionPackage::updateOrCreate(
            ['name' => 'Top Up Saldo Rp 50.000'],
            [
                'type' => 'balance',
                'price' => 50000.00,
                'duration_days' => 365,
                'max_vehicles' => 1,
                'value' => 50000.00,
                'vehicle_type_id' => $mobil->id,
                'status' => 'active',
                'description' => 'Isi ulang saldo dompet prabayar ParkirGo sebesar Rp 50.000.',
            ]
        );

        // 3. Buat Akun Contoh Customer (Pengendara)
        $cust1 = User::updateOrCreate(
            ['email' => 'ahmad@parkirgo.test'],
            [
                'name' => 'Ahmad Pengendara',
                'password' => Hash::make('password'),
                'role' => 'customer',
                'phone' => '081222222222',
                'status' => 'active',
                'email_verified_at' => now(),
            ]
        );

        $cust2 = User::updateOrCreate(
            ['email' => 'siti@parkirgo.test'],
            [
                'name' => 'Siti Pengendara',
                'password' => Hash::make('password'),
                'role' => 'customer',
                'phone' => '081233333333',
                'status' => 'active',
                'email_verified_at' => now(),
            ]
        );

        // 4. Buat Saldo Dompet (UserWallet) untuk Ahmad
        UserWallet::updateOrCreate(
            ['user_id' => $cust1->id],
            ['balance' => 75000.00]
        );

        // 5. Buat Langganan Unlimited Pass untuk Ahmad (Mobil B 1234 ABC)
        $sub1 = UserSubscription::create([
            'user_id' => $cust1->id,
            'subscription_package_id' => $pkgPassMobilSingle->id,
            'type' => 'pass',
            'start_date' => now()->toDateString(),
            'end_date' => now()->addDays(30)->toDateString(),
            'status' => 'active',
        ]);

        SubscriptionVehicle::create([
            'user_subscription_id' => $sub1->id,
            'license_plate' => 'B1234ABC',
            'label' => 'Mobil Utama Ahmad',
        ]);

        // 6. Buat Langganan Kuota untuk Siti (Mobil B 5678 XYZ, Sisa Kuota 12)
        $sub2 = UserSubscription::create([
            'user_id' => $cust2->id,
            'subscription_package_id' => $pkgQuotaMobil->id,
            'type' => 'quota',
            'value_remaining' => 12,
            'start_date' => now()->toDateString(),
            'end_date' => now()->addDays(30)->toDateString(),
            'status' => 'active',
        ]);

        SubscriptionVehicle::create([
            'user_subscription_id' => $sub2->id,
            'license_plate' => 'B5678XYZ',
            'label' => 'Mobil Siti',
        ]);
    }
}
