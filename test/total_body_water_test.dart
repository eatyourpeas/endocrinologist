import 'package:flutter_test/flutter_test.dart';
import 'package:endocrinologist/calculations/salinecalculations.dart'; // Adjust path if needed
import 'package:endocrinologist/enums/enums.dart'; // Adjust path if needed
import 'dart:math' as math; // For direct comparison if needed, though not strictly for these tests

void main() {
  group('totalBodyWater - Wells et al. method (age <= 12)', () {
    test(
        'Boy aged 4.4, weight 17.0 kg, height 106 cm (Wells example 1)',
            () {
          // Inputs from Wells et al. example
          const double age = 4.4; // years
          const double weight = 17.0; // kg
          const double height = 106.0; // cm
          const Sex sex = Sex.male; // "sex scored as zero" implies male in the formula

          // Expected lnTBW and TBW from the paper
          // lnTBW = -2.952 + (0.551 * ln17) + (0.796 * ln106) + (0.008 * 4.4)
          // lnTBW = -2.952 + (0.551 * 2.833213344) + (0.796 * 4.66343909) + (0.008 * 4.4)
          // lnTBW = -2.952 + 1.561100552 + 3.712109516 + 0.0352 = 2.356410068
          // TBW = exp(2.356410068) = 10.5530
          const double expectedLiters = 10.55; // From paper

          final double result = totalBodyWater(
            age: age,
            height: height,
            weight: weight,
            sex: sex,
          );

          // Using expectLater with closeTo for floating point comparisons
          expect(result, closeTo(expectedLiters, 0.01)); // Allow a small delta
        });

    test(
        'Girl aged 0.23, weight 5.95 kg, height 62 cm (Wells example 2)',
            () {
          // Inputs from Wells et al. example
          const double age = 0.23; // years
          const double weight = 5.95; // kg
          const double height = 62.0; // cm
          const Sex sex = Sex.female; // "sex scored as 1" implies female in the formula

          // Expected lnTBW and TBW from the paper
          // lnTBW = -2.952 + (0.551 * ln5.95) + (0.796 * ln62) - 0.047 + (0.008 * 0.23)
          // lnTBW = -2.952 + (0.551 * 1.783474935) + (0.796 * 4.127134385) - 0.047 + (0.008 * 0.23)
          // lnTBW = -2.952 + 0.982694689 + 3.28519909 - 0.047 + 0.00184
          // lnTBW = 1.270733779
          // TBW = exp(1.270733779) = 3.5632
          const double expectedLiters = 3.56; // From paper

          final double result = totalBodyWater(
            age: age,
            height: height,
            weight: weight,
            sex: sex,
          );

          expect(result, closeTo(expectedLiters, 0.01));
        });

    // Add more test cases for age <= 12:
    // - Edge case: age = 12 (male)
    // - Edge case: age = 12 (female)
    // - Younger infant (male)
    // - Younger infant (female)
    test('Boy aged 12, weight 40 kg, height 150 cm', () {
      final double result = totalBodyWater(
        age: 12,
        height: 150,
        weight: 40,
        sex: Sex.male,
      );
      // Manual calculation for this test case:
      // lnTBW = -2.952 + (0.551 * ln(40)) + (0.796 * ln(150)) + (0.008 * 12)
      // lnTBW = -2.952 + (0.551 * 3.688879) + (0.796 * 5.010635) + 0.096
      // lnTBW = -2.952 + 2.032572329 + 3.988465456 + 0.096 = 3.165037785
      // TBW = exp(3.165037785) = 23.689
      expect(result, closeTo(23.69, 0.01));
    });

    test('Female aged 12, weight 40 kg, height 150 cm', () {
      final double result = totalBodyWater(
        age: 12,
        height: 150,
        weight: 40,
        sex: Sex.female,
      );
      // Manual calculation for this test case:
      // lnTBW_male = 3.165037785 (from above)
      // lnTBW_female = lnTBW_male - 0.047 = 3.118037785
      // TBW_female = exp(3.118037785) = 22.599
      expect(result, closeTo(22.60, 0.01));
    });

  });

  group('totalBodyWater - Chumlea et al. method (age > 12)', () {
    test('Boy aged 15, weight 60 kg, height 170 cm', () {
      // Inputs
      const double age = 15.0;
      const double weight = 60.0;
      const double height = 170.0;
      const Sex sex = Sex.male;

      // Expected from formula: TBW = −25.87 + 0.23 (stature) + 0.37(weight)
      // TBW = -25.87 + (0.23 * 170) + (0.37 * 60)
      // TBW = -25.87 + 39.1 + 22.2 = 35.43
      const double expectedLiters = 35.43;

      final double result = totalBodyWater(
        age: age,
        height: height,
        weight: weight,
        sex: sex,
      );

      expect(result, closeTo(expectedLiters, 0.01));
    });

    test('Girl aged 14, weight 50 kg, height 160 cm', () {
      // Inputs
      const double age = 14.0;
      const double weight = 50.0;
      const double height = 160.0;
      const Sex sex = Sex.female;

      // Expected from formula: TBW = −14.77 + 0.18 (stature) + 0.25(weight)
      // TBW = -14.77 + (0.18 * 160) + (0.25 * 50)
      // TBW = -14.77 + 28.8 + 12.5 = 26.53
      const double expectedLiters = 26.53;

      final double result = totalBodyWater(
        age: age,
        height: height,
        weight: weight,
        sex: sex,
      );

      expect(result, closeTo(expectedLiters, 0.01));
    });

    // Add more test cases for age > 12 if desired:
    // - Edge case: age just above 12 (e.g., 12.1) for male
    // - Edge case: age just above 12 (e.g., 12.1) for female
    test('Boy aged 12.1, weight 45 kg, height 155 cm', () {
      final double result = totalBodyWater(
        age: 12.1,
        height: 155,
        weight: 45,
        sex: Sex.male,
      );
      // TBW = -25.87 + (0.23 * 155) + (0.37 * 45)
      // TBW = -25.87 + 35.65 + 16.65 = 26.43
      expect(result, closeTo(26.43, 0.01));
    });
  });

  // Optional: Test for boundary conditions if your logic has specific handling
  // (though the age <= 12 vs > 12 is the main boundary here)
  test('Age exactly 12 should use Wells et al. method (Male)', () {
    const double age = 12.0;
    const double weight = 40.0;
    const double height = 150.0;
    const Sex sex = Sex.male;

    // Expected from Wells et al. for Male (calculated in previous test)
    const double expectedWells = 23.689;

    final double result = totalBodyWater(
      age: age,
      height: height,
      weight: weight,
      sex: sex,
    );
    expect(result, closeTo(expectedWells, 0.01));
  });
}

