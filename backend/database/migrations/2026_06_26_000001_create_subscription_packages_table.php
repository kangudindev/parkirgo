<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('subscription_packages', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->enum('type', ['pass', 'quota', 'balance'])->default('pass');
            $table->decimal('price', 12, 2)->default(0);
            $table->unsignedInteger('duration_days')->default(30);
            $table->unsignedInteger('max_vehicles')->default(1);
            $table->decimal('value', 12, 2)->nullable(); // Menampung jumlah sesi untuk quota atau nominal saldo untuk balance
            $table->foreignId('vehicle_type_id')->constrained('vehicle_types')->cascadeOnDelete();
            $table->enum('status', ['active', 'inactive'])->default('active');
            $table->text('description')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('subscription_packages');
    }
};
