import 'package:flutter_test/flutter_test.dart';
import '../lib/calculations/bodysurfacearea.dart';

void main() {
  group('BSA Calculation Tests', () {

    // Test Mostellar method
    test('Mostellar method for height 170cm and weight 70kg', () {
      double result = calculateBSA(170, 70, BsaCalculationMethod.mostellar);
      expect(result.toStringAsFixed(2), '1.82'); // Expected BSA value
    });

    test('Mostellar method for height 160cm and weight 60kg', () {
      double result = calculateBSA(160, 60, BsaCalculationMethod.mostellar);
      expect(result.toStringAsFixed(2), '1.62'); // Expected BSA value
    });

    // Test Boyd method
    test('Boyd method for height 170cm and weight 70kg', () {
      double result = calculateBSA(170, 70, BsaCalculationMethod.boyd);
      expect(result.toStringAsFixed(2), '1.81'); // Expected BSA value
    });

    test('Boyd method for height 150cm and weight 50kg', () {
      double result = calculateBSA(150, 50, BsaCalculationMethod.boyd);
      expect(result.toStringAsFixed(2), '1.42'); // Expected BSA value
    });

    // Test DuBois method
    test('DuBois method for height 170cm and weight 70kg', () {
      double result = calculateBSA(170, 70, BsaCalculationMethod.dubois);
      expect(result.toStringAsFixed(2), '1.84'); // Expected BSA value
    });

    test('DuBois method for height 180cm and weight 90kg', () {
      double result = calculateBSA(180, 90, BsaCalculationMethod.dubois);
      expect(result.toStringAsFixed(2), '2.14'); // Expected BSA value
    });

    // Test Gehan and George method
    test('Gehan and George method for height 170cm and weight 70kg', () {
      double result = calculateBSA(170, 70, BsaCalculationMethod.gehangeorge);
      expect(result.toStringAsFixed(2), '1.83'); // Expected BSA value
    });

    test('Gehan and George method for height 160cm and weight 55kg', () {
      double result = calculateBSA(160, 55, BsaCalculationMethod.gehangeorge);
      expect(result.toStringAsFixed(2), '1.60'); // Expected BSA value
    });

    // Edge case tests
    test('Mostellar method with very low height and weight', () {
      double result = calculateBSA(50, 3, BsaCalculationMethod.mostellar);
      expect(result.toStringAsFixed(2), '0.15'); // Expected BSA value
    });

    test('DuBois method with very high height and weight', () {
      double result = calculateBSA(250, 150, BsaCalculationMethod.dubois);
      expect(result.toStringAsFixed(2), '3.84'); // Expected BSA value
    });

  });
}

