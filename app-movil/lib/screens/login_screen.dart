import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../widgets/colores_app.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _correoController = TextEditingController();
  final _contrasenaController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _cargando = false;
  String? _error;

  Future<void> _iniciarSesion() async {
    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      final resultado = await _authService.login(
        _correoController.text.trim(),
        _contrasenaController.text.trim(),
      );

      if (resultado['exito']) {
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      } else {
        setState(() => _error = resultado['mensaje']);
      }
    } catch (e) {
      setState(() => _error = 'No se pudo conectar con el servidor. Revisa la dirección en el engranaje.');
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  Future<void> _configurarServidor() async {
    final controlador = TextEditingController(text: ApiConfig.baseUrl);

    final guardar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Dirección del servidor'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Pega la dirección que muestra el túnel (https://...trycloudflare.com).'),
            const SizedBox(height: 12),
            TextField(
              controller: controlador,
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await ApiConfig.restablecer();
              if (dialogContext.mounted) Navigator.pop(dialogContext, null);
            },
            child: const Text('Restablecer'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );

    if (guardar == true) {
      await ApiConfig.guardar(controlador.text);
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Servidor: ${ApiConfig.baseUrl}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColoresApp.fondoClaro,
      appBar: AppBar(
        backgroundColor: ColoresApp.fondoClaro,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: ColoresApp.grisMedio),
            tooltip: 'Servidor',
            onPressed: _configurarServidor,
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.church, size: 72, color: ColoresApp.azulMarino),
                const SizedBox(height: 12),
                const Text(
                  'CONEXIÓN IDMEC',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: ColoresApp.azulMarino,
                  ),
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: _correoController,
                  decoration: const InputDecoration(
                    labelText: 'Correo',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _contrasenaController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Contraseña',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(_error!, style: const TextStyle(color: ColoresApp.error)),
                  ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _cargando ? null : _iniciarSesion,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColoresApp.azulMedio,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: _cargando
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Iniciar sesión'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}