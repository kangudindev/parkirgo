<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('subscription_vehicles', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_subscription_id')->constrained('user_subscriptions')->cascadeOnDelete();
            $table->string('license_plate', 30);
            $table->string('label')->nullable();
            $table->timestamps();

            $table->index('license_plate');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('subscription_vehicles');
    }
};
