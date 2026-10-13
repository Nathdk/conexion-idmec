import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';

class EventoService {
  Future<List<dynamic>> listar() async {
    final respuesta = await http.get(Uri.parse('${ApiConfig.baseUrl}/eventos'));
    if (respuesta.statusCode == 200) {
      return jsonDecode(respuesta.body);
    }
    throw Exception('Error al listar eventos');
  }

  Future<void> crear(Map<String, dynamic> datos) async {
    final respuesta = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/eventos'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(datos),
    );
    if (respuesta.statusCode != 201) {
      final error = jsonDecode(respuesta.body);
      throw Exception(error['mensaje'] ?? 'Error al crear evento');
    }
  }

  Future<void> actualizar(int id, Map<String, dynamic> datos) async {
    final respuesta = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/eventos/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(datos),
    );
    if (respuesta.statusCode != 200) {
      final error = jsonDecode(respuesta.body);
      throw Exception(error['mensaje'] ?? 'Error al actualizar evento');
    }
  }

  Future<void> eliminar(int id) async {
    final respuesta = await http.delete(Uri.parse('${ApiConfig.baseUrl}/eventos/$id'));
    if (respuesta.statusCode != 200) {
      throw Exception('Error al eliminar evento');
    }
  }
}