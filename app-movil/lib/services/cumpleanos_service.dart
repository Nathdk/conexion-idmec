import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';

class CumpleanosService {
  Future<List<dynamic>> listarPorMes(int mes) async {
    final respuesta = await http.get(Uri.parse('${ApiConfig.baseUrl}/cumpleanos/mes/$mes'));
    if (respuesta.statusCode == 200) {
      return jsonDecode(respuesta.body);
    }
    throw Exception('Error al consultar los cumpleaños');
  }
}