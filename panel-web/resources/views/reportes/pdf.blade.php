<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Reporte financiero</title>
    <style>
        body { font-family: DejaVu Sans, sans-serif; font-size: 12px; color: #2C333D; }
        .encabezado { background: #0F2A4A; color: #ffffff; padding: 14px; }
        .encabezado h1 { margin: 0; font-size: 18px; }
        .encabezado p { margin: 4px 0 0; font-size: 11px; color: #D4AF37; }
        .info { margin: 14px 0; font-size: 11px; color: #8B95A3; }
        table { width: 100%; border-collapse: collapse; }
        th { background: #0F2A4A; color: #ffffff; text-align: left; padding: 7px; font-size: 11px; }
        td { padding: 7px; border-bottom: 1px solid #dddddd; }
        .ingreso { color: #2E7D32; font-weight: bold; }
        .egreso { color: #B33A3A; font-weight: bold; }
        .totales { margin-top: 16px; text-align: right; font-size: 13px; line-height: 1.7; }
    </style>
</head>
<body>
    <div class="encabezado">
        <h1>CONEXIÓN IDMEC - Reporte financiero</h1>
        <p>Iglesia de Dios en México Evangelio Completo, Torre Fuerte</p>
    </div>

    <div class="info">
        Tipo: {{ ucfirst($filtros['tipo']) }}
        | Desde: {{ $filtros['desde'] ?? 'el inicio' }}
        | Hasta: {{ $filtros['hasta'] ?? 'hoy' }}
        | Generado: {{ now()->format('d/m/Y H:i') }}
        | Por: {{ auth()->user()->nombre }}
    </div>

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
            <strong>Balance:
                <span class="{{ $balance >= 0 ? 'ingreso' : 'egreso' }}">
                    {{ $balance < 0 ? '-' : '' }}${{ number_format(abs($balance), 2) }}
                </span>
            </strong>
        </div>
    @endif
</body>
</html>