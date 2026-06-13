<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('zones', function (Blueprint $table) {
            $table->id();
            $table->string('code')->unique();
            $table->string('name');
            $table->string('city')->default('Jakarta');
            $table->json('polygon')->nullable();
            $table->unsignedInteger('capacity_motor')->default(0);
            $table->unsignedInteger('capacity_car')->default(0);
            $table->text('qris_payload')->nullable();
            $table->string('qris_image_path')->nullable();
            $table->string('status')->default('active');
            $table->timestamps();
        });

        Schema::create('vehicle_types', function (Blueprint $table) {
            $table->id();
            $table->string('code')->unique();
            $table->string('name');
            $table->string('icon')->nullable();
            $table->unsignedInteger('sort_order')->default(0);
            $table->string('status')->default('active');
            $table->timestamps();
        });

        Schema::create('zone_tariffs', function (Blueprint $table) {
            $table->id();
            $table->foreignId('zone_id')->constrained()->cascadeOnDelete();
            $table->foreignId('vehicle_type_id')->nullable()->constrained()->nullOnDelete();
            $table->string('vehicle_type');
            $table->string('pricing_type');
            $table->string('payment_timing');
            $table->unsignedInteger('base_minutes')->default(60);
            $table->unsignedInteger('base_rate')->default(0);
            $table->unsignedInteger('increment_minutes')->nullable();
            $table->unsignedInteger('increment_rate')->nullable();
            $table->unsignedInteger('daily_max_rate')->nullable();
            $table->unsignedInteger('grace_period_minutes')->default(0);
            $table->unsignedInteger('rounding_minutes')->default(1);
            $table->string('status')->default('active');
            $table->timestamps();
            $table->unique(['zone_id', 'vehicle_type', 'pricing_type']);
        });

        Schema::create('shifts', function (Blueprint $table) {
            $table->id();
            $table->foreignId('zone_id')->constrained()->cascadeOnDelete();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->string('code')->unique();
            $table->date('shift_date');
            $table->time('start_time');
            $table->time('end_time');
            $table->string('status')->default('scheduled');
            $table->timestamps();
        });

        Schema::create('attendances', function (Blueprint $table) {
            $table->id();
            $table->foreignId('shift_id')->nullable()->constrained()->nullOnDelete();
            $table->foreignId('zone_id')->constrained()->cascadeOnDelete();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->timestamp('check_in_at')->nullable();
            $table->timestamp('check_out_at')->nullable();
            $table->decimal('check_in_latitude', 10, 7)->nullable();
            $table->decimal('check_in_longitude', 10, 7)->nullable();
            $table->decimal('check_out_latitude', 10, 7)->nullable();
            $table->decimal('check_out_longitude', 10, 7)->nullable();
            $table->string('selfie_path')->nullable();
            $table->string('sync_status')->default('synced');
            $table->string('local_id')->nullable();
            $table->string('idempotency_key')->nullable()->unique();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('attendances');
        Schema::dropIfExists('shifts');
        Schema::dropIfExists('zone_tariffs');
        Schema::dropIfExists('vehicle_types');
        Schema::dropIfExists('zones');
    }
};
