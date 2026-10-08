<?php

namespace App\Http\Controllers;

use App\Models\Ingreso;
use Illuminate\Http\Request;

class IngresoController extends Controller
{
    public const CATEGORIAS = ['Diezmos', 'Ofrendas', 'Donaciones', 'Eventos', 'Otros'];

    public function index()
    {
        $ingresos = Ingreso::orderByDesc('fecha')->orderByDesc('id_ingreso')->get();
        $total = $ingresos->sum('monto');

        return view('ingresos.index', [
            'ingresos' => $ingresos,
            'total' => $total,
            'categorias' => self::CATEGORIAS,
        ]);
    }

    public function store(Request $request)
    {
        $datos = $request->validate([
            'monto' => 'required|numeric|min:0.01',
            'fecha' => 'required|date',
            'concepto' => 'required|in:' . implode(',', self::CATEGORIAS),
            'departamento' => 'required|string|max:50',
        ]);

        Ingreso::create($datos + ['id_tesorero' => auth()->id()]);

        return redirect()->route('ingresos.index')->with('exito', 'Ingreso registrado correctamente');
    }

    public function destroy($id)
    {
        Ingreso::where('id_ingreso', $id)->delete();

        return redirect()->route('ingresos.index')->with('exito', 'Ingreso eliminado');
    }
}