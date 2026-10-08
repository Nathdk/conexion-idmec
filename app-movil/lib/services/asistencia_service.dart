import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';

class AsistenciaService {
  Future<void> registrar(String fecha, int idLider, List<int> idsMiembros) async {
    final respuesta = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/asistencia'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'fecha': fecha, 'id_lider': idLider, 'ids_miembros': idsMiembros}),
    );
    if (respuesta.statusCode != 201) {
      final error = jsonDecode(respuesta.body);
      throw Exception(error['mensaje'] ?? 'Error al registrar asistencia');
    }
  }

  Future<List<dynamic>> listarPorFecha(String fecha) async {
    final respuesta = await http.get(Uri.parse('${ApiConfig.baseUrl}/asistencia/fecha/$fecha'));
    if (respuesta.statusCode == 200) {
      return jsonDecode(respuesta.body);
    }
    throw Exception('Error al listar asistencia');
  }

  Future<List<dynamic>> historialPorMiembro(int idMiembro) async {
    final respuesta = await http.get(Uri.parse('${ApiConfig.baseUrl}/asistencia/miembro/$idMiembro'));
    if (respuesta.statusCode == 200) {
      return jsonDecode(respuesta.body);
    }
    throw Exception('Error al obtener historial');
  }

  Future<List<dynamic>> estadisticas() async {
    final respuesta = await http.get(Uri.parse('${ApiConfig.baseUrl}/asistencia/estadisticas'));
    if (respuesta.statusCode == 200) {
      return jsonDecode(respuesta.body);
    }
    throw Exception('Error al obtener estadísticas');
  }
}