<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('parking_sessions', function (Blueprint $table) {
            $table->string('owner_name', 100)->nullable()->after('metadata');
            $table->string('owner_nik', 30)->nullable()->after('owner_name');
            $table->text('owner_address')->nullable()->after('owner_nik');
            $table->string('owner_ktp_photo', 255)->nullable()->after('owner_address');
            $table->string('owner_stnk_photo', 255)->nullable()->after('owner_ktp_photo');
            $table->string('exit_vehicle_photo', 255)->nullable()->after('owner_stnk_photo');
            $table->string('driver_photo', 255)->nullable()->after('exit_vehicle_photo');
            $table->boolean('is_card_lost')->default(false)->after('driver_photo');
            $table->integer('penalty_fee')->default(0)->after('is_card_lost');
            $table->text('jukir_note')->nullable()->after('penalty_fee');
        });
    }

    public function down(): void
    {
        Schema::table('parking_sessions', function (Blueprint $table) {
            $table->dropColumn([
                'owner_name', 'owner_nik', 'owner_address',
                'owner_ktp_photo', 'owner_stnk_photo',
                'exit_vehicle_photo', 'driver_photo',
                'is_card_lost', 'penalty_fee', 'jukir_note',
            ]);
        });
    }
};
