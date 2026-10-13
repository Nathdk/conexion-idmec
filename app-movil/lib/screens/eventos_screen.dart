import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/evento_service.dart';
import '../widgets/colores_app.dart';

class EventosScreen extends StatefulWidget {
  const EventosScreen({super.key});

  @override
  State<EventosScreen> createState() => _EventosScreenState();
}

class _EventosScreenState extends State<EventosScreen> {
  final EventoService _service = EventoService();
  final AuthService _authService = AuthService();
  List<dynamic> _eventos = [];
  bool _cargando = true;
  int? _idUsuario;

  String get _hoy => DateTime.now().toIso8601String().split('T')[0];

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() => _cargando = true);
    try {
      final sesion = await _authService.obtenerSesion();
      final datos = await _service.listar();
      setState(() {
        _idUsuario = sesion['id_usuario'];
        _eventos = datos;
        _cargando = false;
      });
    } catch (e) {
      setState(() => _cargando = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar eventos: $e')),
        );
      }
    }
  }

  void _abrirFormulario({Map<String, dynamic>? evento}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _FormularioEvento(
        evento: evento,
        idUsuario: _idUsuario,
        onGuardado: _cargar,
      ),
    );
  }

  Future<void> _eliminar(int id) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar evento'),
        content: const Text('Se eliminará el evento y sus recordatorios. ¿Continuar?'),
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
        title: const Text('Eventos'),
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : _eventos.isEmpty
              ? const Center(child: Text('No hay eventos registrados'))
              : RefreshIndicator(
                  onRefresh: _cargar,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _eventos.length,
                    itemBuilder: (context, index) {
                      final e = _eventos[index];
                      final pasado = (e['fecha'] as String).compareTo(_hoy) < 0;
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: pasado ? ColoresApp.grisMedio : ColoresApp.dorado,
                            child: Icon(
                              Icons.event,
                              color: pasado ? Colors.white : ColoresApp.azulMarino,
                            ),
                          ),
                          title: Text(
                            e['titulo'],
                            style: TextStyle(
                              color: pasado ? ColoresApp.grisMedio : ColoresApp.grisOscuro,
                            ),
                          ),
                          subtitle: Text('${e['fecha']}\n${e['descripcion']}'),
                          isThreeLine: true,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: ColoresApp.azulMedio),
                                onPressed: () => _abrirFormulario(evento: e),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: ColoresApp.error),
                                onPressed: () => _eliminar(e['id_evento']),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: ColoresApp.dorado,
        onPressed: () => _abrirFormulario(),
        child: const Icon(Icons.add, color: ColoresApp.azulMarino),
      ),
    );
  }
}

class _FormularioEvento extends StatefulWidget {
  final Map<String, dynamic>? evento;
  final int? idUsuario;
  final VoidCallback onGuardado;

  const _FormularioEvento({this.evento, required this.idUsuario, required this.onGuardado});

  @override
  State<_FormularioEvento> createState() => _FormularioEventoState();
}

class _FormularioEventoState extends State<_FormularioEvento> {
  final _service = EventoService();
  late TextEditingController _tituloCtrl;
  late TextEditingController _descripcionCtrl;
  DateTime _fecha = DateTime.now();
  bool _guardando = false;

  bool get _esEdicion => widget.evento != null;

  @override
  void initState() {
    super.initState();
    _tituloCtrl = TextEditingController(text: widget.evento?['titulo'] ?? '');
    _descripcionCtrl = TextEditingController(text: widget.evento?['descripcion'] ?? '');
    if (widget.evento != null) {
      _fecha = DateTime.parse(widget.evento!['fecha']);
    }
  }

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _descripcionCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (_tituloCtrl.text.trim().isEmpty || _descripcionCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa todos los campos')),
      );
      return;
    }

    setState(() => _guardando = true);

    final datos = {
      'titulo': _tituloCtrl.text.trim(),
      'descripcion': _descripcionCtrl.text.trim(),
      'fecha': _fecha.toIso8601String().split('T')[0],
      if (!_esEdicion) 'id_usuario': widget.idUsuario,
    };

    try {
      if (_esEdicion) {
        await _service.actualizar(widget.evento!['id_evento'], datos);
      } else {
        await _service.crear(datos);
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _esEdicion ? 'Editar evento' : 'Nuevo evento',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: ColoresApp.azulMarino),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _tituloCtrl,
            decoration: const InputDecoration(labelText: 'Título', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _descripcionCtrl,
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'Descripción', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('Fecha: ${_fecha.toIso8601String().split('T')[0]}'),
            trailing: const Icon(Icons.calendar_today, color: ColoresApp.azulMedio),
            onTap: () async {
              final fecha = await showDatePicker(
                context: context,
                initialDate: _fecha,
                firstDate: DateTime(2020),
                lastDate: DateTime(2035),
              );
              if (fecha != null) setState(() => _fecha = fecha);
            },
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