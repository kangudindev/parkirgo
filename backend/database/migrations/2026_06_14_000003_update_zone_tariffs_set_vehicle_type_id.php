<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        DB::statement("
            UPDATE zone_tariffs t
            SET t.vehicle_type_id = (
                SELECT id FROM vehicle_types
                WHERE LOWER(name) = LOWER(t.vehicle_type)
                   OR LOWER(code) = LOWER(t.vehicle_type)
                LIMIT 1
            )
            WHERE t.vehicle_type_id IS NULL
        ");

        Schema::table('zone_tariffs', function (Blueprint $table) {
            $table->index('zone_id');
        });

        DB::statement('ALTER TABLE `zone_tariffs` DROP FOREIGN KEY `zone_tariffs_vehicle_type_id_foreign`');
        DB::statement('ALTER TABLE `zone_tariffs` DROP INDEX `zone_tariffs_zone_id_vehicle_type_pricing_type_unique`');

        Schema::table('zone_tariffs', function (Blueprint $table) {
            $table->dropColumn('vehicle_type');
        });

        Schema::table('zone_tariffs', function (Blueprint $table) {
            $table->foreignId('vehicle_type_id')->nullable(false)->change();
            $table->foreign('vehicle_type_id')->references('id')->on('vehicle_types')->cascadeOnDelete();
        });

        DB::statement('ALTER TABLE `zone_tariffs` ADD UNIQUE INDEX `zone_tariffs_zone_id_vehicle_type_id_pricing_type_unique` (`zone_id`, `vehicle_type_id`, `pricing_type`)');
    }

    public function down(): void
    {
        DB::statement('ALTER TABLE `zone_tariffs` DROP FOREIGN KEY `zone_tariffs_vehicle_type_id_foreign`');
        DB::statement('ALTER TABLE `zone_tariffs` DROP INDEX `zone_tariffs_zone_id_vehicle_type_id_pricing_type_unique`');

        Schema::table('zone_tariffs', function (Blueprint $table) {
            $table->string('vehicle_type', 30)->after('vehicle_type_id');
            $table->foreignId('vehicle_type_id')->nullable()->change();
            $table->foreign('vehicle_type_id')->references('id')->on('vehicle_types')->nullOnDelete();
        });

        DB::statement('ALTER TABLE `zone_tariffs` ADD UNIQUE INDEX `zone_tariffs_zone_id_vehicle_type_pricing_type_unique` (`zone_id`, `vehicle_type`, `pricing_type`)');

        Schema::table('zone_tariffs', function (Blueprint $table) {
            $table->dropIndex(['zone_id']);
        });
    }
};
