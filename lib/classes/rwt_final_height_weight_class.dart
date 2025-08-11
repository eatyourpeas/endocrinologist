import "package:endocrinologist/enums/enums.dart";

/// A class to hold growth prediction coefficients for a specific age and sex.
class RWTFinalHeightWeights {
  /// Age in years.
  final int ageYears;

  /// Age in months.
  final int ageMonths;

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

  /// Constructs a [RWTFinalHeightWeights] object with the given parameters.
  RWTFinalHeightWeights({
    required this.ageYears,
    required this.ageMonths,
    required this.heightLengthCoefficient,
    required this.weightCoefficient,
    required this.midparentalHeightCoefficient,
    required this.boneAgeCoefficient,
    required this.regressionIntercept,
    required this.sex,
  });

  /// Calculated field: Age in decimal years.
  double get decimalYears => ageYears + (ageMonths / 12.0);

  /// A factory constructor to create a [RWTFinalHeightWeights] object from a map (e.g., from JSON).
  factory RWTFinalHeightWeights.fromMap(Map<String, dynamic> map) {
    return RWTFinalHeightWeights(
      ageYears: map['age_years'] as int,
      ageMonths: map['age_months'] as int,
      heightLengthCoefficient: map['height_length_coefficient'] as double,
      weightCoefficient: map['weight_coefficient'] as double,
      midparentalHeightCoefficient: map['midparental_height_coefficient'] as double,
      boneAgeCoefficient: map['bone_age_coefficient'] as double,
      regressionIntercept: map['regression_intercept'] as double,
      sex: Sex.values.firstWhere((e) => e.toString() == 'Sex.${map['sex']}', orElse: () => Sex.male), // Default to male if sex is not found
    );
  }

  /// Converts a [RWTFinalHeightWeights] object to a map (e.g., for serialization to JSON).
  Map<String, dynamic> toMap() {
    return {
      'age_years': ageYears,
      'age_months': ageMonths,
      'height_length_coefficient': heightLengthCoefficient,
      'weight_coefficient': weightCoefficient,
      'midparental_height_coefficient': midparentalHeightCoefficient,
      'bone_age_coefficient': boneAgeCoefficient,
      'regression_intercept': regressionIntercept,
      'sex': sex.toString().split('.').last, // 'Sex.male' -> 'male'
      // decimalYears is a calculated getter and typically not part of the serialized map
      // unless specifically needed for persistence, in which case it would be calculated
      // from ageYears and ageMonths on retrieval.
    };
  }

  @override
  String toString() {
    return 'RWTFinalHeightWeights(ageYears: $ageYears, ageMonths: $ageMonths, decimalYears: $decimalYears, heightLengthCoefficient: $heightLengthCoefficient, weightCoefficient: $weightCoefficient, midparentalHeightCoefficient: $midparentalHeightCoefficient, boneAgeCoefficient: $boneAgeCoefficient, regressionIntercept: $regressionIntercept, sex: $sex)';
  }
}
