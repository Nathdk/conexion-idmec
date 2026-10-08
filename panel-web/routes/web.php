<?php

use App\Http\Controllers\AuthController;
use App\Http\Controllers\EgresoController;
use App\Http\Controllers\IngresoController;
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
});