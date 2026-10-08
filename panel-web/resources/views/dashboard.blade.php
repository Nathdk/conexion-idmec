<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Panel financiero</title>
    <style>
        body { margin: 0; font-family: Arial, sans-serif; background: #F7F7F5; }
        header { background: #0F2A4A; color: #fff; padding: 16px 24px; display: flex; justify-content: space-between; align-items: center; }
        header button { background: #D4AF37; color: #0F2A4A; border: 0; padding: 8px 14px; border-radius: 6px; cursor: pointer; }
        main { padding: 24px; color: #2C333D; }
    </style>
</head>
<body>
    <header>
        <strong>CONEXIÓN IDMEC · Panel financiero</strong>
        <form method="POST" action="{{ route('logout') }}">
            @csrf
            <button type="submit">Cerrar sesión</button>
        </form>
    </header>
    <main>
        <h2>Bienvenida, {{ auth()->user()->nombre }}</h2>
        <p>Rol: {{ auth()->user()->rol }}</p>
	<p><a href="{{ route('ingresos.index') }}" style="color:#1E4D7B;font-weight:bold">Ir a Ingresos →</a></p>
	<p><a href="{{ route('egresos.index') }}" style="color:#1E4D7B;font-weight:bold">Ir a Egresos →</a></p>
    </main>
</body>
</html>