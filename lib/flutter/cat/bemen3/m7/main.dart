import 'package:flutter/material.dart';
import 'package:empty/flutter/cat/bemen3/m7/t_shirt_app.dart';  // Asegúrate de importar correctamente

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Calculadora de Samarretes',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const TShirtCalculatorScreen(), // Usa tu pantalla aquí
    );
  }
}
