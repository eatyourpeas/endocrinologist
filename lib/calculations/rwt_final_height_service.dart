import "package:endocrinologist/enums/enums.dart";
import "package:endocrinologist/classes/rwt_final_height_weight_class.dart";

/// A service class to manage and query RWTFinalHeightWeights data.
class RWTFinalHeightPredictionService {
  /// Raw CSV data for boys.
  static const String _boysCsvData = r'''
age_years,age_months,height_length_coefficient,weight_coefficient,midparental_height_coefficient,bone_age_coefficient,regression_intercept
0,0,0.966,0.199,0.606,-0.673,1.632
0,3,1.032,0.086,0.580,-0.417,-1.841
0,6,1.086,-0.016,0.559,-0.205,-4.892
0,9,1.130,-0.106,0.540,-0.033,-7.528
1,0,1.163,-0.186,0.523,0.104,-9.764
1,3,1.189,-0.256,0.509,0.211,-11.618
1,6,1.207,-0.316,0.496,0.291,-13.114
1,9,1.219,-0.369,0.485,0.349,-14.278
2,0,1.227,-0.413,0.475,0.388,-15.139
2,3,1.230,-0.450,0.466,0.410,-15.729
2,6,1.229,-0.481,0.458,0.419,-16.081
2,9,1.226,-0.505,0.451,0.417,-16.228
3,0,1.221,-0.523,0.444,0.405,-16.201
3,3,1.214,-0.537,0.437,0.387,-16.034
3,6,1.206,-0.546,0.431,0.363,-15.758
3,9,1.197,-0.550,0.424,0.335,-15.400
4,0,1.188,-0.551,0.418,0.303,-14.990
4,3,1.179,-0.548,0.412,0.269,-14.551
4,6,1.169,-0.543,0.406,0.234,-14.106
4,9,1.160,-0.535,0.400,0.198,-13.672
5,0,1.152,-0.524,0.394,0.161,-13.267
5,3,1.143,-0.512,0.389,0.123,-12.901
5,6,1.135,-0.499,0.383,0.085,-12.583
5,9,1.127,-0.484,0.378,0.046,-12.318
6,0,1.120,-0.468,0.373,0.006,-12.107
6,3,1.113,-0.451,0.369,-0.034,-11.948
6,6,1.106,-0.434,0.365,-0.077,-11.834
6,9,1.100,-0.417,0.361,-0.121,-11.756
7,0,1.093,-0.400,0.358,-0.167,-11.701
7,3,1.086,-0.382,0.356,-0.217,-11.652
7,6,1.079,-0.365,0.354,-0.270,-11.592
7,9,1.071,-0.349,0.353,-0.327,-11.498
8,0,1.063,-0.333,0.353,-0.389,-11.349
8,3,1.054,-0.317,0.353,-0.455,-11.118
8,6,1.044,-0.303,0.355,-0.527,-10.779
8,9,1.033,-0.289,0.357,-0.605,-10.306
9,0,1.063,-0.333,0.353,-0.389,-11.349
9,3,1.054,-0.317,0.353,-0.455,-11.118
9,6,1.044,-0.303,0.355,-0.527,-10.779
9,9,1.033,-0.289,0.357,-0.605,-10.306
10,0,1.021,-0.276,0.360,-0.690,-9.671
10,3,1.008,-0.263,0.363,-0.781,-8.848
10,6,0.993,-0.252,0.368,-0.878,-7.812
10,9,0.977,-0.241,0.373,-0.983,-6.540
11,0,0.960,-0.231,0.378,-1.094,-5.010
11,3,0.942,-0.222,0.384,-1.211,-3.206
11,6,0.923,-0.213,0.390,-1.335,-1.113
11,9,0.902,-0.206,0.397,-1.464,1.273
12,0,0.881,-0.198,0.403,-1.597,3.958
12,3,0.859,-0.191,0.409,-1.735,6.931
12,6,0.837,-0.184,0.414,-1.875,10.181
12,9,0.815,-0.177,0.418,-2.015,13.684
13,0,0.794,-0.170,0.421,-2.156,17.405
13,3,0.773,-0.163,0.422,-2.294,21.297
13,6,0.755,-0.155,0.422,-2.427,25.304
13,9,0.738,-0.146,0.418,-2.553,29.349
14,0,0.724,-0.136,0.412,-2.668,33.345
14,3,0.714,-0.125,0.401,-2.771,37.183
14,6,0.709,-0.112,0.387,-2.856,40.738
14,9,0.709,-0.098,0.367,-2.922,43.869
15,0,0.717,-0.081,0.342,-2.962,46.403
15,3,0.732,-0.062,0.310,-2.973,48.154
15,6,0.756,-0.040,0.271,-2.949,48.898
15,9,0.792,-0.015,0.223,-2.885,48.402
16,0,0.839,-0.014,0.167,-2.776,46.391
''';

  /// Raw CSV data for girls.
  static const String _girlsCsvData = r'''
age_years,age_months,height_length_coefficient,weight_coefficient,midparental_height_coefficient,bone_age_coefficient,regression_intercept
1,0,1.087,-0.271,0.386,0.434,21.729
1,3,1.112,-0.369,0.367,0.094,20.684
1,6,1.134,-0.455,0.349,-0.172,19.957
1,9,1.153,-0.530,0.332,-0.374,19.463
2,0,1.170,-0.594,0.316,-0.523,19.131
2,3,1.183,-0.648,0.301,-0.623,18.908
2,6,1.192,-0.690,0.287,-0.690,18.740
2,9,1.204,-0.729,0.274,-0.725,18.604
3,0,1.210,-0.757,0.262,-0.736,18.474
3,3,1.215,-0.777,0.251,-0.729,18.337
3,6,1.217,-0.791,0.241,-0.711,18.187
3,9,1.217,-0.798,0.232,-0.684,18.024
4,0,1.215,-0.800,0.224,-0.655,17.855
4,3,1.212,-0.797,0.217,-0.626,17.691
4,6,1.206,-0.789,0.210,-0.600,17.548
4,9,1.199,-0.777,0.205,-0.582,17.444
5,0,1.190,-0.761,0.200,-0.571,17.398
5,3,1.180,-0.742,0.197,-0.572,17.431
5,6,1.168,-0.721,0.193,-0.584,17.567
5,9,1.155,-0.697,0.191,-0.609,17.826
6,0,1.140,-0.671,0.190,-0.647,18.229
6,3,1.124,-0.644,0.189,-0.700,18.796
6,6,1.107,-0.616,0.188,-0.766,19.544
6,9,1.089,-0.587,0.189,-0.845,20.489
7,0,1.069,-0.557,0.189,-0.938,21.642
7,3,1.049,-0.527,0.191,-1.043,23.017
7,6,1.028,-0.498,0.192,-1.158,24.602
7,9,1.006,-0.468,0.194,-1.284,26.416
8,0,0.983,-0.439,0.196,-1.418,28.448
8,3,0.960,-0.411,0.199,-1.558,30.690
8,6,0.937,-0.384,0.202,-1.704,33.129
8,9,0.914,-0.359,0.204,-1.853,35.747
9,0,0.891,-0.334,0.207,-2.003,38.520
9,3,0.868,-0.311,0.210,-2.154,41.421
9,6,0.845,-0.289,0.212,-2.301,44.415
9,9,0.824,-0.269,0.214,-2.444,47.464
10,0,0.803,-0.250,0.216,-2.581,50.525
10,3,0.783,-0.233,0.217,-2.710,53.548
10,6,0.766,-0.217,0.217,-2.829,56.481
10,9,0.749,-0.203,0.217,-2.936,59.267
11,0,0.736,-0.190,0.216,-3.029,61.841
11,3,0.724,-0.179,0.214,-3.108,64.136
11,6,0.716,-0.169,0.211,-3.171,66.093
11,9,0.711,-0.159,0.206,-3.217,67.627
12,0,0.710,-0.151,0.201,-3.245,68.670
12,3,0.713,-0.143,0.193,-3.254,69.140
12,6,0.720,-0.136,0.184,-3.244,68.966
12,9,0.733,-0.129,0.173,-3.214,68.061
13,0,0.752,-0.121,0.160,-3.166,66.339
13,3,0.777,-0.113,0.144,-3.100,63.728
13,6,0.810,-0.105,0.127,-3.015,60.150
13,9,0.850,-0.085,0.106,-2.915,55.522
14,0,0.898,-0.083,0.083,-2.800,49.781
''';

  final List<RWTFinalHeightWeights> _allData;

  /// Constructs a [RWTFinalHeightPredictionService] and populates it with data
  /// from the embedded CSV strings for boys and girls.
  RWTFinalHeightPredictionService() : _allData = [] {
    _loadData();
  }

  /// Parses the CSV data and populates the [_allData] list.
  void _loadData() {
    // Process boys data
    final List<String> boysLines = _boysCsvData.trim().split('\n');
    final List<String> boysHeaders = boysLines.first.split(',');
    for (int i = 1; i < boysLines.length; i++) {
      final List<String> values = boysLines[i].split(',');
      if (values.length == boysHeaders.length) {
        _allData.add(_parseRow(boysHeaders, values, Sex.male));
      }
    }

    // Process girls data
    final List<String> girlsLines = _girlsCsvData.trim().split('\n');
    final List<String> girlsHeaders = girlsLines.first.split(',');
    for (int i = 1; i < girlsLines.length; i++) {
      final List<String> values = girlsLines[i].split(',');
      if (values.length == girlsHeaders.length) {
        _allData.add(_parseRow(girlsHeaders, values, Sex.female));
      }
    }
  }

  /// Helper method to parse a single CSV row into an RWTFinalHeightWeights object.
  RWTFinalHeightWeights _parseRow(List<String> headers, List<String> values, Sex sex) {
    // Create a map from headers and values for easy access by key
    final Map<String, dynamic> rowMap = {};
    for (int i = 0; i < headers.length; i++) {
      final String header = headers[i].trim();
      final String value = values[i].trim();
      switch (header) {
        case 'age_years':
          rowMap[header] = int.parse(value);
          break;
        case 'age_months':
          rowMap[header] = int.parse(value);
          break;
        case 'height_length_coefficient':
        case 'weight_coefficient':
        case 'midparental_height_coefficient':
        case 'bone_age_coefficient':
        case 'regression_intercept':
          rowMap[header] = double.parse(value);
          break;
        default:
        // Ignore unknown headers or handle as needed
          break;
      }
    }
    rowMap['sex'] = sex.toString().split('.').last; // Add sex to the map for fromMap
    return RWTFinalHeightWeights.fromMap(rowMap);
  }

  /// Returns an immutable list of all loaded growth data.
  List<RWTFinalHeightWeights> get allData => List.unmodifiable(_allData);

  /// Filters the growth data by age (years) and sex.
  ///
  /// Returns a list of [RWTFinalHeightWeights] objects matching the criteria.
  List<RWTFinalHeightWeights> getDataByAgeAndSex({
    int? ageYears,
    Sex? sex,
  }) {
    return _allData.where((data) {
      bool matchesAge = (ageYears == null || data.ageYears == ageYears);
      bool matchesSex = (sex == null || data.sex == sex);
      return matchesAge && matchesSex;
    }).toList();
  }

  /// Retrieves a specific [RWTFinalHeightWeights] object by exact age and sex.
  ///
  /// Returns null if no matching data is found.
  RWTFinalHeightWeights? getExactData({
    required int ageYears,
    required int ageMonths,
    required Sex sex,
  }) {
    try {
      return _allData.firstWhere(
            (data) =>
        data.ageYears == ageYears &&
            data.ageMonths == ageMonths &&
            data.sex == sex,
      );
    } catch (e) {
      // No element found, return null
      return null;
    }
  }

  /// Helper function to perform linear interpolation.
  /// Given a value `x` within a range `[x1, x2]`,
  /// and corresponding function values `y1` and `y2`,
  /// this function calculates the interpolated value `y`.
  double _linearInterpolate(double x, double x1, double y1, double x2, double y2) {
    if (x1 == x2) {
      return y1; // Should not happen in this specific use case if x is within bounds and not an exact match
    }
    return y1 + (y2 - y1) * ((x - x1) / (x2 - x1));
  }

  /// Helper function to calculate final height based on coefficients.
  double _calculateHeight(
      double currentHeightCm,
      double weightKg,
      double boneAgeDecimalYears,
      double midparentalHeightCm,
      RWTFinalHeightWeights coefficients,
      ) {
    return (currentHeightCm * coefficients.heightLengthCoefficient) +
        (weightKg * coefficients.weightCoefficient) +
        (midparentalHeightCm * coefficients.midparentalHeightCoefficient) +
        (boneAgeDecimalYears * coefficients.boneAgeCoefficient) +
        coefficients.regressionIntercept;
  }

  /// Estimates the final adult height of a child.
  ///
  /// This function takes a child's current measurements and estimates their
  /// final adult height in centimeters. It uses the pre-loaded growth data
  /// to find appropriate coefficients, either directly or through linear interpolation.
  ///
  /// Parameters:
  /// - [currentHeightCm]: The child's current height in centimeters.
  /// - [ageDecimalYears]: The child's current age in decimal years.
  /// - [weightKg]: The child's current weight in kilograms.
  /// - [boneAgeDecimalYears]: The child's bone age in decimal years.
  /// - [midparentalHeightCm]: The midparental height in centimeters.
  /// - [sex]: The sex of the child (male or female).
  ///
  /// Returns the estimated final adult height in centimeters.
  ///
  /// Throws an [ArgumentError] if the provided [ageDecimalYears] is outside
  /// the supported range for the given [sex] in the dataset.
  double estimateFinalAdultHeight({
    required double currentHeightCm,
    required double ageDecimalYears,
    required double weightKg,
    required double boneAgeDecimalYears,
    required double midparentalHeightCm,
    required Sex sex,
  }) {
    // Filter and sort the data specific to the provided sex
    final List<RWTFinalHeightWeights> dataForSex = _allData
        .where((data) => data.sex == sex)
        .toList()
      ..sort((a, b) => a.decimalYears.compareTo(b.decimalYears));

    if (dataForSex.isEmpty) {
      throw ArgumentError('No growth data available for $sex. Cannot estimate height.');
    }

    // Determine the min and max age in the dataset for the given sex
    final double minAge = dataForSex.first.decimalYears;
    final double maxAge = dataForSex.last.decimalYears;

    // Check if the provided age is within the supported range
    if (ageDecimalYears < minAge || ageDecimalYears > maxAge) {
      throw ArgumentError(
        'Age $ageDecimalYears is beyond the supported range for $sex. '
            'Supported range: $minAge to $maxAge decimal years.',
      );
    }

    // Try to find an exact match for the ageDecimalYears
    RWTFinalHeightWeights? exactMatch;
    for (var data in dataForSex) {
      // Using a small epsilon for floating-point comparison
      if ((data.decimalYears - ageDecimalYears).abs() < 0.00001) {
        exactMatch = data;
        break;
      }
    }

    // If an exact match is found, use its coefficients for calculation
    if (exactMatch != null) {
      return _calculateHeight(
        currentHeightCm,
        weightKg,
        boneAgeDecimalYears,
        midparentalHeightCm,
        exactMatch,
      );
    } else {
      // If no exact match, perform linear interpolation to get the coefficients
      RWTFinalHeightWeights lowerBound = dataForSex.lastWhere(
            (data) => data.decimalYears < ageDecimalYears,
        orElse: () => dataForSex.first, // Fallback if age is at min boundary, though checked above
      );
      RWTFinalHeightWeights upperBound = dataForSex.firstWhere(
            (data) => data.decimalYears > ageDecimalYears,
        orElse: () => dataForSex.last, // Fallback if age is at max boundary, though checked above
      );

      // Interpolate each coefficient based on the surrounding age points
      final double interpolatedHeightLengthCoefficient = _linearInterpolate(
        ageDecimalYears,
        lowerBound.decimalYears,
        lowerBound.heightLengthCoefficient,
        upperBound.decimalYears,
        upperBound.heightLengthCoefficient,
      );
      final double interpolatedWeightCoefficient = _linearInterpolate(
        ageDecimalYears,
        lowerBound.decimalYears,
        lowerBound.weightCoefficient,
        upperBound.decimalYears,
        upperBound.weightCoefficient,
      );
      final double interpolatedMidparentalHeightCoefficient = _linearInterpolate(
        ageDecimalYears,
        lowerBound.decimalYears,
        lowerBound.midparentalHeightCoefficient,
        upperBound.decimalYears,
        upperBound.midparentalHeightCoefficient,
      );
      final double interpolatedBoneAgeCoefficient = _linearInterpolate(
        ageDecimalYears,
        lowerBound.decimalYears,
        lowerBound.boneAgeCoefficient,
        upperBound.decimalYears,
        upperBound.boneAgeCoefficient,
      );
      final double interpolatedRegressionIntercept = _linearInterpolate(
        ageDecimalYears,
        lowerBound.decimalYears,
        lowerBound.regressionIntercept,
        upperBound.decimalYears,
        upperBound.regressionIntercept,
      );

      // Create a temporary RWTFinalHeightWeights object to hold the interpolated coefficients
      final RWTFinalHeightWeights interpolatedCoefficients = RWTFinalHeightWeights(
        ageYears: ageDecimalYears.floor(), // These fields are just for object creation, not used in calculation
        ageMonths: ((ageDecimalYears - ageDecimalYears.floor()) * 12).round(),
        heightLengthCoefficient: interpolatedHeightLengthCoefficient,
        weightCoefficient: interpolatedWeightCoefficient,
        midparentalHeightCoefficient: interpolatedMidparentalHeightCoefficient,
        boneAgeCoefficient: interpolatedBoneAgeCoefficient,
        regressionIntercept: interpolatedRegressionIntercept,
        sex: sex,
      );

      // Calculate the final height using the interpolated coefficients
      return _calculateHeight(
        currentHeightCm,
        weightKg,
        boneAgeDecimalYears,
        midparentalHeightCm,
        interpolatedCoefficients,
      );
    }
  }
}