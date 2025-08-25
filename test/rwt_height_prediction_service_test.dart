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

  group('RWTFinalHeightPredictionService Exact Lookup Tests - Original Data',
      () {
    test(
        'Boy - Exact lookup for 6 years, 3 months should return correct coefficients',
        () {
      final RWTFinalHeightWeights? data = service.getExactData(
        ageYears: 6,
        ageMonths: 3,
        sex: Sex.male,
        useAmendedData: false, // Explicitly use original data
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

    test(
        'Girl - Exact lookup for 10 years, 6 months should return correct coefficients',
        () {
      final RWTFinalHeightWeights? data = service.getExactData(
        ageYears: 10,
        ageMonths: 6,
        sex: Sex.female,
        useAmendedData: false, // Explicitly use original data
      );

      expect(data, isNotNull);
      expect(data!.heightLengthCoefficient, closeTo(0.766, 0.001));
      expect(data.weightCoefficient, closeTo(-0.217, 0.001));
      expect(data.midparentalHeightCoefficient, closeTo(0.217, 0.001));
      expect(data.boneAgeCoefficient, closeTo(-2.829, 0.001));
      expect(data.regressionIntercept, closeTo(56.481, 0.001));
    });

    test(
        'Boy - Exact lookup for 16 years, 0 months should return correct coefficients',
        () {
      final RWTFinalHeightWeights? data = service.getExactData(
        ageYears: 16,
        ageMonths: 0,
        sex: Sex.male,
        useAmendedData: false, // Explicitly use original data
      );

      expect(data, isNotNull);
      expect(data!.heightLengthCoefficient, closeTo(0.839, 0.001));
      expect(data.weightCoefficient, closeTo(-0.014, 0.001));
      expect(data.midparentalHeightCoefficient, closeTo(0.167, 0.001));
      expect(data.boneAgeCoefficient, closeTo(-2.776, 0.001));
      expect(data.regressionIntercept, closeTo(46.391, 0.001));
    });
  });

  group('RWTFinalHeightPredictionService Exact Lookup Tests - Amended Data',
      () {
    test(
        'Boy - Exact lookup for 6.0 decimal years should return correct coefficients (amended data)',
        () {
      final RWTFinalHeightWeights? data = service.getExactData(
        ageYears: 6, // 6.0 decimal years
        ageMonths: 0,
        sex: Sex.male,
        useAmendedData: true, // Explicitly use amended data
      );

      expect(data, isNotNull);
      expect(data!.heightLengthCoefficient, closeTo(1.16573, 0.001));
      expect(data.weightCoefficient, closeTo(-0.33493, 0.001));
      expect(data.midparentalHeightCoefficient, closeTo(0.48857, 0.001));
      expect(data.boneAgeCoefficient, closeTo(-0.82953, 0.001));
      expect(data.regressionIntercept, closeTo(-28.5616, 0.001));
    });

    test(
        'Girl - Exact lookup for 10.5 decimal years should return correct coefficients (amended data)',
        () {
      final RWTFinalHeightWeights? data = service.getExactData(
        ageYears: 10, // 10.5 decimal years
        ageMonths: 6,
        sex: Sex.female,
        useAmendedData: true, // Explicitly use amended data
      );

      expect(data, isNotNull);
      expect(data!.heightLengthCoefficient, closeTo(0.94329, 0.001));
      expect(data.weightCoefficient, closeTo(-0.26275, 0.001));
      expect(data.midparentalHeightCoefficient, closeTo(0.23610, 0.001));
      expect(data.boneAgeCoefficient, closeTo(-2.96492, 0.001));
      expect(data.regressionIntercept, closeTo(30.8503, 0.001));
    });

    test(
        'Boy - Exact lookup for 17.5 decimal years should return correct coefficients (amended data)',
        () {
      final RWTFinalHeightWeights? data = service.getExactData(
        ageYears: 17, // 17.5 decimal years
        ageMonths: 6,
        sex: Sex.male,
        useAmendedData: true, // Explicitly use amended data
      );

      expect(data, isNotNull);
      expect(data!.heightLengthCoefficient, closeTo(1.02640, 0.001));
      expect(data.weightCoefficient, closeTo(-0.01946, 0.001));
      expect(data.midparentalHeightCoefficient, closeTo(0.01745, 0.001));
      expect(data.boneAgeCoefficient, closeTo(0.23891, 0.001));
      expect(data.regressionIntercept, closeTo(-11.3232, 0.001));
    });
  });

  group('RWTFinalHeightPredictionService Interpolation Tests - Original Data',
      () {
    // Standard test input values for height calculation
    const double testCurrentHeight = 120.0;
    const double testWeight = 25.0;
    const double testBoneAge = 7.5;
    const double testMidparentalHeight = 170.0;

    test(
        'Boy - Interpolated height for 6 years, 4.5 months (6.375 decimal years) - Original Data',
        () {
      // Data points surrounding 6.375 decimal years for boys (original data):
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
        useAmendedData: false, // Explicitly use original data
      );

      // Expected interpolated coefficients (manual calculation for verification):
      // HLC: 1.139
      // WC: -0.5055
      // MPHC: 0.386
      // BAC: 0.104
      // RI: -12.742

      // Expected calculation:
      // 1.139 * 120 + (-0.5055 * 25) + (0.386 * 170) + (0.104 * 7.5) + -12.742 = 136.68 - 12.6375 + 65.62 + 0.78 - 12.742 = 177.7005
      expect(
          estimatedHeight,
          closeTo(
              177.70, 0.01)); // Allowing for minor floating point variations
    });

    test(
        'Girl - Interpolated height for 5 years, 1.5 months (5.125 decimal years) - Original Data',
        () {
      // Data points surrounding 5.125 decimal years for girls (original data):
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
        useAmendedData: false, // Explicitly use original data
      );

      // Expected interpolated coefficients (manual calculation for verification):
      // HLC: 1.185
      // WC: -0.7515
      // MPHC: 0.1985
      // BAC: -0.5714999999999999
      // RI: 17.4145

      // Expected calculation:
      // (120 * 1.185) + (25 * -0.7515) + (170 * 0.1985) + (7.5 * -0.5715) + 17.4145 = 142.2 - 18.7875 + 33.745 - 4.28625 + 17.4145 = 170.28575
      expect(estimatedHeight, closeTo(170.29, 0.01));
    });
  });

  group('RWTFinalHeightPredictionService Interpolation Tests - Amended Data',
      () {
    const double testCurrentHeight = 120.0;
    const double testWeight = 25.0;
    const double testBoneAge = 7.5;
    const double testMidparentalHeight = 170.0;

    test('Boy - Interpolated height for 6.25 decimal years - Amended Data', () {
      // Data points surrounding 6.25 decimal years for boys (amended data):
      // 6.0 -> RI: -28.5616, HLC: 1.16573, WC: -0.33493, MPHC: 0.48857, BAC: -0.82953
      // 6.5 -> RI: -27.8955, HLC: 1.15849, WC: -0.30526, MPHC: 0.46982, BAC: -0.86454
      const double ageToTest = 6.25;

      final double estimatedHeight = service.estimateFinalAdultHeight(
        currentHeightCm: testCurrentHeight,
        ageDecimalYears: ageToTest,
        weightKg: testWeight,
        boneAgeDecimalYears: testBoneAge,
        midparentalHeightCm: testMidparentalHeight,
        sex: Sex.male,
        useAmendedData: true, // Explicitly use amended data
      );

      // Manually calculated interpolated coefficients for 6.25:
      // HLC: 1.16211
      // WC: -0.320095
      // MPHC: 0.479195
      // BAC: -0.847035
      // RI: -28.22855

      // Expected calculation:
      // (120 * 1.16211) + (25 * -0.320095) + (170 * 0.479195) + (7.5 * -0.847035) + (-28.22855)
      // 139.4532 + (-8.002375) + 81.46315 + (-6.3527625) + (-28.22855) = 178.3326625
      expect(estimatedHeight, closeTo(178.33, 0.01));
    });

    test('Girl - Interpolated height for 5.25 decimal years - Amended Data',
        () {
      // Data points surrounding 5.25 decimal years for girls (amended data):
      // 5.0 -> RI: -13.5388, HLC: 1.21884, WC: -0.97101, MPHC: 0.38620, BAC: 0.43747
      // 5.5 -> RI: -12.2278, HLC: 1.20167, WC: -0.90399, MPHC: 0.36875, BAC: -0.50281
      const double ageToTest = 5.25;

      final double estimatedHeight = service.estimateFinalAdultHeight(
        currentHeightCm: testCurrentHeight,
        ageDecimalYears: ageToTest,
        weightKg: testWeight,
        boneAgeDecimalYears: testBoneAge,
        midparentalHeightCm: testMidparentalHeight,
        sex: Sex.female,
        useAmendedData: true, // Explicitly use amended data
      );

      // Manually calculated interpolated coefficients for 5.25:
      // HLC: 1.210255
      // WC: -0.9375
      // MPHC: 0.377475
      // BAC: -0.03267
      // RI: -12.8833

      // Expected calculation:
      // (120 * 1.210255) + (25 * -0.9375) + (170 * 0.377475) + (7.5 * -0.03267) + (-12.8833)
      // 145.2306 + (-23.4375) + 64.17075 + (-0.245025) + (-12.8833) = 172.835525
      expect(estimatedHeight, closeTo(172.84, 0.01));
    });
  });

  group('RWTFinalHeightPredictionService Out of Range Tests - Original Data',
      () {
    const double testCurrentHeight = 120.0;
    const double testWeight = 25.0;
    const double testBoneAge = 7.5;
    const double testMidparentalHeight = 170.0;

    test(
        'Boy - Age below minimum range should throw ArgumentError (Original Data)',
        () {
      // Boys original data starts at 1.0 decimal years
      const double ageBelowMin = 0.5; // 0 years, 6 months
      expect(
        () => service.estimateFinalAdultHeight(
          currentHeightCm: testCurrentHeight,
          ageDecimalYears: ageBelowMin,
          weightKg: testWeight,
          boneAgeDecimalYears: testBoneAge,
          midparentalHeightCm: testMidparentalHeight,
          sex: Sex.male,
          useAmendedData: false,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test(
        'Boy - Age above maximum range should throw ArgumentError (Original Data)',
        () {
      // Boys original data ends at 16.0 decimal years
      const double ageAboveMax = 16.1; // 16 years, 1.2 months
      expect(
        () => service.estimateFinalAdultHeight(
          currentHeightCm: testCurrentHeight,
          ageDecimalYears: ageAboveMax,
          weightKg: testWeight,
          boneAgeDecimalYears: testBoneAge,
          midparentalHeightCm: testMidparentalHeight,
          sex: Sex.male,
          useAmendedData: false,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test(
        'Girl - Age below minimum range should throw ArgumentError (Original Data)',
        () {
      // Girls original data starts at 1.0 decimal years
      const double ageBelowMin = 0.9; // 0 years, 10.8 months
      expect(
        () => service.estimateFinalAdultHeight(
          currentHeightCm: testCurrentHeight,
          ageDecimalYears: ageBelowMin,
          weightKg: testWeight,
          boneAgeDecimalYears: testBoneAge,
          midparentalHeightCm: testMidparentalHeight,
          sex: Sex.female,
          useAmendedData: false,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test(
        'Girl - Age above maximum range should throw ArgumentError (Original Data)',
        () {
      // Girls original data ends at 14.0 decimal years
      const double ageAboveMax = 14.0001; // Slightly above 14y 0m
      expect(
        () => service.estimateFinalAdultHeight(
          currentHeightCm: testCurrentHeight,
          ageDecimalYears: ageAboveMax,
          weightKg: testWeight,
          boneAgeDecimalYears: testBoneAge,
          midparentalHeightCm: testMidparentalHeight,
          sex: Sex.female,
          useAmendedData: false,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  group('RWTFinalHeightPredictionService Out of Range Tests - Amended Data',
      () {
    const double testCurrentHeight = 120.0;
    const double testWeight = 25.0;
    const double testBoneAge = 7.5;
    const double testMidparentalHeight = 170.0;

    test(
        'Boy - Age below minimum range should throw ArgumentError (Amended Data)',
        () {
      // Boys amended data starts at 3.0 decimal years
      const double ageBelowMin = 2.9;
      expect(
        () => service.estimateFinalAdultHeight(
          currentHeightCm: testCurrentHeight,
          ageDecimalYears: ageBelowMin,
          weightKg: testWeight,
          boneAgeDecimalYears: testBoneAge,
          midparentalHeightCm: testMidparentalHeight,
          sex: Sex.male,
          useAmendedData: true, // Explicitly use amended data
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test(
        'Boy - Age above maximum range should throw ArgumentError (Amended Data)',
        () {
      // Boys amended data ends at 17.5 decimal years
      const double ageAboveMax = 17.6;
      expect(
        () => service.estimateFinalAdultHeight(
          currentHeightCm: testCurrentHeight,
          ageDecimalYears: ageAboveMax,
          weightKg: testWeight,
          boneAgeDecimalYears: testBoneAge,
          midparentalHeightCm: testMidparentalHeight,
          sex: Sex.male,
          useAmendedData: true, // Explicitly use amended data
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test(
        'Girl - Age below minimum range should throw ArgumentError (Amended Data)',
        () {
      // Girls amended data starts at 3.0 decimal years
      const double ageBelowMin = 2.9;
      expect(
        () => service.estimateFinalAdultHeight(
          currentHeightCm: testCurrentHeight,
          ageDecimalYears: ageBelowMin,
          weightKg: testWeight,
          boneAgeDecimalYears: testBoneAge,
          midparentalHeightCm: testMidparentalHeight,
          sex: Sex.female,
          useAmendedData: true, // Explicitly use amended data
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test(
        'Girl - Age above maximum range should throw ArgumentError (Amended Data)',
        () {
      // Girls amended data ends at 17.5 decimal years
      const double ageAboveMax = 17.6;
      expect(
        () => service.estimateFinalAdultHeight(
          currentHeightCm: testCurrentHeight,
          ageDecimalYears: ageAboveMax,
          weightKg: testWeight,
          boneAgeDecimalYears: testBoneAge,
          midparentalHeightCm: testMidparentalHeight,
          sex: Sex.female,
          useAmendedData: true, // Explicitly use amended data
        ),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
