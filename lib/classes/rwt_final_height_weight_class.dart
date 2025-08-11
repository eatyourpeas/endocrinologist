import "package:endocrinologist/enums/enums.dart";

/// A class to hold growth prediction coefficients for a specific age and sex.
/// A class to hold growth prediction coefficients for a specific age and sex.
class RWTFinalHeightWeights {
  /// Age in years (optional, used if data originally came in years/months).
  final int? ageYears;

  /// Age in months (optional, used if data originally came in years/months).
  final int? ageMonths;

  /// Directly provided or calculated age in decimal years.
  final double _decimalYearsValue; // Private field to store the decimal years

  /// Coefficient for height/length.
  final double heightLengthCoefficient;

  /// Coefficient for weight.
  final double weightCoefficient;

  /// Coefficient for midparental height.
  final double midparentalHeightCoefficient;

  /// Coefficient for bone age.
  final double boneAgeCoefficient;

  /// Regression intercept value.
  final double regressionIntercept;

  /// The sex associated with this growth data.
  final Sex sex;

  /// Private constructor for internal use by named factories.
  /// Ensures _decimalYearsValue is always initialized.
  RWTFinalHeightWeights._({
    this.ageYears,
    this.ageMonths,
    required double decimalYearsValue, // Must always be provided
    required this.heightLengthCoefficient,
    required this.weightCoefficient,
    required this.midparentalHeightCoefficient,
    required this.boneAgeCoefficient,
    required this.regressionIntercept,
    required this.sex,
  }) : _decimalYearsValue = decimalYearsValue;

  /// Factory constructor for data provided in years and months.
  factory RWTFinalHeightWeights.fromYearsMonths({
    required int ageYears,
    required int ageMonths,
    required double heightLengthCoefficient,
    required double weightCoefficient,
    required double midparentalHeightCoefficient,
    required double boneAgeCoefficient,
    required double regressionIntercept,
    required Sex sex,
  }) {
    final double calculatedDecimalYears = ageYears + (ageMonths / 12.0);
    return RWTFinalHeightWeights._(
      ageYears: ageYears,
      ageMonths: ageMonths,
      decimalYearsValue: calculatedDecimalYears,
      heightLengthCoefficient: heightLengthCoefficient,
      weightCoefficient: weightCoefficient,
      midparentalHeightCoefficient: midparentalHeightCoefficient,
      boneAgeCoefficient: boneAgeCoefficient,
      regressionIntercept: regressionIntercept,
      sex: sex,
    );
  }

  /// Factory constructor for data provided directly in decimal years.
  factory RWTFinalHeightWeights.fromDecimalYears({
    required double decimalYears,
    required double heightLengthCoefficient,
    required double weightCoefficient,
    required double midparentalHeightCoefficient,
    required double boneAgeCoefficient,
    required double regressionIntercept,
    required Sex sex,
  }) {
    // Optionally derive ageYears and ageMonths for consistency, or leave null if not strictly needed
    final int derivedAgeYears = decimalYears.floor();
    final int derivedAgeMonths = ((decimalYears - derivedAgeYears) * 12).round();

    return RWTFinalHeightWeights._(
      ageYears: derivedAgeYears, // Derived from decimal
      ageMonths: derivedAgeMonths, // Derived from decimal
      decimalYearsValue: decimalYears,
      heightLengthCoefficient: heightLengthCoefficient,
      weightCoefficient: weightCoefficient,
      midparentalHeightCoefficient: midparentalHeightCoefficient,
      boneAgeCoefficient: boneAgeCoefficient,
      regressionIntercept: regressionIntercept,
      sex: sex,
    );
  }

  /// Calculated field: Age in decimal years.
  /// Always returns the correct decimal age regardless of input format.
  double get decimalYears => _decimalYearsValue;

  /// A general factory constructor to create a [RWTFinalHeightWeights] object from a map (e.g., from CSV parsing).
  /// It intelligently handles both 'age_decimal' and 'age_years'/'age_months' formats
  /// by delegating to the appropriate named factory constructor.
  factory RWTFinalHeightWeights.fromMap(Map<String, dynamic> map) {
    // Extract common fields
    final double heightLengthCoefficient = map['height_length_coefficient'] as double;
    final double weightCoefficient = map['weight_coefficient'] as double;
    final double midparentalHeightCoefficient = map['midparental_height_coefficient'] as double;
    final double boneAgeCoefficient = map['bone_age_coefficient'] as double;
    final double regressionIntercept = map['regression_intercept'] as double;
    final Sex sex = Sex.values.firstWhere((e) => e.toString() == 'Sex.${map['sex']}', orElse: () => Sex.male);

    if (map.containsKey('age_decimal')) {
      return RWTFinalHeightWeights.fromDecimalYears(
        decimalYears: map['age_decimal'] as double,
        heightLengthCoefficient: heightLengthCoefficient,
        weightCoefficient: weightCoefficient,
        midparentalHeightCoefficient: midparentalHeightCoefficient,
        boneAgeCoefficient: boneAgeCoefficient,
        regressionIntercept: regressionIntercept,
        sex: sex,
      );
    } else if (map.containsKey('age_years') && map.containsKey('age_months')) {
      return RWTFinalHeightWeights.fromYearsMonths(
        ageYears: map['age_years'] as int,
        ageMonths: map['age_months'] as int,
        heightLengthCoefficient: heightLengthCoefficient,
        weightCoefficient: weightCoefficient,
        midparentalHeightCoefficient: midparentalHeightCoefficient,
        boneAgeCoefficient: boneAgeCoefficient,
        regressionIntercept: regressionIntercept,
        sex: sex,
      );
    } else {
      throw ArgumentError('Map must contain either "age_decimal" or "age_years" and "age_months"');
    }
  }

  /// Converts a [RWTFinalHeightWeights] object to a map (e.g., for serialization to JSON).
  /// Prioritizes decimalYears if available, otherwise years/months if present.
  Map<String, dynamic> toMap() {
    final Map<String, dynamic> map = {
      'height_length_coefficient': heightLengthCoefficient,
      'weight_coefficient': weightCoefficient,
      'midparental_height_coefficient': midparentalHeightCoefficient,
      'bone_age_coefficient': boneAgeCoefficient,
      'regression_intercept': regressionIntercept,
      'sex': sex.toString().split('.').last,
    };
    // Prioritize the original input fields if they exist, otherwise use decimal.
    if (ageYears != null && ageMonths != null) {
      map['age_years'] = ageYears;
      map['age_months'] = ageMonths;
    } else {
      map['age_decimal'] = decimalYears; // Fallback to decimal if original was decimal
    }
    return map;
  }

  @override
  String toString() {
    return 'RWTFinalHeightWeights(decimalYears: $decimalYears, heightLengthCoefficient: $heightLengthCoefficient, weightCoefficient: $weightCoefficient, midparentalHeightCoefficient: $midparentalHeightCoefficient, boneAgeCoefficient: $boneAgeCoefficient, regressionIntercept: $regressionIntercept, sex: $sex)';
  }
}
