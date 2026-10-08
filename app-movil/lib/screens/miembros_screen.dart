import 'package:flutter/material.dart';
import '../services/miembro_service.dart';
import '../widgets/colores_app.dart';

class MiembrosScreen extends StatefulWidget {
  const MiembrosScreen({super.key});

  @override
  State<MiembrosScreen> createState() => _MiembrosScreenState();
}

class _MiembrosScreenState extends State<MiembrosScreen> {
  final MiembroService _service = MiembroService();
  List<dynamic> _miembros = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarMiembros();
  }

  Future<void> _cargarMiembros() async {
    setState(() => _cargando = true);
    try {
      final datos = await _service.listar();
      setState(() {
        _miembros = datos;
        _cargando = false;
      });
    } catch (e) {
      setState(() => _cargando = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar miembros: $e')),
        );
      }
    }
  }

  void _abrirFormulario({Map<String, dynamic>? miembro}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _FormularioMiembro(
        miembro: miembro,
        onGuardado: _cargarMiembros,
      ),
    );
  }

  Future<void> _eliminarMiembro(int id) async {
    try {
      await _service.eliminar(id);
      _cargarMiembros();
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
        title: const Text('Miembros'),
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : _miembros.isEmpty
              ? const Center(child: Text('No hay miembros registrados'))
              : RefreshIndicator(
                  onRefresh: _cargarMiembros,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _miembros.length,
                    itemBuilder: (context, index) {
                      final m = _miembros[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: ColoresApp.azulMedio,
                            child: Icon(Icons.person, color: Colors.white),
                          ),
                          title: Text(m['nombre']),
                          subtitle: Text('${m['departamento']} • ${m['telefono']}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: ColoresApp.azulMedio),
                                onPressed: () => _abrirFormulario(miembro: m),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: ColoresApp.error),
                                onPressed: () => _eliminarMiembro(m['id_miembro']),
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

class _FormularioMiembro extends StatefulWidget {
  final Map<String, dynamic>? miembro;
  final VoidCallback onGuardado;

  const _FormularioMiembro({this.miembro, required this.onGuardado});

  @override
  State<_FormularioMiembro> createState() => _FormularioMiembroState();
}

class _FormularioMiembroState extends State<_FormularioMiembro> {
  final _service = MiembroService();
  late TextEditingController _nombreCtrl;
  late TextEditingController _telefonoCtrl;
  late TextEditingController _departamentoCtrl;
  DateTime _fechaIngreso = DateTime.now();
  bool _guardando = false;

  bool get _esEdicion => widget.miembro != null;

  @override
  void initState() {
    super.initState();
    _nombreCtrl = TextEditingController(text: widget.miembro?['nombre'] ?? '');
    _telefonoCtrl = TextEditingController(text: widget.miembro?['telefono'] ?? '');
    _departamentoCtrl = TextEditingController(text: widget.miembro?['departamento'] ?? '');
    if (widget.miembro != null) {
      _fechaIngreso = DateTime.parse(widget.miembro!['fecha_ingreso']);
    }
  }

  Future<void> _guardar() async {
    if (_nombreCtrl.text.isEmpty || _telefonoCtrl.text.isEmpty || _departamentoCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa todos los campos')),
      );
      return;
    }

    setState(() => _guardando = true);

    final datos = {
      'nombre': _nombreCtrl.text,
      'telefono': _telefonoCtrl.text,
      'departamento': _departamentoCtrl.text,
      'fecha_ingreso': _fechaIngreso.toIso8601String().split('T')[0],
    };

    try {
      if (_esEdicion) {
        await _service.actualizar(widget.miembro!['id_miembro'], datos);
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
            _esEdicion ? 'Editar miembro' : 'Nuevo miembro',
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
            controller: _departamentoCtrl,
            decoration: const InputDecoration(labelText: 'Departamento', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('Fecha de ingreso: ${_fechaIngreso.toLocal().toString().split(' ')[0]}'),
            trailing: const Icon(Icons.calendar_today, color: ColoresApp.azulMedio),
            onTap: () async {
              final fecha = await showDatePicker(
                context: context,
                initialDate: _fechaIngreso,
                firstDate: DateTime(1950),
                lastDate: DateTime.now(),
              );
              if (fecha != null) setState(() => _fechaIngreso = fecha);
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