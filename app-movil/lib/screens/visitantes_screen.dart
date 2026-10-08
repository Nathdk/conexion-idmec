import 'package:flutter/material.dart';
import '../services/visitante_service.dart';
import '../widgets/colores_app.dart';

class VisitantesScreen extends StatefulWidget {
  const VisitantesScreen({super.key});

  @override
  State<VisitantesScreen> createState() => _VisitantesScreenState();
}

class _VisitantesScreenState extends State<VisitantesScreen> {
  final VisitanteService _service = VisitanteService();
  List<dynamic> _visitantes = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarVisitantes();
  }

  Future<void> _cargarVisitantes() async {
    setState(() => _cargando = true);
    try {
      final datos = await _service.listar();
      setState(() {
        _visitantes = datos;
        _cargando = false;
      });
    } catch (e) {
      setState(() => _cargando = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar visitantes: $e')),
        );
      }
    }
  }

  void _abrirFormulario({Map<String, dynamic>? visitante}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _FormularioVisitante(
        visitante: visitante,
        onGuardado: _cargarVisitantes,
      ),
    );
  }

  Future<void> _eliminarVisitante(int id) async {
    try {
      await _service.eliminar(id);
      _cargarVisitantes();
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
        title: const Text('Visitantes'),
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : _visitantes.isEmpty
              ? const Center(child: Text('No hay visitantes registrados'))
              : RefreshIndicator(
                  onRefresh: _cargarVisitantes,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _visitantes.length,
                    itemBuilder: (context, index) {
                      final v = _visitantes[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: ColoresApp.dorado,
                            child: Icon(Icons.person_outline, color: ColoresApp.azulMarino),
                          ),
                          title: Text(v['nombre']),
                          subtitle: Text('${v['servicio']} • ${v['telefono']}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: ColoresApp.azulMedio),
                                onPressed: () => _abrirFormulario(visitante: v),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: ColoresApp.error),
                                onPressed: () => _eliminarVisitante(v['id_visitante']),
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

class _FormularioVisitante extends StatefulWidget {
  final Map<String, dynamic>? visitante;
  final VoidCallback onGuardado;

  const _FormularioVisitante({this.visitante, required this.onGuardado});

  @override
  State<_FormularioVisitante> createState() => _FormularioVisitanteState();
}

class _FormularioVisitanteState extends State<_FormularioVisitante> {
  final _service = VisitanteService();
  late TextEditingController _nombreCtrl;
  late TextEditingController _telefonoCtrl;
  late TextEditingController _servicioCtrl;
  DateTime _fechaVisita = DateTime.now();
  bool _guardando = false;

  bool get _esEdicion => widget.visitante != null;

  @override
  void initState() {
    super.initState();
    _nombreCtrl = TextEditingController(text: widget.visitante?['nombre'] ?? '');
    _telefonoCtrl = TextEditingController(text: widget.visitante?['telefono'] ?? '');
    _servicioCtrl = TextEditingController(text: widget.visitante?['servicio'] ?? '');
    if (widget.visitante != null) {
      _fechaVisita = DateTime.parse(widget.visitante!['fecha_visita']);
    }
  }

  Future<void> _guardar() async {
    if (_nombreCtrl.text.isEmpty || _telefonoCtrl.text.isEmpty || _servicioCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa todos los campos')),
      );
      return;
    }

    setState(() => _guardando = true);

    final datos = {
      'nombre': _nombreCtrl.text,
      'telefono': _telefonoCtrl.text,
      'servicio': _servicioCtrl.text,
      'fecha_visita': _fechaVisita.toIso8601String().split('T')[0],
    };

    try {
      if (_esEdicion) {
        await _service.actualizar(widget.visitante!['id_visitante'], datos);
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
            _esEdicion ? 'Editar visitante' : 'Nuevo visitante',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: ColoresApp.azulMarino),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _nombreCtrl,
            decoration: const InputDecoration(labelText: 'Nombre', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _telefonoCtrl,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(labelText: 'Teléfono', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _servicioCtrl,
            decoration: const InputDecoration(labelText: 'Servicio (ej. Dominical)', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('Fecha de visita: ${_fechaVisita.toLocal().toString().split(' ')[0]}'),
            trailing: const Icon(Icons.calendar_today, color: ColoresApp.azulMedio),
            onTap: () async {
              final fecha = await showDatePicker(
                context: context,
                initialDate: _fechaVisita,
                firstDate: DateTime(2020),
                lastDate: DateTime.now().add(const Duration(days: 1)),
              );
              if (fecha != null) setState(() => _fechaVisita = fecha);
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