<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('zones', function (Blueprint $table) {
            $table->decimal('center_lat', 10, 7)->nullable()->after('polygon');
            $table->decimal('center_lng', 10, 7)->nullable()->after('center_lat');
            $table->unsignedInteger('radius_meters')->default(150)->after('center_lng');
        });
    }

    public function down(): void
    {
        Schema::table('zones', function (Blueprint $table) {
            $table->dropColumn(['center_lat', 'center_lng', 'radius_meters']);
        });
    }
};
