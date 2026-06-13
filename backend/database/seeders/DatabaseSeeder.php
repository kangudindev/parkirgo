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

        // Add 5 more zones across Jakarta
        $zones = [
            [
                'code' => 'ZONA-BLOK-M',
                'name' => 'Blok M Square',
                'city' => 'Jakarta Selatan',
                'capacity_motor' => 200,
                'capacity_car' => 100,
                'status' => 'active'
            ],
            [
                'code' => 'ZONA-KOTA-TUA',
                'name' => 'Kota Tua Museum Fatahillah',
                'city' => 'Jakarta Barat',
                'capacity_motor' => 300,
                'capacity_car' => 20,
                'status' => 'active'
            ],
            [
                'code' => 'ZONA-KELAPA-GADING',
                'name' => 'Boulevard Kelapa Gading',
                'city' => 'Jakarta Utara',
                'capacity_motor' => 150,
                'capacity_car' => 80,
                'status' => 'active'
            ],
            [
                'code' => 'ZONA-PASAR-BARU',
                'name' => 'Pasar Baru Area',
                'city' => 'Jakarta Pusat',
                'capacity_motor' => 100,
                'capacity_car' => 30,
                'status' => 'active'
            ],
            [
                'code' => 'ZONA-TEBET',
                'name' => 'Tebet Eco Park West',
                'city' => 'Jakarta Selatan',
                'capacity_motor' => 180,
                'capacity_car' => 40,
                'status' => 'active'
            ]
        ];

        $createdZones = [$zone];
        foreach ($zones as $zData) {
            $createdZones[] = Zone::updateOrCreate(['code' => $zData['code']], $zData);
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
                    'assigned_zone_id' => $createdZones[array_rand($createdZones)]->id,
                    'qr_auth_token' => 'QR-' . strtoupper(bin2hex(random_bytes(12))),
                    'email_verified_at' => now(),
                    'last_seen_at' => now()->subMinutes(rand(1, 120)),
                ]
            );
        }

        // Create historical sessions, transactions, and settlements for the last 7 days
        foreach ($createdZones as $z) {
            $jukirInZone = User::where('assigned_zone_id', $z->id)->first() ?? $jukir;
            
            for ($i = 7; $i >= 0; $i--) {
                $date = Carbon::today()->subDays($i);
                
                // Create a shift for each day
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

                $dailyCash = 0;
                $dailyQris = 0;

                // Create some sessions for each day
                $sessionCount = rand(10, 30);
                for ($j = 1; $j <= $sessionCount; $j++) {
                    $vType = rand(0, 1) == 0 ? $motor : $mobil;
                    $tariff = $vType->code == 'motor' ? $flatMotor : $progressiveCar;
                    $entryTime = (clone $date)->setTime(rand(7, 14), rand(0, 59));
                    
                    $isCompleted = $i > 0 || rand(0, 1) == 1;
                    $exitTime = $isCompleted ? (clone $entryTime)->addMinutes(rand(30, 240)) : null;
                    
                    $amount = 3000; // default for motor
                    if ($vType->code == 'mobil') {
                        $duration = $exitTime ? $exitTime->diffInMinutes($entryTime) : 60;
                        $hours = ceil($duration / 60);
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
                            'qris_payload' => $method == 'qris' ? $z->qris_payload : null,
                            'created_at' => $exitTime,
                        ]);

                        if ($method == 'cash') $dailyCash += $amount;
                        else $dailyQris += $amount;
                    }
                }

                // Create settlement for past days
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
            'new_values' => ['message' => 'ParkirGo demo data initialized'],
        ]);
    }
}
