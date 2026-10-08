import 'package:flutter/material.dart';
import '../services/asistencia_service.dart';
import '../widgets/colores_app.dart';

class EstadisticasAsistenciaScreen extends StatefulWidget {
  const EstadisticasAsistenciaScreen({super.key});

  @override
  State<EstadisticasAsistenciaScreen> createState() => _EstadisticasAsistenciaScreenState();
}

class _EstadisticasAsistenciaScreenState extends State<EstadisticasAsistenciaScreen> {
  final _service = AsistenciaService();
  List<dynamic> _estadisticas = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() => _cargando = true);
    try {
      final datos = await _service.estadisticas();
      setState(() {
        _estadisticas = datos;
        _cargando = false;
      });
    } catch (e) {
      setState(() => _cargando = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColoresApp.fondoClaro,
      appBar: AppBar(
        backgroundColor: ColoresApp.azulMarino,
        foregroundColor: Colors.white,
        title: const Text('Estadísticas de asistencia'),
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : _estadisticas.isEmpty
              ? const Center(child: Text('Aún no hay registros de asistencia'))
              : RefreshIndicator(
                  onRefresh: _cargar,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _estadisticas.length,
                    itemBuilder: (context, index) {
                      final e = _estadisticas[index];
                      final total = e['total_asistencias'] ?? 0;
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: ColoresApp.dorado,
                            child: Text(
                              '$total',
                              style: const TextStyle(color: ColoresApp.azulMarino, fontWeight: FontWeight.bold),
                            ),
                          ),
                          title: Text(e['nombre']),
                          subtitle: Text('$total asistencia${total == 1 ? '' : 's'} registrada${total == 1 ? '' : 's'}'),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}