import 'package:flutter_test/flutter_test.dart';
import 'package:empty/flutter/cat/bemen3/m7/Samarretes/t_shirt_calculator_logic.dart';

void main() {
  group('TShirtCalculatorLogic', () {
      test('Prueba de rendimiento de calculatePrice', () {
      final stopwatch = Stopwatch()..start();

      for (int i = 0; i < 100000; i++) {
        TShirtCalculatorLogic.calculatePrice('medium', 15);
      }

      stopwatch.stop();
      print('Tiempo total para 100,000 ejecuciones: ${stopwatch.elapsedMilliseconds} ms');
      
      // Verificar que la ejecución se mantiene en un rango aceptable
      expect(stopwatch.elapsedMilliseconds, lessThan(5000)); // Menos de 5 segundos
    });

    test('Prueba de carga con múltiples ejecuciones en paralelo', () async {
      int numRequests = 10000; // Simular 10,000 llamadas
      List<Future> futures = [];

      for (int i = 0; i < numRequests; i++) {
        futures.add(Future(() {
          TShirtCalculatorLogic.calculatePrice('large', 20);
        }));
      }

      await Future.wait(futures);
      print('Finalizadas $numRequests peticiones concurrentes exitosamente');
    });

     test('Prueba de estrés aumentando la carga hasta fallo', () {
      int count = 0;
      bool hasFailed = false;

      try {
        while (true) {  // Bucle infinito hasta fallo
          TShirtCalculatorLogic.calculatePrice('small', 10);
          count++;
        }
      } catch (e) {
        hasFailed = true;
        print('Fallo detectado después de $count ejecuciones. Error: $e');
      }

      expect(hasFailed, isTrue);
    });

    test('calculatePrice without discount', () {
      expect(TShirtCalculatorLogic.calculatePrice('small', 15), 118.5);
      expect(TShirtCalculatorLogic.calculatePrice('medium', 15), 124.5);
      expect(TShirtCalculatorLogic.calculatePrice('large', 15), 190.5);
    });

    test('calculatePrice with discount', () {
      // No discount
      expect(TShirtCalculatorLogic.calculatePriceWithDiscount('small', 15, ''),118.5);
      // 10% discount
      expect(TShirtCalculatorLogic.calculatePriceWithDiscount('small', 15, '10%'),106.65);
      // 20€ discount, total > 100€
      expect(TShirtCalculatorLogic.calculatePriceWithDiscount('large', 15, '20€'),170.5);
      // 20€ discount, total < 100€
      expect(TShirtCalculatorLogic.calculatePriceWithDiscount('small', 10, '20€'),79.0);
    });
  });
}