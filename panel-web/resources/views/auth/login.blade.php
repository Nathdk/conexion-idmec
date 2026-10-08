<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CONEXIÓN IDMEC - Panel financiero</title>
    <style>
        body { margin: 0; font-family: Arial, sans-serif; background: #F7F7F5; display: flex; align-items: center; justify-content: center; min-height: 100vh; }
        .caja { background: #fff; padding: 32px; border-radius: 12px; width: 100%; max-width: 360px; box-shadow: 0 2px 10px rgba(0,0,0,.08); border-top: 5px solid #D4AF37; }
        h1 { color: #0F2A4A; font-size: 22px; text-align: center; margin: 0 0 4px; }
        p.sub { color: #8B95A3; text-align: center; margin: 0 0 24px; font-size: 14px; }
        label { display: block; color: #2C333D; font-size: 14px; margin-bottom: 4px; }
        input { width: 100%; padding: 10px; border: 1px solid #8B95A3; border-radius: 6px; margin-bottom: 16px; box-sizing: border-box; }
        button { width: 100%; padding: 12px; background: #1E4D7B; color: #fff; border: 0; border-radius: 6px; font-size: 16px; cursor: pointer; }
        button:hover { background: #0F2A4A; }
        .error { color: #B33A3A; font-size: 14px; margin-bottom: 12px; }
    </style>
</head>
<body>
    <div class="caja">
        <h1>CONEXIÓN IDMEC</h1>
        <p class="sub">Panel financiero</p>

        <form method="POST" action="{{ route('login') }}">
            @csrf
            @error('correo')
                <div class="error">{{ $message }}</div>
            @enderror

            <label for="correo">Correo</label>
            <input type="text" id="correo" name="correo" value="{{ old('correo') }}" required>

            <label for="contrasena">Contraseña</label>
            <input type="password" id="contrasena" name="contrasena" required>

            <button type="submit">Iniciar sesión</button>
        </form>
    </div>
</body>
</html>