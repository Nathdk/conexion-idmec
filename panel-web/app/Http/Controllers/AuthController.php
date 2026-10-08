<?php

namespace App\Http\Controllers;

use App\Models\Usuario;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;

class AuthController extends Controller
{
    public function mostrarLogin()
    {
        if (Auth::check()) {
            return redirect()->route('dashboard');
        }
        return view('auth.login');
    }

    public function login(Request $request)
    {
        $datos = $request->validate([
            'correo' => 'required|string',
            'contrasena' => 'required|string',
        ]);

        $usuario = Usuario::where('correo', $datos['correo'])->first();

        if (!$usuario || !Hash::check($datos['contrasena'], $usuario->contrasena)) {
            return back()
                ->withErrors(['correo' => 'Correo o contraseña incorrectos'])
                ->withInput($request->only('correo'));
        }

        if (!in_array($usuario->rol, ['Tesorero', 'Administrador'])) {
            return back()
                ->withErrors(['correo' => 'No tienes acceso al panel financiero'])
                ->withInput($request->only('correo'));
        }

        Auth::login($usuario);
        $request->session()->regenerate();

        return redirect()->route('dashboard');
    }

    public function logout(Request $request)
    {
        Auth::logout();
        $request->session()->invalidate();
        $request->session()->regenerateToken();

        return redirect()->route('login');
    }
}