<?php

namespace App\Http\Controllers;

use App\Models\Inventario;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;

class InventarioController extends Controller
{
    public function index()
    {
        $articulos = Inventario::orderBy('nombre_art')->get();
        $bajos = $articulos->filter(fn ($a) => $a->cantidad <= $a->minimo);

        return view('inventario.index', compact('articulos', 'bajos'));
    }

    public function store(Request $request)
    {
        $datos = $request->validate([
            'nombre_art' => 'required|string|max:150',
            'cantidad' => 'required|integer|min:0',
            'minimo' => 'required|integer|min:0',
        ]);

        $articulo = Inventario::create($datos + ['id_tesorero' => auth()->id()]);

        // Si se registra ya por debajo del mínimo, se avisa
        if ($articulo->cantidad <= $articulo->minimo) {
            $this->avisarStockBajo($articulo);
        }

        return redirect()->route('inventario.index')->with('exito', 'Artículo registrado correctamente');
    }

    public function update(Request $request, $id)
    {
        $datos = $request->validate([
            'nombre_art' => 'required|string|max:150',
            'minimo' => 'required|integer|min:0',
        ]);

        Inventario::where('id_inventario', $id)->update($datos);

        return redirect()->route('inventario.index')->with('exito', 'Artículo actualizado');
    }

    // Entrada (suma) o salida (resta) de existencias
    public function movimiento(Request $request, $id)
    {
        $datos = $request->validate([
            'tipo' => 'required|in:entrada,salida',
            'unidades' => 'required|integer|min:1',
        ]);

        $articulo = Inventario::where('id_inventario', $id)->firstOrFail();

        if ($datos['tipo'] === 'salida' && $datos['unidades'] > $articulo->cantidad) {
            return back()->withErrors([
                'movimiento' => "No hay suficientes existencias de \"{$articulo->nombre_art}\" (quedan {$articulo->cantidad}).",
            ]);
        }

        $antes = $articulo->cantidad;
        $articulo->cantidad += $datos['tipo'] === 'entrada' ? $datos['unidades'] : -$datos['unidades'];
        $articulo->save();

        // Avisa solo cuando el artículo cruza el mínimo (antes estaba por encima, ahora no)
        if ($antes > $articulo->minimo && $articulo->cantidad <= $articulo->minimo) {
            $this->avisarStockBajo($articulo);
        }

        return redirect()->route('inventario.index')->with('exito', 'Movimiento registrado');
    }

    public function destroy($id)
    {
        Inventario::where('id_inventario', $id)->delete();

        return redirect()->route('inventario.index')->with('exito', 'Artículo eliminado');
    }

    // Pide al backend de Node que mande la notificación por Firebase
    private function avisarStockBajo(Inventario $articulo): void
    {
        try {
            Http::timeout(3)->post(rtrim(env('NODE_API_URL'), '/') . '/notificaciones/stock-bajo', [
                'articulo' => $articulo->nombre_art,
                'cantidad' => $articulo->cantidad,
                'minimo' => $articulo->minimo,
            ]);
        } catch (\Throwable $e) {
            // Si el backend no responde, el inventario se guarda igual
        }
    }
}