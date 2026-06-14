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

        // Define Vehicle Types First
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

        $truk = VehicleType::updateOrCreate(
            ['code' => 'truk'],
            [
                'name' => 'Truk',
                'icon' => 'ri-truck-line',
                'sort_order' => 30,
                'status' => 'active',
            ]
        );

        // Create Main Zone
        $zone = Zone::updateOrCreate(
            ['code' => 'ZONA-MONAS'],
            [
                'name' => 'Zona Monas Timur',
                'city' => 'Jakarta Pusat',
                'center_lat' => -6.175110,
                'center_lng' => 106.827153,
                'radius_meters' => 150,
                'qris_payload' => '00020101021126680016ID.CO.PARKIRGO0112ZONA-MONAS5204599953033605802ID5911ParkirGo6007Jakarta6304DEMO',
                'status' => 'active',
            ]
        );

        $zone->vehicleTypes()->sync([
            $motor->id => ['capacity' => 120],
            $mobil->id => ['capacity' => 48],
            $truk->id => ['capacity' => 10],
        ]);

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

        // Tariffs
        $flatMotor = ZoneTariff::updateOrCreate(
            ['zone_id' => $zone->id, 'vehicle_type_id' => $motor->id, 'pricing_type' => ZoneTariff::TYPE_FLAT],
            [
                'payment_timing' => ZoneTariff::PAYMENT_ENTRY,
                'base_minutes' => 60,
                'base_rate' => 3000,
                'status' => 'active',
            ]
        );

        $progressiveCar = ZoneTariff::updateOrCreate(
            ['zone_id' => $zone->id, 'vehicle_type_id' => $mobil->id, 'pricing_type' => ZoneTariff::TYPE_PROGRESSIVE],
            [
                'payment_timing' => ZoneTariff::PAYMENT_EXIT,
                'base_minutes' => 60,
                'base_rate' => 5000,
                'increment_minutes' => 60,
                'increment_rate' => 4000,
                'daily_max_rate' => 45000,
                'status' => 'active',
            ]
        );

        ZoneTariff::updateOrCreate(
            ['zone_id' => $zone->id, 'vehicle_type_id' => $truk->id, 'pricing_type' => ZoneTariff::TYPE_FLAT],
            [
                'payment_timing' => ZoneTariff::PAYMENT_ENTRY,
                'base_minutes' => 60,
                'base_rate' => 10000,
                'status' => 'active',
            ]
        );

        // Additional Zones with Coordinates
        $zonesData = [
            ['code' => 'ZONA-BLOK-M',       'name' => 'Blok M Square',           'city' => 'Jakarta Selatan', 'lat' => -6.244187, 'lng' => 106.798783, 'rad' => 200],
            ['code' => 'ZONA-KOTA-TUA',     'name' => 'Kota Tua Fatahillah',     'city' => 'Jakarta Barat',   'lat' => -6.135769, 'lng' => 106.814038, 'rad' => 200],
            ['code' => 'ZONA-KELAPA-GADING','name' => 'Boulevard Gading',        'city' => 'Jakarta Utara',   'lat' => -6.159539, 'lng' => 106.908660, 'rad' => 150],
            ['code' => 'ZONA-PASAR-BARU',   'name' => 'Pasar Baru Area',         'city' => 'Jakarta Pusat',   'lat' => -6.160468, 'lng' => 106.832977, 'rad' => 150],
            ['code' => 'ZONA-TEBET',        'name' => 'Tebet Eco Park',          'city' => 'Jakarta Selatan', 'lat' => -6.226809, 'lng' => 106.855305, 'rad' => 150],
        ];

        $createdZones = [$zone];
        foreach ($zonesData as $zData) {
            $newZone = Zone::updateOrCreate(['code' => $zData['code']], [
                'name' => $zData['name'],
                'city' => $zData['city'],
                'center_lat' => $zData['lat'],
                'center_lng' => $zData['lng'],
                'radius_meters' => $zData['rad'],
                'status' => 'active',
            ]);
            
            $newZone->vehicleTypes()->sync([
                $motor->id => ['capacity' => rand(100, 300)],
                $mobil->id => ['capacity' => rand(20, 100)],
                $truk->id => ['capacity' => rand(5, 20)],
            ]);

            // Add standard tariffs for each zone
            ZoneTariff::updateOrCreate(
                ['zone_id' => $newZone->id, 'vehicle_type_id' => $motor->id, 'pricing_type' => ZoneTariff::TYPE_FLAT],
                ['payment_timing' => ZoneTariff::PAYMENT_ENTRY, 'base_rate' => 3000, 'status' => 'active']
            );
            ZoneTariff::updateOrCreate(
                ['zone_id' => $newZone->id, 'vehicle_type_id' => $mobil->id, 'pricing_type' => ZoneTariff::TYPE_PROGRESSIVE],
                ['payment_timing' => ZoneTariff::PAYMENT_EXIT, 'base_rate' => 5000, 'increment_minutes' => 60, 'increment_rate' => 4000, 'status' => 'active']
            );

            // Add Penalties for each zone
            \App\Models\ZonePenalty::updateOrCreate(
                ['zone_id' => $newZone->id, 'penalty_type' => 'card_lost', 'vehicle_type' => 'motor'],
                ['amount' => 50000, 'status' => 'active']
            );
            \App\Models\ZonePenalty::updateOrCreate(
                ['zone_id' => $newZone->id, 'penalty_type' => 'card_lost', 'vehicle_type' => 'mobil'],
                ['amount' => 100000, 'status' => 'active']
            );

            $createdZones[] = $newZone;
        }

        // Add more jukirs
        $jukirNames = ['Agus', 'Slamet', 'Iwan', 'Dedi', 'Roni', 'Heri', 'Mulyadi', 'Toto'];
        $createdJukirs = [$jukir];
        foreach ($jukirNames as $index => $name) {
            $createdJukirs[] = User::updateOrCreate(
                ['email' => strtolower($name) . '@parkirgo.test'],
                [
                    'name' => $name . ' Jukir',
                    'password' => Hash::make('password'),
                    'role' => 'jukir',
                    'nik' => '3173' . str_pad($index + 2, 12, '0', STR_PAD_LEFT),
                    'phone' => '08' . str_pad(rand(1000000000, 9999999999), 10, '0', STR_PAD_LEFT),
                    'status' => 'active',
                    'assigned_zone_id' => $createdZones[$index % count($createdZones)]->id,
                    'qr_auth_token' => 'QR-' . strtoupper(bin2hex(random_bytes(12))),
                    'email_verified_at' => now(),
                    'last_seen_at' => now()->subMinutes(rand(1, 120)),
                ]
            );
        }

        // Create historical data
        foreach ($createdZones as $z) {
            $jukirInZone = User::where('assigned_zone_id', $z->id)->first() ?? $jukir;
            
            for ($i = 7; $i >= 0; $i--) {
                $date = Carbon::today()->subDays($i);
                
                $dailyShift = Shift::updateOrCreate(
                    ['code' => 'SHIFT-' . $z->code . '-' . $date->format('Ymd')],
                    [
                        'zone_id' => $z->id,
                        'user_id' => $jukirInZone->id,
                        'shift_date' => $date,
                        'start_time' => '07:00:00',
                        'end_time' => '15:00:00',
                        'status' => $i == 0 ? 'active' : 'completed',
                    ]
                );

                // Create Attendance for each shift
                \App\Models\Attendance::create([
                    'shift_id' => $dailyShift->id,
                    'zone_id' => $z->id,
                    'user_id' => $jukirInZone->id,
                    'check_in_at' => $date->copy()->setTime(6, 50 + rand(0, 15)),
                    'check_out_at' => $i == 0 ? null : $date->copy()->setTime(15, 0 + rand(0, 20)),
                    'check_in_latitude' => $z->center_lat + (rand(-100, 100) / 1000000),
                    'check_in_longitude' => $z->center_lng + (rand(-100, 100) / 1000000),
                    'sync_status' => 'synced',
                ]);

                $dailyCash = 0;
                $dailyQris = 0;

                $sessionCount = rand(15, 40);
                for ($j = 1; $j <= $sessionCount; $j++) {
                    $vType = rand(0, 10) > 2 ? (rand(0, 1) == 0 ? $motor : $mobil) : $truk;
                    $tariff = ZoneTariff::where('zone_id', $z->id)->where('vehicle_type_id', $vType->id)->first() ?? $flatMotor;
                    
                    $entryTime = $date->copy()->setTime(rand(7, 14), rand(0, 59));
                    $isCompleted = $i > 0 || rand(0, 1) == 1;
                    $exitTime = $isCompleted ? $entryTime->copy()->addMinutes(rand(30, 300)) : null;
                    
                    $amount = $vType->code == 'motor' ? 3000 : 5000;
                    if ($vType->code == 'mobil' && $exitTime) {
                        $hours = max(1, ceil($exitTime->diffInMinutes($entryTime) / 60));
                        $amount = 5000 + (($hours - 1) * 4000);
                    }

                    $pSession = ParkingSession::create([
                        'ticket_number' => $z->code . '-' . $date->format('ymd') . '-' . str_pad($j, 4, '0', STR_PAD_LEFT),
                        'zone_id' => $z->id,
                        'tariff_id' => $tariff->id,
                        'jukir_id' => $jukirInZone->id,
                        'plate_number' => 'B ' . rand(1000, 9999) . ' ' . chr(rand(65, 90)) . chr(rand(65, 90)),
                        'vehicle_type_id' => $vType->id,
                        'vehicle_type' => $vType->code,
                        'entry_at' => $entryTime,
                        'exit_at' => $exitTime,
                        'estimated_amount' => $amount,
                        'final_amount' => $isCompleted ? $amount : null,
                        'status' => $isCompleted ? 'completed' : 'active',
                        'payment_status' => $isCompleted ? 'paid' : 'unpaid',
                    ]);

                    if ($isCompleted) {
                        $method = rand(0, 3) == 0 ? 'qris' : 'cash';
                        Transaction::create([
                            'transaction_number' => 'TRX-' . $date->format('Ymd') . '-' . $z->id . '-' . str_pad($j, 4, '0', STR_PAD_LEFT),
                            'parking_session_id' => $pSession->id,
                            'zone_id' => $z->id,
                            'jukir_id' => $jukirInZone->id,
                            'payment_method' => $method,
                            'amount' => $amount,
                            'status' => 'recorded',
                            'created_at' => $exitTime,
                        ]);
                        if ($method == 'cash') $dailyCash += $amount; else $dailyQris += $amount;
                    }
                }

                if ($i > 0) {
                    Settlement::create([
                        'settlement_number' => 'SET-' . $date->format('Ymd') . '-' . $z->id,
                        'shift_id' => $dailyShift->id,
                        'zone_id' => $z->id,
                        'jukir_id' => $jukirInZone->id,
                        'settlement_date' => $date,
                        'cash_amount' => $dailyCash,
                        'qris_amount' => $dailyQris,
                        'total_amount' => $dailyCash + $dailyQris,
                        'status' => 'approved',
                    ]);
                }
            }
        }

        $admin->auditLogs()->create([
            'action' => 'seeded',
            'entity_type' => 'database',
            'new_values' => ['message' => 'ParkirGo complete demo data initialized'],
        ]);
    }
}
