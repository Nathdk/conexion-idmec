<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Balance - CONEXIÓN IDMEC</title>
    <style>
        body { margin: 0; font-family: Arial, sans-serif; background: #F7F7F5; color: #2C333D; }
        header { background: #0F2A4A; color: #fff; padding: 16px 24px; display: flex; justify-content: space-between; align-items: center; }
        header a { color: #D4AF37; text-decoration: none; margin-right: 16px; }
        header button { background: #D4AF37; color: #0F2A4A; border: 0; padding: 8px 14px; border-radius: 6px; cursor: pointer; }
        main { padding: 24px; max-width: 900px; margin: 0 auto; }
        h2 { color: #0F2A4A; margin-top: 0; }
        .resumen { display: flex; gap: 16px; flex-wrap: wrap; margin-bottom: 20px; }
        .caja { flex: 1; min-width: 200px; background: #fff; padding: 20px; border-radius: 10px; box-shadow: 0 2px 8px rgba(0,0,0,.06); }
        .caja small { color: #8B95A3; display: block; margin-bottom: 6px; }
        .caja strong { font-size: 26px; }
        .ingreso { color: #2E7D32; }
        .egreso { color: #B33A3A; }
        .tarjeta { background: #fff; padding: 20px; border-radius: 10px; box-shadow: 0 2px 8px rgba(0,0,0,.06); }
        table { width: 100%; border-collapse: collapse; }
        th { background: #0F2A4A; color: #fff; text-align: left; padding: 10px; }
        td { padding: 10px; border-bottom: 1px solid #e3e3e0; }
    </style>
</head>
<body>
    <header>
        <strong>CONEXIÓN IDMEC · Panel financiero</strong>
        <div>
            <a href="{{ route('dashboard') }}">Inicio</a>
            <a href="{{ route('ingresos.index') }}">Ingresos</a>
            <a href="{{ route('egresos.index') }}">Egresos</a>
            <form method="POST" action="{{ route('logout') }}" style="display:inline">
                @csrf
                <button type="submit">Cerrar sesión</button>
            </form>
        </div>
    </header>

    <main>
        <h2>Balance general</h2>

        <div class="resumen">
            <div class="caja">
                <small>Total de ingresos</small>
                <strong class="ingreso">${{ number_format($totalIngresos, 2) }}</strong>
            </div>
            <div class="caja">
                <small>Total de egresos</small>
                <strong class="egreso">${{ number_format($totalEgresos, 2) }}</strong>
            </div>
            <div class="caja">
                <small>Balance (ingresos − egresos)</small>
                <strong class="{{ $balance >= 0 ? 'ingreso' : 'egreso' }}">
                    {{ $balance < 0 ? '-' : '' }}${{ number_format(abs($balance), 2) }}
                </strong>
            </div>
        </div>

        <div class="tarjeta">
            <h2>Ingresos por categoría</h2>
            @if ($ingresosPorCategoria->isEmpty())
                <p>Aún no hay ingresos registrados.</p>
            @else
                <table>
                    <thead>
                        <tr><th>Categoría</th><th>Total</th></tr>
                    </thead>
                    <tbody>
                        @foreach ($ingresosPorCategoria as $fila)
                            <tr>
                                <td>{{ $fila->concepto }}</td>
                                <td class="ingreso"><strong>${{ number_format((float) $fila->total, 2) }}</strong></td>
                            </tr>
                        @endforeach
                    </tbody>
                </table>
            @endif
        </div>
    </main>
</body>
</html>