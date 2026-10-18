import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/limpieza_service.dart';
import '../services/miembro_service.dart';
import '../widgets/colores_app.dart';

const _meses = [
  'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
  'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre',
];

class LimpiezaScreen extends StatefulWidget {
  const LimpiezaScreen({super.key});

  @override
  State<LimpiezaScreen> createState() => _LimpiezaScreenState();
}

class _LimpiezaScreenState extends State<LimpiezaScreen> {
  final LimpiezaService _service = LimpiezaService();
  final AuthService _authService = AuthService();
  List<dynamic> _asignaciones = [];
  bool _cargando = true;
  int? _idLider;
  late DateTime _lunes;

  @override
  void initState() {
    super.initState();
    final hoy = DateTime.now();
    _lunes = DateTime(hoy.year, hoy.month, hoy.day - (hoy.weekday - 1));
    _cargar();
  }

  String _fmt(DateTime d) => d.toIso8601String().split('T')[0];

  String get _rango {
    final domingo = DateTime(_lunes.year, _lunes.month, _lunes.day + 6);
    final inicio = _lunes.month == domingo.month
        ? '${_lunes.day}'
        : '${_lunes.day} de ${_meses[_lunes.month - 1]}';
    return '$inicio al ${domingo.day} de ${_meses[domingo.month - 1]} de ${domingo.year}';
  }

  Future<void> _cargar() async {
    setState(() => _cargando = true);
    try {
      final sesion = await _authService.obtenerSesion();
      final datos = await _service.listarPorSemana(_fmt(_lunes));
      setState(() {
        _idLider = sesion['id_usuario'];
        _asignaciones = datos;
        _cargando = false;
      });
    } catch (e) {
      setState(() => _cargando = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar la limpieza: $e')),
        );
      }
    }
  }

  void _cambiarSemana(int semanas) {
    setState(() {
      _lunes = DateTime(_lunes.year, _lunes.month, _lunes.day + 7 * semanas);
    });
    _cargar();
  }

  void _abrirFormulario({Map<String, dynamic>? asignacion}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _FormularioLimpieza(
        asignacion: asignacion,
        fecha: _fmt(_lunes),
        idLider: _idLider,
        onGuardado: _cargar,
      ),
    );
  }

  Future<void> _eliminar(int id) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar asignación'),
        content: const Text('¿Quitar esta persona de la limpieza de la semana?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Eliminar', style: TextStyle(color: ColoresApp.error)),
          ),
        ],
      ),
    );
    if (confirmar != true) return;

    try {
      await _service.eliminar(id);
      _cargar();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar: $e')),
        );
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
        title: const Text('Limpieza semanal'),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left, color: ColoresApp.azulMedio),
                  onPressed: () => _cambiarSemana(-1),
                ),
                Expanded(
                  child: Text(
                    'Semana del $_rango',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: ColoresApp.azulMarino,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right, color: ColoresApp.azulMedio),
                  onPressed: () => _cambiarSemana(1),
                ),
              ],
            ),
          ),
          Expanded(
            child: _cargando
                ? const Center(child: CircularProgressIndicator())
                : _asignaciones.isEmpty
                    ? const Center(child: Text('No hay asignaciones para esta semana'))
                    : RefreshIndicator(
                        onRefresh: _cargar,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: _asignaciones.length,
                          itemBuilder: (context, index) {
                            final a = _asignaciones[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 10),
                              child: ListTile(
                                leading: const CircleAvatar(
                                  backgroundColor: ColoresApp.dorado,
                                  child: Icon(Icons.cleaning_services, color: ColoresApp.azulMarino),
                                ),
                                title: Text(a['nombre_miembro']),
                                subtitle: Text(a['tarea']),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: ColoresApp.azulMedio),
                                      onPressed: () => _abrirFormulario(asignacion: a),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: ColoresApp.error),
                                      onPressed: () => _eliminar(a['id_limpieza']),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: ColoresApp.dorado,
        onPressed: () => _abrirFormulario(),
        child: const Icon(Icons.add, color: ColoresApp.azulMarino),
      ),
    );
  }
}

class _FormularioLimpieza extends StatefulWidget {
  final Map<String, dynamic>? asignacion;
  final String fecha;
  final int? idLider;
  final VoidCallback onGuardado;

  const _FormularioLimpieza({
    this.asignacion,
    required this.fecha,
    required this.idLider,
    required this.onGuardado,
  });

  @override
  State<_FormularioLimpieza> createState() => _FormularioLimpiezaState();
}

class _FormularioLimpiezaState extends State<_FormularioLimpieza> {
  final _service = LimpiezaService();
  final _miembroService = MiembroService();
  final _tareaCtrl = TextEditingController();
  List<dynamic> _miembros = [];
  int? _idMiembro;
  bool _cargando = true;
  bool _guardando = false;

  bool get _esEdicion => widget.asignacion != null;

  @override
  void initState() {
    super.initState();
    _tareaCtrl.text = widget.asignacion?['tarea'] ?? '';
    _cargarMiembros();
  }

  @override
  void dispose() {
    _tareaCtrl.dispose();
    super.dispose();
  }

  Future<void> _cargarMiembros() async {
    try {
      final miembros = await _miembroService.listar();
      final actual = widget.asignacion?['id_miembro'] as int?;
      setState(() {
        _miembros = miembros;
        _idMiembro = miembros.any((m) => m['id_miembro'] == actual) ? actual : null;
        _cargando = false;
      });
    } catch (e) {
      setState(() => _cargando = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar los miembros: $e')),
        );
      }
    }
  }

  Future<void> _guardar() async {
    if (_idMiembro == null || _tareaCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Elige una persona y escribe la tarea')),
      );
      return;
    }

    setState(() => _guardando = true);

    try {
      if (_esEdicion) {
        await _service.actualizar(widget.asignacion!['id_limpieza'], {
          'id_miembro': _idMiembro,
          'tarea': _tareaCtrl.text.trim(),
        });
      } else {
        await _service.crear({
          'fecha': widget.fecha,
          'id_miembro': _idMiembro,
          'tarea': _tareaCtrl.text.trim(),
          'id_lider': widget.idLider,
        });
      }
      widget.onGuardado();
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      setState(() => _guardando = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20, right: 20, top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: _cargando
          ? const SizedBox(height: 120, child: Center(child: CircularProgressIndicator()))
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _esEdicion ? 'Editar asignación' : 'Nueva asignación',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: ColoresApp.azulMarino,
                  ),
                ),
                const SizedBox(height: 16),
                InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Persona responsable',
                    border: OutlineInputBorder(),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: _idMiembro,
                      isExpanded: true,
                      hint: const Text('Selecciona una persona'),
                      items: _miembros
                          .map<DropdownMenuItem<int>>((m) => DropdownMenuItem<int>(
                                value: m['id_miembro'] as int,
                                child: Text(m['nombre']),
                              ))
                          .toList(),
                      onChanged: (valor) => setState(() => _idMiembro = valor),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _tareaCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Tarea (ej. Baños, Salón principal)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _guardando ? null : _guardar,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColoresApp.azulMedio,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: _guardando
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Guardar'),
                  ),
                ),
              ],
            ),
    );
  }
}