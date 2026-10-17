<?php

use App\Http\Controllers\AuthController;
use App\Http\Controllers\BalanceController;
use App\Http\Controllers\EgresoController;
use App\Http\Controllers\IngresoController;
use App\Http\Controllers\InventarioController;
use App\Http\Controllers\ReporteController;
use Illuminate\Support\Facades\Route;

Route::get('/', fn () => redirect()->route('login'));
Route::get('/login', [AuthController::class, 'mostrarLogin'])->name('login');
Route::post('/login', [AuthController::class, 'login']);
Route::post('/logout', [AuthController::class, 'logout'])->name('logout');

Route::middleware('auth')->group(function () {
    Route::get('/dashboard', fn () => view('dashboard'))->name('dashboard');

    Route::get('/ingresos', [IngresoController::class, 'index'])->name('ingresos.index');
    Route::post('/ingresos', [IngresoController::class, 'store'])->name('ingresos.store');
    Route::delete('/ingresos/{id}', [IngresoController::class, 'destroy'])->name('ingresos.destroy');

    Route::get('/egresos', [EgresoController::class, 'index'])->name('egresos.index');
    Route::post('/egresos', [EgresoController::class, 'store'])->name('egresos.store');
    Route::delete('/egresos/{id}', [EgresoController::class, 'destroy'])->name('egresos.destroy');

    Route::get('/balance', [BalanceController::class, 'index'])->name('balance.index');

    Route::get('/reportes', [ReporteController::class, 'index'])->name('reportes.index');
    Route::get('/reportes/pdf', [ReporteController::class, 'pdf'])->name('reportes.pdf');

    Route::get('/inventario', [InventarioController::class, 'index'])->name('inventario.index');
    Route::post('/inventario', [InventarioController::class, 'store'])->name('inventario.store');
    Route::put('/inventario/{id}', [InventarioController::class, 'update'])->name('inventario.update');
    Route::post('/inventario/{id}/movimiento', [InventarioController::class, 'movimiento'])->name('inventario.movimiento');
    Route::delete('/inventario/{id}', [InventarioController::class, 'destroy'])->name('inventario.destroy');
});