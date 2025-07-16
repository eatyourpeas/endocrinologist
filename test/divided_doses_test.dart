// test/divided_doses_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:endocrinologist/calculations/glucocorticoidmaths.dart';

void main() {
  group('dividedDoses Function Tests', () {
    // Helper function to sum doses for verification
    double sumDoses(List<double> doses) {
      return doses.fold(0.0, (prev, element) => prev + element);
    }

    // Helper to check if all doses are multiples of 1.25
    bool areAllMultiplesOf(List<double> doses, double multiple) {
      const double tolerance = 0.00001;
      return doses.every((dose) => (dose % multiple).abs() < tolerance || (dose % multiple).abs() > (multiple - tolerance) );
    }

    test('Test Case 1: Original Dose = 7.0, Number of Doses = 3', () {
      double originalDose = 7.0;
      int numberOfDoses = 3;
      List<double> result = dividedDoses(originalDose, numberOfDoses);

      // Expected: TargetTotalDose = 7.5. Doses like [2.5, 2.5, 2.5]
      expect(result.length, numberOfDoses);
      expect(sumDoses(result), greaterThanOrEqualTo(originalDose));
      expect(sumDoses(result), closeTo(7.5, 0.00001)); // Sum should be the rounded up total
      expect(areAllMultiplesOf(result, 1.25), isTrue);
      // More specific check if the distribution pattern is critical
      expect(result, orderedEquals([2.5, 2.5, 2.5]));
    });

    test('Test Case 2: Original Dose = 6.0, Number of Doses = 3', () {
      double originalDose = 6.0;
      int numberOfDoses = 3;
      List<double> result = dividedDoses(originalDose, numberOfDoses);

      // Expected: TargetTotalDose = 6.25. Doses like [2.5, 2.5, 1.25]
      expect(result.length, numberOfDoses);
      expect(sumDoses(result), greaterThanOrEqualTo(originalDose));
      expect(sumDoses(result), closeTo(6.25, 0.00001));
      expect(areAllMultiplesOf(result, 1.25), isTrue);
      // The order might vary if the distribution of the remainder changes,
      // so you might sort them or check for content if order isn't guaranteed.
      // For now, assuming your current distribution is consistent:
      expect(result, orderedEquals([2.5, 2.5, 1.25]));
    });

    test('Test Case 3: Original Dose = 10.0, Number of Doses = 3', () {
      double originalDose = 10.0;
      int numberOfDoses = 3;
      List<double> result = dividedDoses(originalDose, numberOfDoses);

      // Expected: TargetTotalDose = 10.0. Doses like [3.75, 3.75, 2.5]
      expect(result.length, numberOfDoses);
      expect(sumDoses(result), greaterThanOrEqualTo(originalDose));
      expect(sumDoses(result), closeTo(10.0, 0.00001));
      expect(areAllMultiplesOf(result, 1.25), isTrue);
      expect(result, orderedEquals([3.75, 3.75, 2.5]));
    });

    test('Test Case 4: Original Dose = 0.1, Number of Doses = 1', () {
      double originalDose = 0.1;
      int numberOfDoses = 1;
      List<double> result = dividedDoses(originalDose, numberOfDoses);

      // Expected: TargetTotalDose = 1.25. Doses [1.25]
      expect(result.length, numberOfDoses);
      expect(sumDoses(result), greaterThanOrEqualTo(originalDose));
      expect(sumDoses(result), closeTo(1.25, 0.00001));
      expect(areAllMultiplesOf(result, 1.25), isTrue);
      expect(result, orderedEquals([1.25]));
    });

    test('Test Case 5: Original Dose = 2.4, Number of Doses = 2', () {
      double originalDose = 2.4;
      int numberOfDoses = 2;
      List<double> result = dividedDoses(originalDose, numberOfDoses);

      // Expected: TargetTotalDose = 2.5. Doses [1.25, 1.25]
      expect(result.length, numberOfDoses);
      expect(sumDoses(result), greaterThanOrEqualTo(originalDose));
      expect(sumDoses(result), closeTo(2.5, 0.00001));
      expect(areAllMultiplesOf(result, 1.25), isTrue);
      expect(result, orderedEquals([1.25, 1.25]));
    });

    test('Test Case 6: Original Dose = 5.0, Number of Doses = 4', () {
      double originalDose = 5.0;
      int numberOfDoses = 4;
      List<double> result = dividedDoses(originalDose, numberOfDoses);

      // Expected: TargetTotalDose = 5.0. Doses [1.25, 1.25, 1.25, 1.25]
      expect(result.length, numberOfDoses);
      expect(sumDoses(result), greaterThanOrEqualTo(originalDose));
      expect(sumDoses(result), closeTo(5.0, 0.00001));
      expect(areAllMultiplesOf(result, 1.25), isTrue);
      expect(result, orderedEquals([1.25, 1.25, 1.25, 1.25]));
    });

    test('Test Case 7: Original Dose = 5.1, Number of Doses = 4', () {
      double originalDose = 5.1;
      int numberOfDoses = 4;
      List<double> result = dividedDoses(originalDose, numberOfDoses);

      // Expected: TargetTotalDose = 6.25. Doses like [2.5, 1.25, 1.25, 1.25]
      expect(result.length, numberOfDoses);
      expect(sumDoses(result), greaterThanOrEqualTo(originalDose));
      expect(sumDoses(result), closeTo(6.25, 0.00001));
      expect(areAllMultiplesOf(result, 1.25), isTrue);
      expect(result, orderedEquals([2.5, 1.25, 1.25, 1.25]));
    });

    test('Edge Case: Number of doses is zero', () {
      expect(() => dividedDoses(10.0, 0), throwsArgumentError);
    });

    test('Edge Case: Number of doses is negative', () {
      expect(() => dividedDoses(10.0, -2), throwsArgumentError);
    });

    test('Edge Case: Original dose is zero', () {
      double originalDose = 0.0;
      int numberOfDoses = 2;
      List<double> result = dividedDoses(originalDose, numberOfDoses);
      // TargetTotalDose = 0. Doses [0.0, 0.0]
      expect(result.length, numberOfDoses);
      expect(sumDoses(result), closeTo(0.0, 0.00001));
      expect(areAllMultiplesOf(result, 1.25), isTrue); // 0 is a multiple of any non-zero number
      expect(result, orderedEquals([0.0, 0.0]));
    });

    test('Edge Case: Original dose is negative throws ArgumentError', () {
      double originalDose = -5.0;
      int numberOfDoses = 2;
      // Assert that calling dividedDoses with a negative originalDose throws an ArgumentError
      expect(
            () => dividedDoses(originalDose, numberOfDoses),
        throwsA(isA<ArgumentError>()),
      );
    });

    // Test with a dose that's already a perfect multiple and should not change total
    test('Dose is already a perfect multiple of 1.25 and numberOfDoses', (){
      double originalDose = 5.0; // 1.25 * 4
      int numberOfDoses = 2;
      List<double> result = dividedDoses(originalDose, numberOfDoses);
      // TargetTotalDose = 5.0. Doses [2.5, 2.5]
      expect(result.length, numberOfDoses);
      expect(sumDoses(result), closeTo(5.0, 0.00001));
      expect(areAllMultiplesOf(result, 1.25), isTrue);
      expect(result, orderedEquals([2.5, 2.5]));
    });

  });
}
