// integration_test/home_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:empty/flutter/cat/bemen3/m7/AppMovil/Applicacion.dart' as app;
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:camera/camera.dart';
import 'mocks.dart';  // Importa el archivo mocks.dart que contiene los mocks

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Captura una foto y la muestra en la galería con Mock', (tester) async {
    // Usar el mock para simular una cámara disponible
    final camera = MockCameraDescription();
    final cameras = [camera]; // Lista simulada de cámaras

    // Iniciar la aplicación con la cámara mockeada
    app.main();
    await tester.pumpAndSettle();

    // Simula la acción de capturar una foto
    await tester.tap(find.byIcon(Icons.camera_alt));  // Simula el clic en el botón de la cámara
    await tester.pumpAndSettle();

    // Verifica si la galería está mostrando imágenes (ya que se está usando un mock)
    expect(find.byIcon(Icons.photo_library), findsOneWidget);

    // Navega a la galería y verifica si las imágenes están presentes
    await tester.tap(find.byIcon(Icons.photo_library));
    await tester.pumpAndSettle();
    expect(find.byType(GridView), findsOneWidget);
  });

  testWidgets('Cambiar entre cámaras', (tester) async {
    //final cameras = await availableCameras();
    app.main();
    await tester.pumpAndSettle();

    // Verifica que el botón de cambiar cámara está presente
    expect(find.byIcon(Icons.switch_camera), findsOneWidget);

    // Toca el botón para cambiar de cámara
    await tester.tap(find.byIcon(Icons.switch_camera));
    await tester.pumpAndSettle();

    // Verifica que el botón sigue disponible después de cambiar la cámara
    expect(find.byIcon(Icons.switch_camera), findsOneWidget);
  });

  testWidgets('Reproducir música y pausar', (tester) async {
    final cameras = await availableCameras();
    app.main();
    await tester.pumpAndSettle();

    // Navega a la pantalla de música
    await tester.tap(find.byIcon(Icons.audiotrack));
    await tester.pumpAndSettle();

    // Verifica que el texto "Seleccione un audio" está presente
    expect(find.text('Seleccione un audio'), findsOneWidget);

    // Toca el botón de play para reproducir la música
    await tester.tap(find.byIcon(Icons.play_arrow));
    await tester.pumpAndSettle();

    // Verifica que el icono cambió a pause, indicando que la música está reproduciéndose
    expect(find.byIcon(Icons.pause), findsOneWidget);

    // Toca el botón de pause para pausar la música
    await tester.tap(find.byIcon(Icons.pause));
    await tester.pumpAndSettle();

    // Verifica que el icono cambió a play, indicando que la música está pausada
    expect(find.byIcon(Icons.play_arrow), findsOneWidget);
  });

  testWidgets('Adelantar y retroceder música', (tester) async {
    final cameras = await availableCameras();
    app.main();
    await tester.pumpAndSettle();

    // Navega a la pantalla de música
    await tester.tap(find.byIcon(Icons.audiotrack));
    await tester.pumpAndSettle();

    // Verifica que el texto "Seleccione un audio" está presente
    expect(find.text('Seleccione un audio'), findsOneWidget);

    // Toca el botón de adelantar 10 segundos
    await tester.tap(find.byIcon(Icons.forward_10));
    await tester.pumpAndSettle();

    // Toca el botón de retroceder 10 segundos
    await tester.tap(find.byIcon(Icons.replay_10));
    await tester.pumpAndSettle();

    // Verifica que ambos botones están visibles
    expect(find.byIcon(Icons.forward_10), findsOneWidget);
    expect(find.byIcon(Icons.replay_10), findsOneWidget);
  });
}
