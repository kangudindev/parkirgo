<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->string('role')->default('jukir')->after('password');
            $table->string('nik')->nullable()->unique()->after('role');
            $table->string('phone')->nullable()->after('nik');
            $table->string('status')->default('active')->after('phone');
            $table->string('device_id')->nullable()->after('status');
            $table->foreignId('assigned_zone_id')->nullable()->after('device_id');
            $table->timestamp('last_seen_at')->nullable()->after('assigned_zone_id');
        });
    }

    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropColumn(['role', 'nik', 'phone', 'status', 'device_id', 'assigned_zone_id', 'last_seen_at']);
        });
    }
};
