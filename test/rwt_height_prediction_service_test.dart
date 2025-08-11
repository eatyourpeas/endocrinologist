import "package:endocrinologist/calculations/rwt_final_height_service.dart";
import "package:endocrinologist/classes/rwt_final_height_weight_class.dart";
import 'package:flutter_test/flutter_test.dart';
import "package:endocrinologist/enums/enums.dart";

void main() {
  late RWTFinalHeightPredictionService service;

  // Set up the service before each test group
  setUp(() {
    service = RWTFinalHeightPredictionService();
  });

  group('RWTFinalHeightPredictionService Exact Lookup Tests', () {
    test('Boy - Exact lookup for 6 years, 3 months should return correct coefficients', () {
      final RWTFinalHeightWeights? data = service.getExactData(
        ageYears: 6,
        ageMonths: 3,
        sex: Sex.male,
      );

      // Assert that data is not null
      expect(data, isNotNull);

      // Assert specific coefficient values for boys 6y 3m (from the provided CSV)
      expect(data!.heightLengthCoefficient, closeTo(1.143, 0.001));
      expect(data.weightCoefficient, closeTo(-0.512, 0.001));
      expect(data.midparentalHeightCoefficient, closeTo(0.389, 0.001));
      expect(data.boneAgeCoefficient, closeTo(0.123, 0.001));
      expect(data.regressionIntercept, closeTo(-12.901, 0.001));
    });

    test('Girl - Exact lookup for 10 years, 6 months should return correct coefficients', () {
      final RWTFinalHeightWeights? data = service.getExactData(
        ageYears: 10,
        ageMonths: 6,
        sex: Sex.female,
      );

      expect(data, isNotNull);
      expect(data!.heightLengthCoefficient, closeTo(0.766, 0.001));
      expect(data.weightCoefficient, closeTo(-0.217, 0.001));
      expect(data.midparentalHeightCoefficient, closeTo(0.217, 0.001));
      expect(data.boneAgeCoefficient, closeTo(-2.829, 0.001));
      expect(data.regressionIntercept, closeTo(56.481, 0.001));
    });

    test('Boy - Exact lookup for 16 years, 0 months should return correct coefficients', () {
      final RWTFinalHeightWeights? data = service.getExactData(
        ageYears: 16,
        ageMonths: 0,
        sex: Sex.male,
      );

      expect(data, isNotNull);
      expect(data!.heightLengthCoefficient, closeTo(0.839, 0.001));
      expect(data.weightCoefficient, closeTo(-0.014, 0.001));
      expect(data.midparentalHeightCoefficient, closeTo(0.167, 0.001));
      expect(data.boneAgeCoefficient, closeTo(-2.776, 0.001));
      expect(data.regressionIntercept, closeTo(46.391, 0.001));
    });
  });

  group('RWTFinalHeightPredictionService Interpolation Tests', () {
    // Standard test input values for height calculation
    const double testCurrentHeight = 120.0;
    const double testWeight = 25.0;
    const double testBoneAge = 7.5;
    const double testMidparentalHeight = 170.0;

    test('Boy - Interpolated height for 6 years, 4.5 months (6.375 decimal years)', () {
      // Data points surrounding 6.375 decimal years for boys:
      // 6y 3m (6.25) -> HLC: 1.143, WC: -0.512, MPHC: 0.389, BAC: 0.123, RI: -12.901
      // 6y 6m (6.50) -> HLC: 1.106, WC: -0.434, MPHC: 0.365, BAC: -0.077, RI: -11.834
      const double ageToTest = 6.375; // 6 years, 4.5 months

      final double estimatedHeight = service.estimateFinalAdultHeight(
        currentHeightCm: testCurrentHeight,
        ageDecimalYears: ageToTest,
        weightKg: testWeight,
        boneAgeDecimalYears: testBoneAge,
        midparentalHeightCm: testMidparentalHeight,
        sex: Sex.male,
      );

      // Expected interpolated coefficients (manual calculation for verification):
      // HLC: 1.139
      // WC: -0.5055
      // MPHC: 0.386
      // BAC: 0.104
      // RI: -12.742

      // Expected calculation:
      // 1.139 * 120 + (-0.5055 * 25) + (0.386 * 170) + (0.104 * 7.5) + -12.742
      expect(estimatedHeight, closeTo(177.7, 0.01)); // Allowing for minor floating point variations
    });

    test('Girl - Interpolated height for 5 years, 1.5 months (5.125 decimal years)', () {
      // Data points surrounding 5.125 decimal years for girls:
      // 5y 0m (5.00) -> HLC: 1.190, WC: -0.761, MPHC: 0.200, BAC: -0.571, RI: 17.398
      // 5y 3m (5.25) -> HLC: 1.180, WC: -0.742, MPHC: 0.197, BAC: -0.572, RI: 17.431
      const double ageToTest = 5.125; // 5 years, 1.5 months

      final double estimatedHeight = service.estimateFinalAdultHeight(
        currentHeightCm: testCurrentHeight,
        ageDecimalYears: ageToTest,
        weightKg: testWeight,
        boneAgeDecimalYears: testBoneAge,
        midparentalHeightCm: testMidparentalHeight,
        sex: Sex.female,
      );

      // Expected interpolated coefficients (manual calculation for verification):
      // HLC: 1.185
      // WC: -0.7515
      // MPHC: 0.1985
      // BAC: -0.5714999999999999
      // RI: 17.4145

      // Expected calculation:
      // (120 * 1.185) + (25 * -0.7515) + (170 * 0.1985) + (7.5 * -0.5715) + 17.4145

      expect(estimatedHeight, closeTo(170.29, 0.01));
    });
  });

  group('RWTFinalHeightPredictionService Out of Range Tests', () {
    const double testCurrentHeight = 120.0;
    const double testWeight = 25.0;
    const double testBoneAge = 7.5;
    const double testMidparentalHeight = 170.0;

    test('Boy - Age below minimum range should throw ArgumentError', () {
      // Boys data starts at 1.0 decimal years
      const double ageBelowMin = 0.5; // 0 years, 6 months
      expect(
            () => service.estimateFinalAdultHeight(
          currentHeightCm: testCurrentHeight,
          ageDecimalYears: ageBelowMin,
          weightKg: testWeight,
          boneAgeDecimalYears: testBoneAge,
          midparentalHeightCm: testMidparentalHeight,
          sex: Sex.male,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('Boy - Age above maximum range should throw ArgumentError', () {
      // Boys data ends at 16.0 decimal years
      const double ageAboveMax = 16.1; // 16 years, 1.2 months
      expect(
            () => service.estimateFinalAdultHeight(
          currentHeightCm: testCurrentHeight,
          ageDecimalYears: ageAboveMax,
          weightKg: testWeight,
          boneAgeDecimalYears: testBoneAge,
          midparentalHeightCm: testMidparentalHeight,
          sex: Sex.male,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('Girl - Age below minimum range should throw ArgumentError', () {
      // Girls data starts at 1.0 decimal years
      const double ageBelowMin = 0.9; // 0 years, 10.8 months
      expect(
            () => service.estimateFinalAdultHeight(
          currentHeightCm: testCurrentHeight,
          ageDecimalYears: ageBelowMin,
          weightKg: testWeight,
          boneAgeDecimalYears: testBoneAge,
          midparentalHeightCm: testMidparentalHeight,
          sex: Sex.female,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('Girl - Age above maximum range should throw ArgumentError', () {
      // Girls data ends at 14.0 decimal years
      const double ageAboveMax = 14.0001; // Slightly above 14y 0m
      expect(
            () => service.estimateFinalAdultHeight(
          currentHeightCm: testCurrentHeight,
          ageDecimalYears: ageAboveMax,
          weightKg: testWeight,
          boneAgeDecimalYears: testBoneAge,
          midparentalHeightCm: testMidparentalHeight,
          sex: Sex.female,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}