import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'services/auth_service.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'widgets/colores_app.dart';

// Permite mostrar avisos desde cualquier parte de la app
final GlobalKey<ScaffoldMessengerState> mensajeroKey = GlobalKey<ScaffoldMessengerState>();

Future<void> _configurarNotificaciones() async {
  try {
    final mensajero = FirebaseMessaging.instance;
    await mensajero.requestPermission(); // Android 13 o superior pide permiso
    await mensajero.subscribeToTopic('eventos'); // recibe los avisos de eventos

    // Con la app abierta, Android no muestra la notificación sola: la mostramos como aviso
    FirebaseMessaging.onMessage.listen((mensaje) {
      final notificacion = mensaje.notification;
      if (notificacion == null) return;
      mensajeroKey.currentState?.showSnackBar(
        SnackBar(
          content: Text('${notificacion.title ?? ''}\n${notificacion.body ?? ''}'),
          duration: const Duration(seconds: 8),
        ),
      );
    });
  } catch (e) {
    debugPrint('No se pudieron configurar las notificaciones: $e');
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
  _configurarNotificaciones();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CONEXIÓN IDMEC',
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: mensajeroKey,
      theme: ThemeData(
        primaryColor: ColoresApp.azulMarino,
        scaffoldBackgroundColor: ColoresApp.fondoClaro,
        colorScheme: ColorScheme.fromSeed(
          seedColor: ColoresApp.azulMarino,
          primary: ColoresApp.azulMarino,
        ),
      ),
      home: const _PantallaInicial(),
    );
  }
}

class _PantallaInicial extends StatelessWidget {
  const _PantallaInicial();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: AuthService().sesionActiva(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final haySesion = snapshot.data ?? false;
        return haySesion ? const HomeScreen() : const LoginScreen();
      },
    );
  }
}