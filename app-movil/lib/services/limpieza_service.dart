import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';

class LimpiezaService {
  Future<List<dynamic>> listarPorSemana(String fecha) async {
    final respuesta = await http.get(Uri.parse('${ApiConfig.baseUrl}/limpieza/semana/$fecha'));
    if (respuesta.statusCode == 200) {
      return jsonDecode(respuesta.body);
    }
    throw Exception('Error al listar la limpieza de la semana');
  }

  Future<void> crear(Map<String, dynamic> datos) async {
    final respuesta = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/limpieza'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(datos),
    );
    if (respuesta.statusCode != 201) {
      final error = jsonDecode(respuesta.body);
      throw Exception(error['mensaje'] ?? 'Error al registrar la asignación');
    }
  }

  Future<void> actualizar(int id, Map<String, dynamic> datos) async {
    final respuesta = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/limpieza/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(datos),
    );
    if (respuesta.statusCode != 200) {
      final error = jsonDecode(respuesta.body);
      throw Exception(error['mensaje'] ?? 'Error al actualizar la asignación');
    }
  }

  Future<void> eliminar(int id) async {
    final respuesta = await http.delete(Uri.parse('${ApiConfig.baseUrl}/limpieza/$id'));
    if (respuesta.statusCode != 200) {
      throw Exception('Error al eliminar la asignación');
    }
  }
}