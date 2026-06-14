<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('zone_vehicle_types', function (Blueprint $table) {
            $table->id();
            $table->foreignId('zone_id')->constrained()->cascadeOnDelete();
            $table->foreignId('vehicle_type_id')->constrained()->cascadeOnDelete();
            $table->unsignedInteger('capacity')->default(0);
            $table->timestamps();
            $table->unique(['zone_id', 'vehicle_type_id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('zone_vehicle_types');
    }
};
