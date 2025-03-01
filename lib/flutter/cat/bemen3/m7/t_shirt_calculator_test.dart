import 'package:flutter_test/flutter_test.dart';
import 'package:empty/flutter/cat/bemen3/m7/t_shirt_calculator_logic.dart';

void main() {
  group('TShirtCalculatorLogic', () {
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