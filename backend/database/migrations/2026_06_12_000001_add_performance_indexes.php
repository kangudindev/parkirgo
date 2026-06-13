<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('transactions', function (Blueprint $table) {
            $table->index('created_at');
            $table->index('zone_id');
            $table->index('jukir_id');
            $table->index('payment_method');
            $table->index('status');
            $table->index(['zone_id', 'created_at']);
            $table->index(['jukir_id', 'created_at']);
        });

        Schema::table('parking_sessions', function (Blueprint $table) {
            $table->index('zone_id');
            $table->index('jukir_id');
            $table->index('status');
            $table->index(['zone_id', 'status']);
            $table->index(['jukir_id', 'status']);
            $table->index(['zone_id', 'created_at']);
        });

        Schema::table('settlements', function (Blueprint $table) {
            $table->index('zone_id');
            $table->index('jukir_id');
            $table->index('status');
            $table->index(['jukir_id', 'settlement_date']);
        });

        Schema::table('attendances', function (Blueprint $table) {
            $table->index('zone_id');
            $table->index('user_id');
            $table->index(['user_id', 'check_in_at']);
        });

        Schema::table('users', function (Blueprint $table) {
            $table->index('role');
            $table->index('status');
            $table->index(['role', 'status']);
        });

        Schema::table('audit_logs', function (Blueprint $table) {
            $table->index('entity_type');
            $table->index(['entity_type', 'entity_id']);
            $table->index('created_at');
        });
    }

    public function down(): void
    {
        Schema::table('transactions', function (Blueprint $table) {
            $table->dropIndex(['created_at']);
            $table->dropIndex(['zone_id']);
            $table->dropIndex(['jukir_id']);
            $table->dropIndex(['payment_method']);
            $table->dropIndex(['status']);
            $table->dropIndex(['zone_id', 'created_at']);
            $table->dropIndex(['jukir_id', 'created_at']);
        });

        Schema::table('parking_sessions', function (Blueprint $table) {
            $table->dropIndex(['zone_id']);
            $table->dropIndex(['jukir_id']);
            $table->dropIndex(['status']);
            $table->dropIndex(['zone_id', 'status']);
            $table->dropIndex(['jukir_id', 'status']);
            $table->dropIndex(['zone_id', 'created_at']);
        });

        Schema::table('settlements', function (Blueprint $table) {
            $table->dropIndex(['zone_id']);
            $table->dropIndex(['jukir_id']);
            $table->dropIndex(['status']);
            $table->dropIndex(['jukir_id', 'settlement_date']);
        });

        Schema::table('attendances', function (Blueprint $table) {
            $table->dropIndex(['zone_id']);
            $table->dropIndex(['user_id']);
            $table->dropIndex(['user_id', 'check_in_at']);
        });

        Schema::table('users', function (Blueprint $table) {
            $table->dropIndex(['role']);
            $table->dropIndex(['status']);
            $table->dropIndex(['role', 'status']);
        });

        Schema::table('audit_logs', function (Blueprint $table) {
            $table->dropIndex(['entity_type']);
            $table->dropIndex(['entity_type', 'entity_id']);
            $table->dropIndex(['created_at']);
        });
    }
};
