<?php

namespace App\Http\Controllers;

use App\Models\Egreso;
use Illuminate\Http\Client\ConnectionException;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;

class EgresoController extends Controller
{
    private function urlComprobantes(): string
    {
        return rtrim(env('NODE_API_URL'), '/') . '/comprobantes';
    }

    public function index()
    {
        $egresos = Egreso::orderByDesc('fecha')->orderByDesc('id_egreso')->get();

        return view('egresos.index', [
            'egresos' => $egresos,
            'total' => $egresos->sum('monto'),
            'urlComprobantes' => $this->urlComprobantes(),
        ]);
    }

    public function store(Request $request)
    {
        $datos = $request->validate([
            'monto' => 'required|numeric|min:0.01',
            'fecha' => 'required|date',
            'concepto' => 'required|string|max:150',
            'comprobante' => 'required|file|mimes:pdf,jpg,jpeg,png|max:5120',
        ]);

        $archivo = $request->file('comprobante');

        try {
            $respuesta = Http::attach(
                'archivo',
                file_get_contents($archivo->getRealPath()),
                $archivo->getClientOriginalName()
            )->post($this->urlComprobantes());
        } catch (ConnectionException $e) {
            return back()
                ->withErrors(['comprobante' => 'No se pudo conectar con el servidor de comprobantes. Verifica que el backend esté encendido.'])
                ->withInput();
        }

        if (!$respuesta->successful()) {
            return back()
                ->withErrors(['comprobante' => $respuesta->json('mensaje') ?? 'No se pudo guardar el comprobante'])
                ->withInput();
        }

        Egreso::create([
            'monto' => $datos['monto'],
            'fecha' => $datos['fecha'],
            'concepto' => $datos['concepto'],
            'comprobante' => $respuesta->json('id'),
            'id_tesorero' => auth()->id(),
        ]);

        return redirect()->route('egresos.index')->with('exito', 'Egreso registrado correctamente');
    }

    public function destroy($id)
    {
        Egreso::where('id_egreso', $id)->delete();

        return redirect()->route('egresos.index')->with('exito', 'Egreso eliminado');
    }
}