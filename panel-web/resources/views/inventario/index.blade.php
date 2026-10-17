<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Inventario - CONEXIÓN IDMEC</title>
    <style>
        body { margin: 0; font-family: Arial, sans-serif; background: #F7F7F5; color: #2C333D; }
        header { background: #0F2A4A; color: #fff; padding: 16px 24px; display: flex; justify-content: space-between; align-items: center; }
        header a { color: #D4AF37; text-decoration: none; margin-right: 16px; }
        header button { background: #D4AF37; color: #0F2A4A; border: 0; padding: 8px 14px; border-radius: 6px; cursor: pointer; }
        main { padding: 24px; max-width: 1000px; margin: 0 auto; }
        .tarjeta { background: #fff; padding: 20px; border-radius: 10px; box-shadow: 0 2px 8px rgba(0,0,0,.06); margin-bottom: 20px; }
        h2 { color: #0F2A4A; margin-top: 0; }
        .fila { display: flex; gap: 12px; flex-wrap: wrap; align-items: flex-end; }
        .campo { flex: 1; min-width: 160px; }
        label { display: block; font-size: 14px; margin-bottom: 4px; }
        input, select { padding: 8px; border: 1px solid #8B95A3; border-radius: 6px; box-sizing: border-box; }
        .campo input { width: 100%; }
        .btn { background: #1E4D7B; color: #fff; border: 0; padding: 10px 18px; border-radius: 6px; cursor: pointer; }
        .btn:hover { background: #0F2A4A; }
        .btn-chico { background: #1E4D7B; color: #fff; border: 0; padding: 6px 12px; border-radius: 6px; cursor: pointer; }
        table { width: 100%; border-collapse: collapse; }
        th { background: #0F2A4A; color: #fff; text-align: left; padding: 10px; }
        td { padding: 10px; border-bottom: 1px solid #e3e3e0; vertical-align: top; }
        tr.bajo td { background: #fff6e0; }
        .etiqueta-bajo { background: #E0A526; color: #2C333D; padding: 3px 8px; border-radius: 10px; font-size: 12px; font-weight: bold; }
        .etiqueta-ok { background: #e8f5e9; color: #2E7D32; padding: 3px 8px; border-radius: 10px; font-size: 12px; font-weight: bold; }
        .alerta { background: #E0A526; color: #2C333D; padding: 14px; border-radius: 8px; margin-bottom: 20px; }
        .exito { background: #e8f5e9; color: #2E7D32; padding: 10px; border-radius: 6px; margin-bottom: 16px; }
        .error { background: #fdecea; color: #B33A3A; padding: 10px; border-radius: 6px; margin-bottom: 16px; }
        .borrar { background: none; border: 0; color: #B33A3A; cursor: pointer; }
        details { margin-bottom: 6px; }
        summary { color: #1E4D7B; cursor: pointer; font-weight: bold; }
        details form { margin-top: 6px; display: flex; gap: 6px; flex-wrap: wrap; }
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
            <a href="{{ route('reportes.index') }}">Reportes</a>
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

        @if ($errors->any())
            <div class="error">
                @foreach ($errors->all() as $mensaje)
                    <div>{{ $mensaje }}</div>
                @endforeach
            </div>
        @endif

        @if ($bajos->isNotEmpty())
            <div class="alerta">
                <strong>Stock bajo en {{ $bajos->count() }} {{ $bajos->count() === 1 ? 'artículo' : 'artículos' }}:</strong>
                {{ $bajos->pluck('nombre_art')->implode(', ') }}
            </div>
        @endif

        <div class="tarjeta">
            <h2>Registrar artículo</h2>
            <form method="POST" action="{{ route('inventario.store') }}">
                @csrf
                <div class="fila">
                    <div class="campo">
                        <label for="nombre_art">Artículo</label>
                        <input type="text" id="nombre_art" name="nombre_art" value="{{ old('nombre_art') }}" required>
                    </div>
                    <div class="campo">
                        <label for="cantidad">Cantidad inicial</label>
                        <input type="number" id="cantidad" name="cantidad" min="0" value="{{ old('cantidad', 0) }}" required>
                    </div>
                    <div class="campo">
                        <label for="minimo">Mínimo de existencias</label>
                        <input type="number" id="minimo" name="minimo" min="0" value="{{ old('minimo', 1) }}" required>
                    </div>
                    <button type="submit" class="btn">Guardar artículo</button>
                </div>
            </form>
        </div>

        <div class="tarjeta">
            <h2>Inventario</h2>
            @if ($articulos->isEmpty())
                <p>Aún no hay artículos registrados.</p>
            @else
                <table>
                    <thead>
                        <tr><th>Artículo</th><th>Existencias</th><th>Mínimo</th><th>Estado</th><th>Entrada / salida</th><th></th></tr>
                    </thead>
                    <tbody>
                        @foreach ($articulos as $a)
                            @php $bajo = $a->cantidad <= $a->minimo; @endphp
                            <tr class="{{ $bajo ? 'bajo' : '' }}">
                                <td>{{ $a->nombre_art }}</td>
                                <td><strong>{{ $a->cantidad }}</strong></td>
                                <td>{{ $a->minimo }}</td>
                                <td>
                                    @if ($bajo)
                                        <span class="etiqueta-bajo">Stock bajo</span>
                                    @else
                                        <span class="etiqueta-ok">Normal</span>
                                    @endif
                                </td>
                                <td>
                                    <form method="POST" action="{{ route('inventario.movimiento', $a->id_inventario) }}" style="display:flex;gap:6px">
                                        @csrf
                                        <select name="tipo">
                                            <option value="entrada">Entrada</option>
                                            <option value="salida">Salida</option>
                                        </select>
                                        <input type="number" name="unidades" min="1" value="1" style="width:70px" required>
                                        <button type="submit" class="btn-chico">Aplicar</button>
                                    </form>
                                </td>
                                <td>
                                    <details>
                                        <summary>Editar</summary>
                                        <form method="POST" action="{{ route('inventario.update', $a->id_inventario) }}">
                                            @csrf
                                            @method('PUT')
                                            <input type="text" name="nombre_art" value="{{ $a->nombre_art }}" required>
                                            <input type="number" name="minimo" min="0" value="{{ $a->minimo }}" style="width:70px" required>
                                            <button type="submit" class="btn-chico">Guardar</button>
                                        </form>
                                    </details>
                                    <form method="POST" action="{{ route('inventario.destroy', $a->id_inventario) }}"
                                          onsubmit="return confirm('¿Eliminar este artículo?')">
                                        @csrf
                                        @method('DELETE')
                                        <button type="submit" class="borrar">Eliminar</button>
                                    </form>
                                </td>
                            </tr>
                        @endforeach
                    </tbody>
                </table>
            @endif
        </div>
    </main>
</body>
</html>