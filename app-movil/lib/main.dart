import 'package:flutter/material.dart';
import 'services/auth_service.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'widgets/colores_app.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CONEXIÓN IDMEC',
      debugShowCheckedModeBanner: false,
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