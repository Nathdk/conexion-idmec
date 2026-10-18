import 'package:flutter/material.dart';
import '../services/cumpleanos_service.dart';
import '../widgets/colores_app.dart';

const _meses = [
  'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
  'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre',
];

class CumpleanosScreen extends StatefulWidget {
  const CumpleanosScreen({super.key});

  @override
  State<CumpleanosScreen> createState() => _CumpleanosScreenState();
}

class _CumpleanosScreenState extends State<CumpleanosScreen> {
  final CumpleanosService _service = CumpleanosService();
  List<dynamic> _cumpleanos = [];
  bool _cargando = true;
  late int _mes;

  @override
  void initState() {
    super.initState();
    _mes = DateTime.now().month;
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() => _cargando = true);
    try {
      final datos = await _service.listarPorMes(_mes);
      setState(() {
        _cumpleanos = datos;
        _cargando = false;
      });
    } catch (e) {
      setState(() => _cargando = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void _cambiarMes(int delta) {
    setState(() => _mes = ((_mes - 1 + delta) % 12) + 1);
    _cargar();
  }

  @override
  Widget build(BuildContext context) {
    final hoy = DateTime.now();

    return Scaffold(
      backgroundColor: ColoresApp.fondoClaro,
      appBar: AppBar(
        backgroundColor: ColoresApp.azulMarino,
        foregroundColor: Colors.white,
        title: const Text('Cumpleaños'),
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
                  onPressed: () => _cambiarMes(-1),
                ),
                Expanded(
                  child: Text(
                    _meses[_mes - 1],
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: ColoresApp.azulMarino,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right, color: ColoresApp.azulMedio),
                  onPressed: () => _cambiarMes(1),
                ),
              ],
            ),
          ),
          Expanded(
            child: _cargando
                ? const Center(child: CircularProgressIndicator())
                : _cumpleanos.isEmpty
                    ? const Center(child: Text('No hay cumpleaños registrados este mes'))
                    : RefreshIndicator(
                        onRefresh: _cargar,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: _cumpleanos.length,
                          itemBuilder: (context, index) {
                            final c = _cumpleanos[index];
                            final esHoy = c['dia'] == hoy.day && _mes == hoy.month;
                            final anioNacimiento = int.parse((c['fecha_nacimiento'] as String).split('-')[0]);
                            final edad = hoy.year - anioNacimiento;

                            return Card(
                              margin: const EdgeInsets.only(bottom: 10),
                              color: esHoy ? const Color(0x40D4AF37) : null,
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: esHoy ? ColoresApp.dorado : ColoresApp.azulMedio,
                                  child: Text(
                                    '${c['dia']}',
                                    style: TextStyle(
                                      color: esHoy ? ColoresApp.azulMarino : Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                title: Text(c['nombre']),
                                subtitle: Text(
                                  '${c['departamento']} • cumple $edad años${esHoy ? ' • ¡Hoy!' : ''}',
                                ),
                                trailing: esHoy
                                    ? const Icon(Icons.cake, color: ColoresApp.dorado)
                                    : null,
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}