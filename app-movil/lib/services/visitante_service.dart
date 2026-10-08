import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';

class VisitanteService {
  Future<List<dynamic>> listar() async {
    final respuesta = await http.get(Uri.parse('${ApiConfig.baseUrl}/visitantes'));
    if (respuesta.statusCode == 200) {
      return jsonDecode(respuesta.body);
    }
    throw Exception('Error al listar visitantes');
  }

  Future<void> crear(Map<String, dynamic> datos) async {
    final respuesta = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/visitantes'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(datos),
    );
    if (respuesta.statusCode != 201) {
      final error = jsonDecode(respuesta.body);
      throw Exception(error['mensaje'] ?? 'Error al crear visitante');
    }
  }

  Future<void> actualizar(int id, Map<String, dynamic> datos) async {
    final respuesta = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/visitantes/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(datos),
    );
    if (respuesta.statusCode != 200) {
      final error = jsonDecode(respuesta.body);
      throw Exception(error['mensaje'] ?? 'Error al actualizar visitante');
    }
  }

  Future<void> eliminar(int id) async {
    final respuesta = await http.delete(Uri.parse('${ApiConfig.baseUrl}/visitantes/$id'));
    if (respuesta.statusCode != 200) {
      throw Exception('Error al eliminar visitante');
    }
  }
}