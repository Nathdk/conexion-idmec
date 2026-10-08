<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Egresos - CONEXIÓN IDMEC</title>
    <style>
        body { margin: 0; font-family: Arial, sans-serif; background: #F7F7F5; color: #2C333D; }
        header { background: #0F2A4A; color: #fff; padding: 16px 24px; display: flex; justify-content: space-between; align-items: center; }
        header a { color: #D4AF37; text-decoration: none; margin-right: 16px; }
        header button { background: #D4AF37; color: #0F2A4A; border: 0; padding: 8px 14px; border-radius: 6px; cursor: pointer; }
        main { padding: 24px; max-width: 900px; margin: 0 auto; }
        .tarjeta { background: #fff; padding: 20px; border-radius: 10px; box-shadow: 0 2px 8px rgba(0,0,0,.06); margin-bottom: 20px; }
        h2 { color: #0F2A4A; margin-top: 0; }
        .fila { display: flex; gap: 12px; flex-wrap: wrap; }
        .campo { flex: 1; min-width: 160px; }
        label { display: block; font-size: 14px; margin-bottom: 4px; }
        input { width: 100%; padding: 10px; border: 1px solid #8B95A3; border-radius: 6px; box-sizing: border-box; }
        .btn { background: #1E4D7B; color: #fff; border: 0; padding: 10px 18px; border-radius: 6px; cursor: pointer; margin-top: 12px; }
        .btn:hover { background: #0F2A4A; }
        table { width: 100%; border-collapse: collapse; }
        th { background: #0F2A4A; color: #fff; text-align: left; padding: 10px; }
        td { padding: 10px; border-bottom: 1px solid #e3e3e0; }
        .monto { color: #B33A3A; font-weight: bold; }
        .ver { color: #1E4D7B; text-decoration: none; font-weight: bold; }
        .borrar { background: none; border: 0; color: #B33A3A; cursor: pointer; }
        .exito { background: #e8f5e9; color: #2E7D32; padding: 10px; border-radius: 6px; margin-bottom: 16px; }
        .error { color: #B33A3A; font-size: 14px; }
        .total { font-size: 18px; text-align: right; margin-top: 12px; }
    </style>
</head>
<body>
    <header>
        <strong>CONEXIÓN IDMEC · Panel financiero</strong>
        <div>
            <a href="{{ route('dashboard') }}">Inicio</a>
            <a href="{{ route('ingresos.index') }}">Ingresos</a>
            <form method="POST" action="{{ route('logout') }}" style="display:inline">
                @csrf
                <button type="submit">Cerrar sesión</button>
            </form>
        </div>
    </header>

    <main>
        @if (session('exito'))
            <div class="exito">{{ session('exito') }}</div>
        @endif

        <div class="tarjeta">
            <h2>Registrar egreso</h2>
            <form method="POST" action="{{ route('egresos.store') }}" enctype="multipart/form-data">
                @csrf
                <div class="fila">
                    <div class="campo">
                        <label for="monto">Monto ($)</label>
                        <input type="number" step="0.01" id="monto" name="monto" value="{{ old('monto') }}" required>
                        @error('monto') <div class="error">{{ $message }}</div> @enderror
                    </div>
                    <div class="campo">
                        <label for="fecha">Fecha</label>
                        <input type="date" id="fecha" name="fecha" value="{{ old('fecha', date('Y-m-d')) }}" required>
                        @error('fecha') <div class="error">{{ $message }}</div> @enderror
                    </div>
                    <div class="campo">
                        <label for="concepto">Concepto</label>
                        <input type="text" id="concepto" name="concepto" value="{{ old('concepto') }}" required>
                        @error('concepto') <div class="error">{{ $message }}</div> @enderror
                    </div>
                </div>
                <div class="fila" style="margin-top:12px">
                    <div class="campo">
                        <label for="comprobante">Comprobante (PDF, JPG o PNG, máx. 5 MB)</label>
                        <input type="file" id="comprobante" name="comprobante" accept=".pdf,.jpg,.jpeg,.png" required>
                        @error('comprobante') <div class="error">{{ $message }}</div> @enderror
                    </div>
                </div>
                <button type="submit" class="btn">Guardar egreso</button>
            </form>
        </div>

        <div class="tarjeta">
            <h2>Egresos registrados</h2>
            @if ($egresos->isEmpty())
                <p>Aún no hay egresos registrados.</p>
            @else
                <table>
                    <thead>
                        <tr><th>Fecha</th><th>Concepto</th><th>Monto</th><th>Comprobante</th><th></th></tr>
                    </thead>
                    <tbody>
                        @foreach ($egresos as $e)
                            <tr>
                                <td>{{ $e->fecha }}</td>
                                <td>{{ $e->concepto }}</td>
                                <td class="monto">${{ number_format((float) $e->monto, 2) }}</td>
                                <td><a class="ver" href="{{ $urlComprobantes }}/{{ $e->comprobante }}" target="_blank">Ver</a></td>
                                <td>
                                    <form method="POST" action="{{ route('egresos.destroy', $e->id_egreso) }}"
                                          onsubmit="return confirm('¿Eliminar este egreso?')">
                                        @csrf
                                        @method('DELETE')
                                        <button type="submit" class="borrar">Eliminar</button>
                                    </form>
                                </td>
                            </tr>
                        @endforeach
                    </tbody>
                </table>
                <div class="total">Total: <span class="monto">${{ number_format((float) $total, 2) }}</span></div>
            @endif
        </div>
    </main>
</body>
</html>