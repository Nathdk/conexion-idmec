import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class AuthService {
  Future<Map<String, dynamic>> login(String correo, String contrasena) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/auth/login');
    final respuesta = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'correo': correo, 'contrasena': contrasena}),
    );

    final datos = jsonDecode(respuesta.body);

    if (respuesta.statusCode == 200) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', datos['token']);
      await prefs.setString('nombre', datos['usuario']['nombre']);
      await prefs.setString('rol', datos['usuario']['rol']);
      await prefs.setInt('id_usuario', datos['usuario']['id_usuario']);
      return {'exito': true, 'datos': datos};
    } else {
      return {'exito': false, 'mensaje': datos['mensaje'] ?? 'Error al iniciar sesión'};
    }
  }

  Future<bool> sesionActiva() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') != null;
  }

  Future<Map<String, dynamic>> obtenerSesion() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'token': prefs.getString('token'),
      'nombre': prefs.getString('nombre'),
      'rol': prefs.getString('rol'),
      'id_usuario': prefs.getInt('id_usuario'),
    };
  }
  Future<void> cerrarSesion() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}