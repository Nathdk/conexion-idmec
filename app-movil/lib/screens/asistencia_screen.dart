import 'package:flutter/material.dart';
import '../services/asistencia_service.dart';
import '../services/miembro_service.dart';
import '../services/auth_service.dart';
import '../widgets/colores_app.dart';

class AsistenciaScreen extends StatefulWidget {
  const AsistenciaScreen({super.key});

  @override
  State<AsistenciaScreen> createState() => _AsistenciaScreenState();
}

class _AsistenciaScreenState extends State<AsistenciaScreen> {
  final _asistenciaService = AsistenciaService();
  final _miembroService = MiembroService();
  final _authService = AuthService();

  List<dynamic> _miembros = [];
  Set<int> _seleccionados = {};
  DateTime _fecha = DateTime.now();
  bool _cargando = true;
  bool _guardando = false;
  int? _idLider;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    setState(() => _cargando = true);
    try {
      final sesion = await _authService.obtenerSesion();
      final miembros = await _miembroService.listar();
      setState(() {
        _idLider = sesion['id_usuario'];
        _miembros = miembros;
        _cargando = false;
      });
    } catch (e) {
      setState(() => _cargando = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _guardarAsistencia() async {
    if (_seleccionados.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona al menos un miembro')),
      );
      return;
    }

    setState(() => _guardando = true);
    final fechaTexto = _fecha.toIso8601String().split('T')[0];

    try {
      await _asistenciaService.registrar(fechaTexto, _idLider!, _seleccionados.toList());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Asistencia registrada correctamente'), backgroundColor: ColoresApp.exito),
        );
        setState(() => _seleccionados = {});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    } finally {
      setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColoresApp.fondoClaro,
      appBar: AppBar(
        backgroundColor: ColoresApp.azulMarino,
        foregroundColor: Colors.white,
        title: const Text('Registrar asistencia'),
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: ListTile(
                    tileColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    title: Text('Fecha: ${_fecha.toLocal().toString().split(' ')[0]}'),
                    trailing: const Icon(Icons.calendar_today, color: ColoresApp.azulMedio),
                    onTap: () async {
                      final fecha = await showDatePicker(
                        context: context,
                        initialDate: _fecha,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (fecha != null) setState(() => _fecha = fecha);
                    },
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _miembros.length,
                    itemBuilder: (context, index) {
                      final m = _miembros[index];
                      final id = m['id_miembro'] as int;
                      final marcado = _seleccionados.contains(id);
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: CheckboxListTile(
                          value: marcado,
                          activeColor: ColoresApp.azulMedio,
                          title: Text(m['nombre']),
                          subtitle: Text(m['departamento']),
                          onChanged: (valor) {
                            setState(() {
                              if (valor == true) {
                                _seleccionados.add(id);
                              } else {
                                _seleccionados.remove(id);
                              }
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _guardando ? null : _guardarAsistencia,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColoresApp.azulMedio,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: _guardando
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text('Guardar asistencia (${_seleccionados.length} seleccionados)'),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}