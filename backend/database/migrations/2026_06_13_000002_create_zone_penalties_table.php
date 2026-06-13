<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('zone_penalties', function (Blueprint $table) {
            $table->id();
            $table->foreignId('zone_id')->constrained()->onDelete('cascade');
            $table->string('vehicle_type', 30)->nullable()->comment('null = semua jenis');
            $table->string('penalty_type', 30); // card_lost / unregistered
            $table->integer('amount')->default(0);
            $table->string('status', 20)->default('active');
            $table->timestamps();

            $table->unique(['zone_id', 'vehicle_type', 'penalty_type']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('zone_penalties');
    }
};
