<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('user_subscriptions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->nullable()->constrained('users')->nullOnDelete();
            $table->foreignId('subscription_package_id')->constrained('subscription_packages')->cascadeOnDelete();
            $table->enum('type', ['pass', 'quota'])->default('pass');
            $table->integer('value_remaining')->nullable(); // Menampung sisa kuota (sesi)
            $table->date('start_date');
            $table->date('end_date');
            $table->enum('status', ['active', 'expired', 'used_up'])->default('active');
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('user_subscriptions');
    }
};
