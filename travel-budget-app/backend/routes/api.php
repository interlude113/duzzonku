<?php

use App\Http\Controllers\AuthController;
use App\Http\Controllers\TripController;
use App\Http\Controllers\ExpenseController;
use Illuminate\Support\Facades\Route;

// 認証不要のルート（会員登録・ログイン）
Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);

// 認証が必要なルート（Sanctumトークンが必要）
Route::middleware('auth:sanctum')->group(function () {
    // ログアウト
    Route::post('/logout', [AuthController::class, 'logout']);

    // 旅行のCRUD
    Route::get('/trips', [TripController::class, 'index']);
    Route::post('/trips', [TripController::class, 'store']);
    Route::delete('/trips/{trip}', [TripController::class, 'destroy']);

    // 支出のCRUD
    Route::get('/trips/{trip}/expenses', [ExpenseController::class, 'index']);
    Route::post('/trips/{trip}/expenses', [ExpenseController::class, 'store']);
    Route::delete('/trips/{trip}/expenses/{expense}', [ExpenseController::class, 'destroy']);
});