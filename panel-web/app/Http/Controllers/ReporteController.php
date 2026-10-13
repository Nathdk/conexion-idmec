<?php

namespace App\Http\Controllers;

use App\Models\Egreso;
use App\Models\Ingreso;
use App\Models\Reporte;
use Barryvdh\DomPDF\Facade\Pdf;
use Illuminate\Http\Request;

class ReporteController extends Controller
{
    public function index(Request $request)
    {
        return view('reportes.index', $this->consultar($request));
    }

    public function pdf(Request $request)
    {
        $datos = $this->consultar($request);

        Reporte::create([
            'tipo' => ucfirst($datos['filtros']['tipo']),
            'fecha_generacion' => now()->toDateString(),
            'id_usuario' => auth()->id(),
        ]);

        $nombre = 'reporte-financiero-' . now()->format('Ymd-His') . '.pdf';

        return Pdf::loadView('reportes.pdf', $datos)->download($nombre);
    }

    private function consultar(Request $request): array
    {
        $filtros = $request->validate([
            'tipo' => 'nullable|in:todos,ingresos,egresos',
            'desde' => 'nullable|date',
            'hasta' => 'nullable|date',
        ]);

        $filtros['tipo'] = $filtros['tipo'] ?? 'todos';
        $filtros['desde'] = $filtros['desde'] ?? null;
        $filtros['hasta'] = $filtros['hasta'] ?? null;

        $movimientos = collect();

        if (in_array($filtros['tipo'], ['todos', 'ingresos'])) {
            $consulta = Ingreso::query();
            if ($filtros['desde']) $consulta->where('fecha', '>=', $filtros['desde']);
            if ($filtros['hasta']) $consulta->where('fecha', '<=', $filtros['hasta']);

            foreach ($consulta->get() as $i) {
                $movimientos->push([
                    'fecha' => $i->fecha,
                    'tipo' => 'Ingreso',
                    'concepto' => $i->concepto,
                    'detalle' => $i->departamento,
                    'monto' => (float) $i->monto,
                ]);
            }
        }

        if (in_array($filtros['tipo'], ['todos', 'egresos'])) {
            $consulta = Egreso::query();
            if ($filtros['desde']) $consulta->where('fecha', '>=', $filtros['desde']);
            if ($filtros['hasta']) $consulta->where('fecha', '<=', $filtros['hasta']);

            foreach ($consulta->get() as $e) {
                $movimientos->push([
                    'fecha' => $e->fecha,
                    'tipo' => 'Egreso',
                    'concepto' => $e->concepto,
                    'detalle' => '-',
                    'monto' => (float) $e->monto,
                ]);
            }
        }

        $movimientos = $movimientos->sortByDesc('fecha')->values();
        $totalIngresos = $movimientos->where('tipo', 'Ingreso')->sum('monto');
        $totalEgresos = $movimientos->where('tipo', 'Egreso')->sum('monto');

        return [
            'filtros' => $filtros,
            'movimientos' => $movimientos,
            'totalIngresos' => $totalIngresos,
            'totalEgresos' => $totalEgresos,
            'balance' => $totalIngresos - $totalEgresos,
        ];
    }
}