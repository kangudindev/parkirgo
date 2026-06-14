<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('zones', function (Blueprint $table) {
            $table->dropColumn(['capacity_motor', 'capacity_car']);
        });
    }

    public function down(): void
    {
        Schema::table('zones', function (Blueprint $table) {
            $table->unsignedInteger('capacity_motor')->default(0);
            $table->unsignedInteger('capacity_car')->default(0);
        });
    }
};
