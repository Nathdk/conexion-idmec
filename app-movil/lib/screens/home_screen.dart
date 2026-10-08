import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../widgets/colores_app.dart';
import 'login_screen.dart';
import 'miembros_screen.dart';
import 'visitantes_screen.dart';
import 'asistencia_screen.dart';
import 'estadisticas_asistencia_screen.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  String? _nombre;
  String? _rol;

  @override
  void initState() {
    super.initState();
    _cargarSesion();
  }

  Future<void> _cargarSesion() async {
    final sesion = await _authService.obtenerSesion();
    setState(() {
      _nombre = sesion['nombre'];
      _rol = sesion['rol'];
    });
  }

  Future<void> _cerrarSesion() async {
    await _authService.cerrarSesion();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  // Define qué módulos ve cada rol
  List<_Modulo> _modulosSegunRol() {
    final modulos = <_Modulo>[
      _Modulo('Miembros', Icons.groups, () => const MiembrosScreen()),
      _Modulo('Visitantes', Icons.person_add, () => const VisitantesScreen()),
    ];

    if (_rol == 'Administrador') {
      modulos.addAll([
        _Modulo('Usuarios', Icons.admin_panel_settings, null),
        _Modulo('Asistencia', Icons.fact_check, () => const AsistenciaScreen()),
        _Modulo('Estadísticas', Icons.bar_chart, () => const EstadisticasAsistenciaScreen()),
        _Modulo('Eventos', Icons.event, null),
      ]);
    }
    return modulos;
  }

  @override
  Widget build(BuildContext context) {
    final modulos = _modulosSegunRol();

    return Scaffold(
      backgroundColor: ColoresApp.fondoClaro,
      appBar: AppBar(
        backgroundColor: ColoresApp.azulMarino,
        foregroundColor: Colors.white,
        title: Text(_nombre ?? 'CONEXIÓN IDMEC'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _cerrarSesion,
            tooltip: 'Cerrar sesión',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: modulos.length,
          itemBuilder: (context, index) {
            final modulo = modulos[index];
            return Card(
              color: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: modulo.pantalla == null
                    ? null
                    : () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => modulo.pantalla!()),
                        );
                      },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(modulo.icono, size: 40, color: ColoresApp.azulMedio),
                    const SizedBox(height: 8),
                    Text(modulo.nombre, style: const TextStyle(color: ColoresApp.grisOscuro)),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Modulo {
  final String nombre;
  final IconData icono;
  final Widget Function()? pantalla;
  _Modulo(this.nombre, this.icono, this.pantalla);
}