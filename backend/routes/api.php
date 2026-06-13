<?php

use App\Http\Controllers\Api\AttendanceController;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\MeController;
use App\Http\Controllers\Api\ParkingSessionController;
use App\Http\Controllers\Api\PenaltyController;
use App\Http\Controllers\Api\SettlementController;
use App\Http\Controllers\Api\SupervisorController;
use App\Http\Controllers\Api\SyncController;
use App\Http\Controllers\Api\TransactionController;
use App\Http\Controllers\Api\UploadController;
use App\Http\Controllers\Api\ZoneController;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| Here is where you can register API routes for your application. These
| routes are loaded by the RouteServiceProvider and all of them will
| be assigned to the "api" middleware group. Make something great!
|
*/

Route::prefix('v1')->group(function () {
    Route::post('/login/qr', [AuthController::class, 'loginQr']);
});

Route::middleware('auth:sanctum')->prefix('v1')->group(function () {
    Route::get('/me', MeController::class);
    Route::get('/zones', [ZoneController::class, 'index']);

    Route::post('/attendances', [AttendanceController::class, 'store']);
    Route::get('/parking-sessions', [ParkingSessionController::class, 'index']);
    Route::post('/parking-sessions', [ParkingSessionController::class, 'store']);
    Route::get('/parking-sessions/by-ticket/{ticket}', [ParkingSessionController::class, 'showByTicket']);
    Route::post('/parking-sessions/{parkingSession}/close', [ParkingSessionController::class, 'close']);
    Route::post('/parking-sessions/{parkingSession}/force-exit', [ParkingSessionController::class, 'forceExit']);
    Route::post('/parking-sessions/unregistered-exit', [ParkingSessionController::class, 'unregisteredExit']);
    Route::post('/transactions', [TransactionController::class, 'store']);
    Route::get('/transactions', [TransactionController::class, 'index']);
    Route::post('/settlements', [SettlementController::class, 'store']);
    Route::post('/sync/batch', SyncController::class);
    Route::post('/upload', [UploadController::class, 'store']);

    // Denda
    Route::get('/penalties', [PenaltyController::class, 'index']);
    Route::post('/penalties/by-zone-type', [PenaltyController::class, 'byZoneAndType']);

    // Supervisor only
    Route::get('/supervisor/monitoring', [SupervisorController::class, 'monitoring']);
    Route::get('/supervisor/qris-pending', [SupervisorController::class, 'pendingQris']);
    Route::post('/supervisor/verify-qris', [SupervisorController::class, 'verifyQris']);
    Route::get('/supervisor/settlements-pending', [SupervisorController::class, 'pendingSettlements']);
    Route::post('/supervisor/approve-settlement', [SupervisorController::class, 'approveSettlement'])->name('api.v1.supervisor.approve-settlement');
});
