<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Reportes - CONEXIÓN IDMEC</title>
    <style>
        body { margin: 0; font-family: Arial, sans-serif; background: #F7F7F5; color: #2C333D; }
        header { background: #0F2A4A; color: #fff; padding: 16px 24px; display: flex; justify-content: space-between; align-items: center; }
        header a { color: #D4AF37; text-decoration: none; margin-right: 16px; }
        header button { background: #D4AF37; color: #0F2A4A; border: 0; padding: 8px 14px; border-radius: 6px; cursor: pointer; }
        main { padding: 24px; max-width: 900px; margin: 0 auto; }
        .tarjeta { background: #fff; padding: 20px; border-radius: 10px; box-shadow: 0 2px 8px rgba(0,0,0,.06); margin-bottom: 20px; }
        h2 { color: #0F2A4A; margin-top: 0; }
        .fila { display: flex; gap: 12px; flex-wrap: wrap; align-items: flex-end; }
        .campo { flex: 1; min-width: 160px; }
        label { display: block; font-size: 14px; margin-bottom: 4px; }
        input, select { width: 100%; padding: 10px; border: 1px solid #8B95A3; border-radius: 6px; box-sizing: border-box; }
        .btn { background: #1E4D7B; color: #fff; border: 0; padding: 10px 18px; border-radius: 6px; cursor: pointer; text-decoration: none; display: inline-block; font-size: 14px; }
        .btn:hover { background: #0F2A4A; }
        .btn-pdf { background: #D4AF37; color: #0F2A4A; font-weight: bold; }
        table { width: 100%; border-collapse: collapse; }
        th { background: #0F2A4A; color: #fff; text-align: left; padding: 10px; }
        td { padding: 10px; border-bottom: 1px solid #e3e3e0; }
        .ingreso { color: #2E7D32; font-weight: bold; }
        .egreso { color: #B33A3A; font-weight: bold; }
        .totales { margin-top: 16px; text-align: right; line-height: 1.8; }
        .error { color: #B33A3A; font-size: 14px; }
    </style>
</head>
<body>
    <header>
        <strong>CONEXIÓN IDMEC · Panel financiero</strong>
        <div>
            <a href="{{ route('dashboard') }}">Inicio</a>
            <a href="{{ route('ingresos.index') }}">Ingresos</a>
            <a href="{{ route('egresos.index') }}">Egresos</a>
            <a href="{{ route('balance.index') }}">Balance</a>
            <form method="POST" action="{{ route('logout') }}" style="display:inline">
                @csrf
                <button type="submit">Cerrar sesión</button>
            </form>
        </div>
    </header>

    <main>
        <div class="tarjeta">
            <h2>Reportes financieros</h2>
            <form method="GET" action="{{ route('reportes.index') }}">
                <div class="fila">
                    <div class="campo">
                        <label for="tipo">Tipo</label>
                        <select id="tipo" name="tipo">
                            <option value="todos" @selected($filtros['tipo'] === 'todos')>Ingresos y egresos</option>
                            <option value="ingresos" @selected($filtros['tipo'] === 'ingresos')>Solo ingresos</option>
                            <option value="egresos" @selected($filtros['tipo'] === 'egresos')>Solo egresos</option>
                        </select>
                    </div>
                    <div class="campo">
                        <label for="desde">Desde</label>
                        <input type="date" id="desde" name="desde" value="{{ $filtros['desde'] }}">
                    </div>
                    <div class="campo">
                        <label for="hasta">Hasta</label>
                        <input type="date" id="hasta" name="hasta" value="{{ $filtros['hasta'] }}">
                    </div>
                    <button type="submit" class="btn">Filtrar</button>
                    <a class="btn btn-pdf" href="{{ route('reportes.pdf', array_filter($filtros)) }}">Descargar PDF</a>
                </div>
                @error('desde') <div class="error">{{ $message }}</div> @enderror
                @error('hasta') <div class="error">{{ $message }}</div> @enderror
            </form>
        </div>

        <div class="tarjeta">
            <h2>Resultados</h2>
            @if ($movimientos->isEmpty())
                <p>No hay movimientos con esos filtros.</p>
            @else
                <table>
                    <thead>
                        <tr><th>Fecha</th><th>Tipo</th><th>Concepto</th><th>Detalle</th><th>Monto</th></tr>
                    </thead>
                    <tbody>
                        @foreach ($movimientos as $m)
                            <tr>
                                <td>{{ $m['fecha'] }}</td>
                                <td>{{ $m['tipo'] }}</td>
                                <td>{{ $m['concepto'] }}</td>
                                <td>{{ $m['detalle'] }}</td>
                                <td class="{{ $m['tipo'] === 'Ingreso' ? 'ingreso' : 'egreso' }}">${{ number_format($m['monto'], 2) }}</td>
                            </tr>
                        @endforeach
                    </tbody>
                </table>
                <div class="totales">
                    Ingresos: <span class="ingreso">${{ number_format($totalIngresos, 2) }}</span><br>
                    Egresos: <span class="egreso">${{ number_format($totalEgresos, 2) }}</span><br>
                    Balance:
                    <span class="{{ $balance >= 0 ? 'ingreso' : 'egreso' }}">
                        {{ $balance < 0 ? '-' : '' }}${{ number_format(abs($balance), 2) }}
                    </span>
                </div>
            @endif
        </div>
    </main>
</body>
</html>