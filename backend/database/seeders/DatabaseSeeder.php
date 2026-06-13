<?php

namespace Database\Seeders;

use App\Models\ParkingSession;
use App\Models\Settlement;
use App\Models\Shift;
use App\Models\Transaction;
use App\Models\User;
use App\Models\VehicleType;
use App\Models\Zone;
use App\Models\ZoneTariff;
use Illuminate\Database\Seeder;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\Hash;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        $admin = User::updateOrCreate(
            ['email' => 'admin@parkirgo.test'],
            [
                'name' => 'Admin ParkirGo',
                'password' => Hash::make('password'),
                'role' => 'admin',
                'status' => 'active',
                'qr_auth_token' => null,
                'email_verified_at' => now(),
            ]
        );

        $zone = Zone::updateOrCreate(
            ['code' => 'ZONA-MONAS'],
            [
                'name' => 'Zona Monas Timur',
                'city' => 'Jakarta Pusat',
                'capacity_motor' => 120,
                'capacity_car' => 48,
                'qris_payload' => '00020101021126680016ID.CO.PARKIRGO0112ZONA-MONAS5204599953033605802ID5911ParkirGo6007Jakarta6304DEMO',
                'status' => 'active',
            ]
        );

        $jukir = User::updateOrCreate(
            ['email' => 'jukir@parkirgo.test'],
            [
                'name' => 'Budi Jukir',
                'password' => Hash::make('password'),
                'role' => 'jukir',
                'nik' => '3173000000000001',
                'phone' => '081234567890',
                'status' => 'active',
                'assigned_zone_id' => $zone->id,
                'qr_auth_token' => 'QR-' . strtoupper(bin2hex(random_bytes(12))),
                'email_verified_at' => now(),
                'last_seen_at' => now()->subMinutes(8),
            ]
        );

        $motor = VehicleType::updateOrCreate(
            ['code' => 'motor'],
            [
                'name' => 'Motor',
                'icon' => 'ri-motorbike-line',
                'sort_order' => 10,
                'status' => 'active',
            ]
        );

        $mobil = VehicleType::updateOrCreate(
            ['code' => 'mobil'],
            [
                'name' => 'Mobil',
                'icon' => 'ri-car-line',
                'sort_order' => 20,
                'status' => 'active',
            ]
        );

        VehicleType::updateOrCreate(
            ['code' => 'truk'],
            [
                'name' => 'Truk',
                'icon' => 'ri-truck-line',
                'sort_order' => 30,
                'status' => 'active',
            ]
        );

        $flatMotor = ZoneTariff::updateOrCreate(
            ['zone_id' => $zone->id, 'vehicle_type_id' => $motor->id, 'pricing_type' => ZoneTariff::TYPE_FLAT],
            [
                'vehicle_type' => $motor->code,
                'payment_timing' => ZoneTariff::PAYMENT_ENTRY,
                'base_minutes' => 60,
                'base_rate' => 3000,
                'status' => 'active',
            ]
        );

        $progressiveCar = ZoneTariff::updateOrCreate(
            ['zone_id' => $zone->id, 'vehicle_type_id' => $mobil->id, 'pricing_type' => ZoneTariff::TYPE_PROGRESSIVE],
            [
                'vehicle_type' => $mobil->code,
                'payment_timing' => ZoneTariff::PAYMENT_EXIT,
                'base_minutes' => 60,
                'base_rate' => 5000,
                'increment_minutes' => 60,
                'increment_rate' => 4000,
                'daily_max_rate' => 45000,
                'status' => 'active',
            ]
        );

        $shift = Shift::updateOrCreate(
            ['code' => 'SHIFT-MONAS-PAGI'],
            [
                'zone_id' => $zone->id,
                'user_id' => $jukir->id,
                'shift_date' => Carbon::today(),
                'start_time' => '07:00:00',
                'end_time' => '15:00:00',
                'status' => 'active',
            ]
        );

        ParkingSession::updateOrCreate(
            ['ticket_number' => 'TMR-' . now()->format('ymd') . '-0001'],
            [
                'zone_id' => $zone->id,
                'tariff_id' => $flatMotor->id,
                'jukir_id' => $jukir->id,
                'plate_number' => 'B 1234 PGO',
                'vehicle_type_id' => $motor->id,
                'vehicle_type' => $motor->code,
                'entry_at' => now()->subMinutes(32),
                'estimated_amount' => 3000,
                'final_amount' => 3000,
                'status' => 'active',
                'payment_status' => 'paid',
            ]
        );

        $session = ParkingSession::updateOrCreate(
            ['ticket_number' => 'TMR-' . now()->format('ymd') . '-0002'],
            [
                'zone_id' => $zone->id,
                'tariff_id' => $progressiveCar->id,
                'jukir_id' => $jukir->id,
                'plate_number' => 'B 9876 GO',
                'vehicle_type_id' => $mobil->id,
                'vehicle_type' => $mobil->code,
                'entry_at' => now()->subHours(2),
                'estimated_amount' => 9000,
                'status' => 'active',
                'payment_status' => 'unpaid',
            ]
        );

        Transaction::updateOrCreate(
            ['transaction_number' => 'TRX-' . now()->format('Ymd') . '-0001'],
            [
                'parking_session_id' => $session->id,
                'zone_id' => $zone->id,
                'jukir_id' => $jukir->id,
                'payment_method' => 'qris',
                'amount' => 9000,
                'status' => 'recorded',
                'qris_payload' => $zone->qris_payload,
            ]
        );

        Settlement::updateOrCreate(
            ['settlement_number' => 'SET-' . now()->format('Ymd') . '-0001'],
            [
                'shift_id' => $shift->id,
                'zone_id' => $zone->id,
                'jukir_id' => $jukir->id,
                'settlement_date' => Carbon::today(),
                'cash_amount' => 3000,
                'qris_amount' => 9000,
                'total_amount' => 12000,
                'status' => 'submitted',
            ]
        );

        $admin->auditLogs()->create([
            'action' => 'seeded',
            'entity_type' => 'database',
            'new_values' => ['message' => 'ParkirGo demo data initialized'],
        ]);
    }
}
