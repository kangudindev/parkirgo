<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('parking_sessions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('zone_id')->constrained()->cascadeOnDelete();
            $table->foreignId('tariff_id')->nullable()->constrained('zone_tariffs')->nullOnDelete();
            $table->foreignId('jukir_id')->constrained('users')->cascadeOnDelete();
            $table->string('ticket_number')->unique();
            $table->string('plate_number');
            $table->foreignId('vehicle_type_id')->nullable()->constrained()->nullOnDelete();
            $table->string('vehicle_type');
            $table->timestamp('entry_at');
            $table->timestamp('exit_at')->nullable();
            $table->unsignedInteger('duration_minutes')->nullable();
            $table->unsignedInteger('estimated_amount')->default(0);
            $table->unsignedInteger('final_amount')->nullable();
            $table->string('entry_photo_path')->nullable();
            $table->string('exit_photo_path')->nullable();
            $table->string('status')->default('active');
            $table->string('payment_status')->default('unpaid');
            $table->string('sync_status')->default('synced');
            $table->string('local_id')->nullable();
            $table->string('idempotency_key')->nullable()->unique();
            $table->json('metadata')->nullable();
            $table->timestamps();
        });

        Schema::create('transactions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('parking_session_id')->nullable()->constrained()->nullOnDelete();
            $table->foreignId('zone_id')->constrained()->cascadeOnDelete();
            $table->foreignId('jukir_id')->nullable()->constrained('users')->nullOnDelete();
            $table->string('transaction_number')->unique();
            $table->string('payment_method');
            $table->unsignedInteger('amount');
            $table->string('status')->default('recorded');
            $table->text('qris_payload')->nullable();
            $table->string('proof_image_path')->nullable();
            $table->foreignId('verified_by')->nullable()->constrained('users')->nullOnDelete();
            $table->timestamp('verified_at')->nullable();
            $table->text('verification_note')->nullable();
            $table->string('sync_status')->default('synced');
            $table->string('local_id')->nullable();
            $table->string('idempotency_key')->nullable()->unique();
            $table->json('metadata')->nullable();
            $table->timestamps();
        });

        Schema::create('settlements', function (Blueprint $table) {
            $table->id();
            $table->foreignId('shift_id')->nullable()->constrained()->nullOnDelete();
            $table->foreignId('zone_id')->constrained()->cascadeOnDelete();
            $table->foreignId('jukir_id')->constrained('users')->cascadeOnDelete();
            $table->string('settlement_number')->unique();
            $table->date('settlement_date');
            $table->unsignedInteger('cash_amount')->default(0);
            $table->unsignedInteger('qris_amount')->default(0);
            $table->unsignedInteger('total_amount')->default(0);
            $table->string('proof_image_path')->nullable();
            $table->string('status')->default('submitted');
            $table->foreignId('approved_by')->nullable()->constrained('users')->nullOnDelete();
            $table->timestamp('approved_at')->nullable();
            $table->text('approval_note')->nullable();
            $table->string('sync_status')->default('synced');
            $table->string('local_id')->nullable();
            $table->string('idempotency_key')->nullable()->unique();
            $table->timestamps();
        });

        Schema::create('audit_logs', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->nullable()->constrained()->nullOnDelete();
            $table->string('action');
            $table->string('entity_type');
            $table->unsignedBigInteger('entity_id')->nullable();
            $table->json('old_values')->nullable();
            $table->json('new_values')->nullable();
            $table->string('ip_address')->nullable();
            $table->string('device_id')->nullable();
            $table->text('user_agent')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('audit_logs');
        Schema::dropIfExists('settlements');
        Schema::dropIfExists('transactions');
        Schema::dropIfExists('parking_sessions');
    }
};
