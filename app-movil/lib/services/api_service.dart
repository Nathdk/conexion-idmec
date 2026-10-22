import 'package:shared_preferences/shared_preferences.dart';

class ApiConfig {
  // Dirección usada en casa, por WiFi
  static const String urlLocal = 'http://192.168.18.16:3000/api';

  static String baseUrl = urlLocal;

  // Carga la dirección guardada (si se configuró otra)
  static Future<void> cargar() async {
    final prefs = await SharedPreferences.getInstance();
    baseUrl = prefs.getString('api_url') ?? urlLocal;
  }

  // Guarda una dirección nueva. Acepta con o sin https:// y con o sin /api al final
  static Future<void> guardar(String direccion) async {
    var url = direccion.trim();
    if (url.isEmpty) return;
    if (!url.startsWith('http')) url = 'https://$url';
    while (url.endsWith('/')) {
      url = url.substring(0, url.length - 1);
    }
    if (!url.endsWith('/api')) url = '$url/api';

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('api_url', url);
    baseUrl = url;
  }

  // Vuelve a la dirección de casa
  static Future<void> restablecer() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('api_url');
    baseUrl = urlLocal;
  }
}