import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';

class MiembroService {
  Future<List<dynamic>> listar() async {
    final respuesta = await http.get(Uri.parse('${ApiConfig.baseUrl}/miembros'));
    if (respuesta.statusCode == 200) {
      return jsonDecode(respuesta.body);
    }
    throw Exception('Error al listar miembros');
  }

  Future<void> crear(Map<String, dynamic> datos) async {
    final respuesta = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/miembros'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(datos),
    );
    if (respuesta.statusCode != 201) {
      final error = jsonDecode(respuesta.body);
      throw Exception(error['mensaje'] ?? 'Error al crear miembro');
    }
  }

  Future<void> actualizar(int id, Map<String, dynamic> datos) async {
    final respuesta = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/miembros/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(datos),
    );
    if (respuesta.statusCode != 200) {
      final error = jsonDecode(respuesta.body);
      throw Exception(error['mensaje'] ?? 'Error al actualizar miembro');
    }
  }

  Future<void> eliminar(int id) async {
    final respuesta = await http.delete(Uri.parse('${ApiConfig.baseUrl}/miembros/$id'));
    if (respuesta.statusCode != 200) {
      throw Exception('Error al eliminar miembro');
    }
  }
}