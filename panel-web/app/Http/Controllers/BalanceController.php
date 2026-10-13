<?php

namespace App\Http\Controllers;

use App\Models\Egreso;
use App\Models\Ingreso;

class BalanceController extends Controller
{
    public function index()
    {
        $totalIngresos = (float) Ingreso::sum('monto');
        $totalEgresos = (float) Egreso::sum('monto');

        $ingresosPorCategoria = Ingreso::selectRaw('concepto, SUM(monto) as total')
            ->groupBy('concepto')
            ->orderByDesc('total')
            ->get();

        return view('balance.index', [
            'totalIngresos' => $totalIngresos,
            'totalEgresos' => $totalEgresos,
            'balance' => $totalIngresos - $totalEgresos,
            'ingresosPorCategoria' => $ingresosPorCategoria,
        ]);
    }
}