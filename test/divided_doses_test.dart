// test/divided_doses_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:endocrinologist/calculations/glucocorticoidmaths.dart'; // Ensure this path is correct

void main() {
  group('dividedDoses Function Tests (New Logic)', () {
    // Helper function to sum doses for verification
    double sumDoses(List<double> doses) {
      return doses.fold(0.0, (prev, element) => prev + element);
    }

    // Helper to check if all doses are multiples of a given number
    bool areAllMultiplesOf(List<double> doses, double multiple) {
      const double tolerance = 0.00001;
      if (multiple == 0)
        return doses.every((dose) => dose == 0); // Handle multiple of 0 case
      return doses.every((dose) =>
          (dose % multiple).abs() < tolerance ||
          (dose % multiple).abs() > (multiple - tolerance));
    }

    // Test cases based on the refined logic

    test('Test Case 1: Original Dose = 7.0, Number of Doses = 3', () {
      double originalDose = 7.0;
      int numberOfDoses = 3;
      List<double> result = dividedDoses(originalDose, numberOfDoses);

      // Logic: originalDose = 7.0. ceilToDouble() = 7.0. Not a multiple of 1.25.
      // Increment = 1.0. finalTargetTotalDose = 7.0.ceilToDouble() = 7.0.
      // Doses: [3.0, 2.0, 2.0] (or permutations)
      double expectedTargetTotalDose = 7.0;
      double expectedIncrement = 1.0;

      expect(result.length, numberOfDoses);
      expect(sumDoses(result), closeTo(expectedTargetTotalDose, 0.00001));
      expect(areAllMultiplesOf(result, expectedIncrement), isTrue,
          reason: "All doses should be multiples of $expectedIncrement");
      // Order might vary, sum and content are more important
      expect(result.fold<double>(0, (prev, curr) => prev + curr),
          expectedTargetTotalDose);
      expect(result,
          unorderedEquals([3.0, 2.0, 2.0])); // More robust if order can change
    });

    test('Test Case 2: Original Dose = 6.0, Number of Doses = 3', () {
      double originalDose = 6.0;
      int numberOfDoses = 3;
      List<double> result = dividedDoses(originalDose, numberOfDoses);

      // Logic: originalDose = 6.0. ceilToDouble() = 6.0. Not a multiple of 1.25.
      // Increment = 1.0. finalTargetTotalDose = 6.0.ceilToDouble() = 6.0.
      // Doses: [2.0, 2.0, 2.0]
      double expectedTargetTotalDose = 6.0;
      double expectedIncrement = 1.0;

      expect(result.length, numberOfDoses);
      expect(sumDoses(result), closeTo(expectedTargetTotalDose, 0.00001));
      expect(areAllMultiplesOf(result, expectedIncrement), isTrue,
          reason: "All doses should be multiples of $expectedIncrement");
      expect(result, orderedEquals([2.0, 2.0, 2.0]));
    });

    test('Test Case 3: Original Dose = 10.0, Number of Doses = 3', () {
      double originalDose = 10.0;
      int numberOfDoses = 3;
      List<double> result = dividedDoses(originalDose, numberOfDoses);

      // Logic: originalDose = 10.0. ceilToDouble() = 10.0. (1000 % 125 == 0) -> is a multiple of 1.25.
      // Increment = 1.25. finalTargetTotalDose = (10.0 / 1.25).ceil() * 1.25 = 8 * 1.25 = 10.0.
      // Doses: 10.0 / 3 = 3.33...
      // Base per portion: (3.33 / 1.25).floor() * 1.25 = 2 * 1.25 = 2.5
      // Sum of base: 2.5 * 3 = 7.5. Remaining: 10.0 - 7.5 = 2.5
      // Distribute 2.5: first gets +1.25 (total 3.75), second gets +1.25 (total 3.75)
      // Expected: [3.75, 3.75, 2.5]
      double expectedTargetTotalDose = 10.0;
      double expectedIncrement = 1.25;

      expect(result.length, numberOfDoses);
      expect(sumDoses(result), closeTo(expectedTargetTotalDose, 0.00001));
      expect(areAllMultiplesOf(result, expectedIncrement), isTrue,
          reason: "All doses should be multiples of $expectedIncrement");
      expect(result, orderedEquals([3.75, 3.75, 2.5]));
    });

    test('Test Case 4: Original Dose = 0.1, Number of Doses = 1', () {
      double originalDose = 0.1;
      int numberOfDoses = 1;
      List<double> result = dividedDoses(originalDose, numberOfDoses);

      // Logic: originalDose = 0.1. ceilToDouble() = 1.0. Not a multiple of 1.25.
      // Increment = 1.0. finalTargetTotalDose = (0.1).ceilToDouble() = 1.0.
      // Doses: [1.0]
      double expectedTargetTotalDose = 1.0;
      double expectedIncrement = 1.0;

      expect(result.length, numberOfDoses);
      expect(sumDoses(result), closeTo(expectedTargetTotalDose, 0.00001));
      expect(areAllMultiplesOf(result, expectedIncrement), isTrue,
          reason: "All doses should be multiples of $expectedIncrement");
      expect(result, orderedEquals([1.0]));
    });

    test(
        'Test Case 4b: Original Dose = 1.0, Number of Doses = 1 (to trigger 1.25)',
        () {
      double originalDose =
          1.0; // Let's check a case that should use 1.25 if possible
      int numberOfDoses = 1;
      List<double> result = dividedDoses(originalDose, numberOfDoses);

      // Logic: originalDose = 1.0. ceilToDouble() = 1.0. Not a multiple of 1.25.
      // Increment = 1.0. finalTargetTotalDose = (1.0).ceilToDouble() = 1.0
      // Doses: [1.0]
      // IF THE RULE WAS: use 1.25 if originalDose itself is a multiple, then it'd be 1.25.
      // But based on `originalDose.ceilToDouble()` check for increment:
      double expectedTargetTotalDose = 1.0;
      double expectedIncrement = 1.0;

      expect(result.length, numberOfDoses);
      expect(sumDoses(result), closeTo(expectedTargetTotalDose, 0.00001));
      expect(areAllMultiplesOf(result, expectedIncrement), isTrue,
          reason: "All doses should be multiples of $expectedIncrement");
      expect(result, orderedEquals([1.0]));
    });

    test('Test Case 4c: Original Dose = 1.25, Number of Doses = 1', () {
      double originalDose = 1.25;
      int numberOfDoses = 1;
      List<double> result = dividedDoses(originalDose, numberOfDoses);

      // Logic: originalDose = 1.25. ceilToDouble() = 2.0. Not multiple of 1.25.
      // This seems counter-intuitive based on current increment rule.
      // Let's re-evaluate the increment decision based on the code:
      // tempTargetForIncrementCheck = 1.25.ceilToDouble() = 2.0
      // (2.0 * 100).round() % 125 != 0 -> doseIncrement = 1.0
      // finalTargetTotalDose = 1.25.ceilToDouble() = 2.0
      // Doses: [2.0]
      // This highlights a potential area for refinement in the increment decision if the goal is to *always* use 1.25 if original is perfectly 1.25
      // For now, testing the code AS IS:
      double expectedTargetTotalDose = 2.0; // Because increment becomes 1.0
      double expectedIncrement = 1.0;

      expect(result.length, numberOfDoses);
      expect(sumDoses(result), closeTo(expectedTargetTotalDose, 0.00001));
      expect(areAllMultiplesOf(result, expectedIncrement), isTrue,
          reason:
              "All doses should be multiples of $expectedIncrement. Actual: $result");
      expect(result, orderedEquals([2.0]));
    });

    test('Test Case 5: Original Dose = 2.4, Number of Doses = 2', () {
      double originalDose = 2.4;
      int numberOfDoses = 2;
      List<double> result = dividedDoses(originalDose, numberOfDoses);

      // Logic: originalDose = 2.4. ceilToDouble() = 3.0. Not a multiple of 1.25.
      // Increment = 1.0. finalTargetTotalDose = 2.4.ceilToDouble() = 3.0.
      // Doses: [2.0, 1.0]
      double expectedTargetTotalDose = 3.0;
      double expectedIncrement = 1.0;

      expect(result.length, numberOfDoses);
      expect(sumDoses(result), closeTo(expectedTargetTotalDose, 0.00001));
      expect(areAllMultiplesOf(result, expectedIncrement), isTrue,
          reason: "All doses should be multiples of $expectedIncrement");
      expect(result, unorderedEquals([2.0, 1.0]));
    });

    test('Test Case 5b: Original Dose = 2.5, Number of Doses = 2', () {
      double originalDose = 2.5;
      int numberOfDoses = 2;
      List<double> result = dividedDoses(originalDose, numberOfDoses);

      // Logic: originalDose = 2.5. ceilToDouble() = 3.0. (Not mult of 1.25) -> inc = 1.0
      // finalTarget = 2.5.ceilToDouble() = 3.0
      // Doses: [2.0, 1.0] based on current increment logic.
      // IF increment logic was different (e.g. check originalDose for 1.25 divisibility first):
      // tempTargetForIncrementCheck = 2.5.ceilToDouble() = 3.0
      // (3.0 * 100).round() % 125 != 0 -> doseIncrement = 1.0
      // finalTargetTotalDose = 2.5.ceilToDouble() = 3.0
      // Expected: [2.0, 1.0]

      double expectedTargetTotalDose = 3.0;
      double expectedIncrement = 1.0;

      expect(result.length, numberOfDoses);
      expect(sumDoses(result), closeTo(expectedTargetTotalDose, 0.00001));
      expect(areAllMultiplesOf(result, expectedIncrement), isTrue,
          reason:
              "All doses should be multiples of $expectedIncrement. Actual: $result");
      expect(result, unorderedEquals([2.0, 1.0]));
    });

    test('Test Case 6: Original Dose = 5.0, Number of Doses = 4', () {
      double originalDose = 5.0;
      int numberOfDoses = 4;
      List<double> result = dividedDoses(originalDose, numberOfDoses);

      // Logic: originalDose = 5.0. ceilToDouble() = 5.0. (500 % 125 == 0) -> is multiple of 1.25.
      // Increment = 1.25. finalTargetTotalDose = (5.0 / 1.25).ceil() * 1.25 = 4 * 1.25 = 5.0.
      // Doses: [1.25, 1.25, 1.25, 1.25]
      double expectedTargetTotalDose = 5.0;
      double expectedIncrement = 1.25;

      expect(result.length, numberOfDoses);
      expect(sumDoses(result), closeTo(expectedTargetTotalDose, 0.00001));
      expect(areAllMultiplesOf(result, expectedIncrement), isTrue,
          reason: "All doses should be multiples of $expectedIncrement");
      expect(result, orderedEquals([1.25, 1.25, 1.25, 1.25]));
    });

    test('Test Case 7: Original Dose = 5.1, Number of Doses = 4', () {
      double originalDose = 5.1;
      int numberOfDoses = 4;
      List<double> result = dividedDoses(originalDose, numberOfDoses);

      // Logic: originalDose = 5.1. ceilToDouble() = 6.0. Not a multiple of 1.25.
      // Increment = 1.0. finalTargetTotalDose = 5.1.ceilToDouble() = 6.0.
      // Doses: 6.0 / 4 = 1.5. Base = 1.0. Sum base = 4.0. Rem = 2.0.
      // [2.0, 2.0, 1.0, 1.0]
      double expectedTargetTotalDose = 6.0;
      double expectedIncrement = 1.0;

      expect(result.length, numberOfDoses);
      expect(sumDoses(result), closeTo(expectedTargetTotalDose, 0.00001));
      expect(areAllMultiplesOf(result, expectedIncrement), isTrue,
          reason: "All doses should be multiples of $expectedIncrement");
      expect(result, unorderedEquals([2.0, 2.0, 1.0, 1.0]));
    });

    test('Test Case 7b: Original Dose = 6.25, Number of Doses = 2', () {
      double originalDose = 6.25;
      int numberOfDoses = 2;
      List<double> result = dividedDoses(originalDose, numberOfDoses);

      // Logic: originalDose = 6.25. ceilToDouble() = 7.0. Not a multiple of 1.25.
      // So increment = 1.0. finalTargetTotalDose = 6.25.ceilToDouble() = 7.0.
      // Doses: [4.0, 3.0]
      // This is again a consequence of the current increment decision logic.
      double expectedTargetTotalDose = 7.0;
      double expectedIncrement = 1.0;

      expect(result.length, numberOfDoses);
      expect(sumDoses(result), closeTo(expectedTargetTotalDose, 0.00001));
      expect(areAllMultiplesOf(result, expectedIncrement), isTrue,
          reason:
              "All doses should be multiples of $expectedIncrement. Actual: $result");
      expect(result, unorderedEquals([4.0, 3.0]));
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

      double expectedTargetTotalDose = 0.0;
      // For 0, the specific increment doesn't change the outcome of all zeros
      // bool actualAreMultiples = areAllMultiplesOf(result, 1.25); // or 1.0, result is [0.0, 0.0]
      // For this specific test, we can just check the values.

      expect(result.length, numberOfDoses);
      expect(sumDoses(result), closeTo(expectedTargetTotalDose, 0.00001));
      expect(result, orderedEquals([0.0, 0.0]));
      // Check that they are multiples of a non-zero number (e.g. 1) to confirm they are 0
      expect(areAllMultiplesOf(result, 1.0), isTrue,
          reason: "All doses should be 0.0");
    });

    test('Edge Case: Original dose is negative throws ArgumentError', () {
      expect(() => dividedDoses(-5.0, 2), throwsA(isA<ArgumentError>()));
    });

    // Test with a dose that's already a perfect multiple of 1.25 (e.g. 5.0)
    test('Dose is 5.0 (multiple of 1.25), Number of Doses = 2', () {
      double originalDose = 5.0; // 1.25 * 4
      int numberOfDoses = 2;
      List<double> result = dividedDoses(originalDose, numberOfDoses);

      // Logic: originalDose = 5.0. ceilToDouble() = 5.0. (500 % 125 == 0) -> is multiple of 1.25.
      // Increment = 1.25. finalTargetTotalDose = (5.0 / 1.25).ceil() * 1.25 = 5.0.
      // Doses: 5.0 / 2 = 2.5. Base = 2.5. Sum base = 5.0. Rem = 0.
      // [2.5, 2.5]
      double expectedTargetTotalDose = 5.0;
      double expectedIncrement = 1.25;

      expect(result.length, numberOfDoses);
      expect(sumDoses(result), closeTo(expectedTargetTotalDose, 0.00001));
      expect(areAllMultiplesOf(result, expectedIncrement), isTrue,
          reason: "All doses should be multiples of $expectedIncrement");
      expect(result, orderedEquals([2.5, 2.5]));
    });

    test('Dose is 7.5 (multiple of 1.25), Number of Doses = 3', () {
      double originalDose = 7.5;
      int numberOfDoses = 3;
      List<double> result = dividedDoses(originalDose, numberOfDoses);

      // Logic: originalDose = 7.5. ceilToDouble() = 8.0. Not multiple of 1.25.
      // Increment = 1.0. finalTargetTotalDose = 7.5.ceilToDouble() = 8.0.
      // Doses: 8.0 / 3 = 2.66. Base = 2.0. Sum base = 6.0. Rem = 2.0
      // Expected [3.0, 3.0, 2.0]
      // This shows the current increment decision rule in action.
      double expectedTargetTotalDose = 8.0;
      double expectedIncrement = 1.0;

      expect(result.length, numberOfDoses);
      expect(sumDoses(result), closeTo(expectedTargetTotalDose, 0.00001));
      expect(areAllMultiplesOf(result, expectedIncrement), isTrue,
          reason:
              "All doses should be multiples of $expectedIncrement. Actual: $result");
      expect(result, unorderedEquals([3.0, 3.0, 2.0]));
    });
  });
}
