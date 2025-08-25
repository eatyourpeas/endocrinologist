import "package:endocrinologist/enums/enums.dart";
import "package:endocrinologist/classes/rwt_final_height_weight_class.dart";

/// A service class to manage and query RWTFinalHeightWeights data and predict final height.
class RWTFinalHeightPredictionService {
  /// Raw CSV data for boys (original format: age_years, age_months).
  static const String _boysCsvDataOriginal = r'''
age_years,age_months,height_length_coefficient,weight_coefficient,midparental_height_coefficient,bone_age_coefficient,regression_intercept
1,0,0.966,0.199,0.606,-0.673,1.632
1,3,1.032,0.086,0.580,-0.417,-1.841
1,6,1.086,-0.016,0.559,-0.205,-4.892
1,9,1.130,-0.106,0.540,-0.033,-7.528
2,0,1.163,-0.186,0.523,0.104,-9.764
2,3,1.189,-0.256,0.509,0.211,-11.618
2,6,1.207,-0.316,0.496,0.291,-13.114
2,9,1.219,-0.369,0.485,0.349,-14.278
3,0,1.227,-0.413,0.475,0.388,-15.139
3,3,1.230,-0.450,0.466,0.410,-15.729
3,6,1.229,-0.481,0.458,0.419,-16.081
3,9,1.226,-0.505,0.451,0.417,-16.228
4,0,1.221,-0.523,0.444,0.405,-16.201
4,3,1.214,-0.537,0.437,0.387,-16.034
4,6,1.206,-0.546,0.431,0.363,-15.758
4,9,1.197,-0.550,0.424,0.335,-15.400
5,0,1.188,-0.551,0.418,0.303,-14.990
5,3,1.179,-0.548,0.412,0.269,-14.551
5,6,1.169,-0.543,0.406,0.234,-14.106
5,9,1.160,-0.535,0.400,0.198,-13.672
6,0,1.152,-0.524,0.394,0.161,-13.267
6,3,1.143,-0.512,0.389,0.123,-12.901
6,6,1.135,-0.499,0.383,0.085,-12.583
6,9,1.127,-0.484,0.378,0.046,-12.318
7,0,1.120,-0.468,0.373,0.006,-12.107
7,3,1.113,-0.451,0.369,-0.034,-11.948
7,6,1.106,-0.434,0.365,-0.077,-11.834
7,9,1.100,-0.417,0.361,-0.121,-11.756
8,0,1.093,-0.400,0.358,-0.167,-11.701
8,3,1.086,-0.382,0.356,-0.217,-11.652
8,6,1.079,-0.365,0.354,-0.270,-11.592
8,9,1.071,-0.349,0.353,-0.327,-11.498
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

  /// Raw CSV data for boys (amended format: age_decimal, different column order).
  static const String _boysCsvDataAmended = r'''
age_decimal,regression_intercept,height_length_coefficient,weight_coefficient,midparental_height_coefficient,bone_age_coefficient
3.0,-27.2340,1.26246,-0.25019,0.53461,-0.65638
3.5,-28.2574,1.23505,-0.30869,0.53982,-0.70428
4.0,-28.9167,1.21348,-0.34595,0.53855,-0.76831
4.5,-29.2444,1.19675,-0.36472,0.53180,-0.73631
5.0,-29.2727,1.18387,-0.36721,0.52055,-0.78353
5.5,-29.0343,1.17385,-0.35645,0.50581,-0.80409
6.0,-28.5616,1.16573,-0.33493,0.48857,-0.82953
6.5,-27.8955,1.15849,-0.30526,0.46982,-0.86454
7.0,-27.0179,1.15117,-0.27008,0.45056,-0.91381
7.5,-25.8717,1.14277,-0.23200,0.43178,-0.98203
8.0,-24.4000,1.13231,-0.19364,0.41449,-1.07388
8.5,-22.5461,1.11880,-0.15762,0.39967,-1.19404
9.0,-20.2529,1.10126,-0.12657,0.38832,-1.34721
9.5,-17.0286,1.07869,-0.10311,0.38143,-1.53808
10.0,-12.5118,1.05012,-0.08985,0.38001,-1.77132
10.5,-6.8414,1.01698,-0.08062,0.37987,-2.04178
11.0,-0.1564,0.98228,-0.06811,0.37618,-2.32959
11.5,7.4041,0.94744,-0.05323,0.36898,-2.61742
12.0,15.7014,0.91384,-0.03687,0.35828,-2.88793
12.5,24.0267,0.88289,0.01995,0.34412,-3.12378
13.0,31.5226,0.85598,-0.00337,0.32651,-3.30763
13.5,37.8261,0.83452,0.01195,0.30490,-3.42213
14.0,42.5748,0.81989,0.02512,0.28108,-3.49946
14.5,45.4058,0.81349,0.03521,0.25333,-3.73776
15.0,45.9566,0.81674,0.04133,0.22220,-3.17620
15.5,43.7440,0.83101,0.04257,0.18777,-2.83994
16.0,37.8800,0.85772,0.03802,0.15006,-2.34764
16.5,27.3943,0.89825,0.02677,0.10908,-1.68196
17.0,11.3167,0.95402,0.00791,0.06487,-0.82556
17.5,-11.3232,1.02640,-0.01946,0.01745,0.23891
''';

  /// Raw CSV data for girls (original format: age_years, age_months).
  static const String _girlsCsvDataOriginal = r'''
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

  /// Raw CSV data for girls (amended format: age_decimal, different column order).
  static const String _girlsCsvDataAmended = r'''
age_decimal,regression_intercept,height_length_coefficient,weight_coefficient,midparental_height_coefficient,bone_age_coefficient
3.0,-23.9478,1.45753,-1.14127,0.39955,-0.16198
3.5,-20.3292,1.36486,-1.11756,0.40731,-0.24780
4.0,-17.4687,1.29673,-1.07989,0.40680,-0.31738
4.5,-15.2455,1.24936,-1.03034,0.39932,-0.37813
5.0,-13.5388,1.21884,-0.97101,0.38620,0.43747
5.5,-12.2278,1.20167,-0.90399,0.36875,-0.50281
6.0,-11.1916,1.19378,-0.83135,0.34829,-0.58157
6.5,-10.5424,1.19145,0.75518,0.32611,-0.68116
7.0,-10.0670,1.19089,-0.67757,0.30355,-0.80899
7.5,-9.1559,1.18832,-0.60062,0.28191,-0.97248
8.0,-7.1992,1.17992,-0.52639,0.26250,-1.17904
8.5,-3.5889,1.16192,-0.45698,0.24665,-1.43608
9.0,2.2858,1.13050,-0.39448,0.23366,-1.75101
9.5,10.7978,1.08188,-0.34097,0.23084,-2.13125
10.0,20.8509,1.01227,-0.29853,0.23610,-2.58422
10.5,30.8503,0.94329,-0.26275,0.23610,-2.96492
11.0,39.2013,0.89702,-0.22799,0.23100,-3.14271
11.5,44.3092,0.87033,-0.19458,0.21950,-3.14657
12.0,44.5791,0.86007,-0.16283,0.20291,-3.00544
12.5,41.0599,0.86311,-0.13304,0.18251,-2.74831
13.0,36.0835,0.87630,-0.10554,0.15961,-2.40411
13.5,29.8981,0.89652,-0.08063,0.13548,-2.00183
14.0,23.0799,0.92063,-0.05862,0.11144,-1.57041
14.5,15.7131,0.94548,-0.03984,0.08878,-1.13882
15.0,8.2098,0.96794,-0.02458,0.06879,-0.73603
15.5,1.6941,0.98488,-0.01317,0.05276,-0.39099
16.0,-2.4822,0.99315,-0.00591,0.04199,-0.13266
16.5,-3.6480,0.98962,-0.00312,0.03778,0.00999
17.0,-1.1320,0.97115,-0.00511,0.04141,0.00801
17.5,5.7371,0.93460,-0.01219,0.05419,-0.16758
''';

  final List<RWTFinalHeightWeights> _allDataOriginal;
  final List<RWTFinalHeightWeights> _allDataAmended;

  /// Constructs a [RWTFinalHeightPredictionService] and populates it with data
  /// from the embedded CSV strings for original and amended datasets.
  RWTFinalHeightPredictionService()
      : _allDataOriginal = [],
        _allDataAmended = [] {
    _loadData();
  }

  /// Parses the CSV data and populates the [_allDataOriginal] and [_allDataAmended] lists.
  void _loadData() {
    // Process original boys data
    final List<String> boysOriginalLines =
        _boysCsvDataOriginal.trim().split('\n');
    final List<String> boysOriginalHeaders = boysOriginalLines.first.split(',');
    for (int i = 1; i < boysOriginalLines.length; i++) {
      final List<String> values = boysOriginalLines[i].split(',');
      if (values.length == boysOriginalHeaders.length) {
        _allDataOriginal.add(_parseOriginalBoyRow(boysOriginalHeaders, values));
      } else {
        print(
            'Warning: Skipping malformed original boy data row: ${boysOriginalLines[i]}');
      }
    }

    // Process original girls data
    final List<String> girlsOriginalLines =
        _girlsCsvDataOriginal.trim().split('\n');
    final List<String> girlsOriginalHeaders =
        girlsOriginalLines.first.split(',');
    for (int i = 1; i < girlsOriginalLines.length; i++) {
      final List<String> values = girlsOriginalLines[i].split(',');
      if (values.length == girlsOriginalHeaders.length) {
        _allDataOriginal
            .add(_parseOriginalGirlRow(girlsOriginalHeaders, values));
      } else {
        print(
            'Warning: Skipping malformed original girl data row: ${girlsOriginalLines[i]}');
      }
    }

    // Process amended boys data
    final List<String> boysAmendedLines =
        _boysCsvDataAmended.trim().split('\n');
    final List<String> boysAmendedHeaders = boysAmendedLines.first
        .split(','); // Not strictly needed for parsing, but good for validation
    for (int i = 1; i < boysAmendedLines.length; i++) {
      final List<String> values = boysAmendedLines[i].split(',');
      if (values.length == 6) {
        // Expect 6 columns for amended format
        _allDataAmended.add(_parseAmendedBoyRow(values));
      } else {
        print(
            'Warning: Skipping malformed amended boy data row: ${boysAmendedLines[i]}');
      }
    }

    // Process amended girls data
    final List<String> girlsAmendedLines =
        _girlsCsvDataAmended.trim().split('\n');
    final List<String> girlsAmendedHeaders = girlsAmendedLines.first
        .split(','); // Not strictly needed for parsing, but good for validation
    for (int i = 1; i < girlsAmendedLines.length; i++) {
      final List<String> values = girlsAmendedLines[i].split(',');
      if (values.length == 6) {
        // Expect 6 columns for amended format
        _allDataAmended.add(_parseAmendedGirlRow(values));
      } else {
        print(
            'Warning: Skipping malformed amended girl data row: ${girlsAmendedLines[i]}');
      }
    }
  }

  /// Helper method to parse a single CSV row for original boys data.
  /// Uses RWTFinalHeightWeights.fromYearsMonths.
  RWTFinalHeightWeights _parseOriginalBoyRow(
      List<String> headers, List<String> values) {
    return RWTFinalHeightWeights.fromYearsMonths(
      ageYears: int.parse(values[headers.indexOf('age_years')].trim()),
      ageMonths: int.parse(values[headers.indexOf('age_months')].trim()),
      heightLengthCoefficient: double.parse(
          values[headers.indexOf('height_length_coefficient')].trim()),
      weightCoefficient:
          double.parse(values[headers.indexOf('weight_coefficient')].trim()),
      midparentalHeightCoefficient: double.parse(
          values[headers.indexOf('midparental_height_coefficient')].trim()),
      boneAgeCoefficient:
          double.parse(values[headers.indexOf('bone_age_coefficient')].trim()),
      regressionIntercept:
          double.parse(values[headers.indexOf('regression_intercept')].trim()),
      sex: Sex.male,
    );
  }

  /// Helper method to parse a single CSV row for original girls data.
  /// Uses RWTFinalHeightWeights.fromYearsMonths.
  RWTFinalHeightWeights _parseOriginalGirlRow(
      List<String> headers, List<String> values) {
    return RWTFinalHeightWeights.fromYearsMonths(
      ageYears: int.parse(values[headers.indexOf('age_years')].trim()),
      ageMonths: int.parse(values[headers.indexOf('age_months')].trim()),
      heightLengthCoefficient: double.parse(
          values[headers.indexOf('height_length_coefficient')].trim()),
      weightCoefficient:
          double.parse(values[headers.indexOf('weight_coefficient')].trim()),
      midparentalHeightCoefficient: double.parse(
          values[headers.indexOf('midparental_height_coefficient')].trim()),
      boneAgeCoefficient:
          double.parse(values[headers.indexOf('bone_age_coefficient')].trim()),
      regressionIntercept:
          double.parse(values[headers.indexOf('regression_intercept')].trim()),
      sex: Sex.female,
    );
  }

  /// Helper method to parse a single CSV row for amended boys data (decimal age format).
  /// Uses RWTFinalHeightWeights.fromDecimalYears.
  RWTFinalHeightWeights _parseAmendedBoyRow(List<String> values) {
    // Column order: age_decimal,regression_intercept,height_length_coefficient,weight_coefficient,midparental_height_coefficient,bone_age_coefficient
    return RWTFinalHeightWeights.fromDecimalYears(
      decimalYears: double.parse(values[0].trim()),
      regressionIntercept: double.parse(values[1].trim()),
      heightLengthCoefficient: double.parse(values[2].trim()),
      weightCoefficient: double.parse(values[3].trim()),
      midparentalHeightCoefficient: double.parse(values[4].trim()),
      boneAgeCoefficient: double.parse(values[5].trim()),
      sex: Sex.male,
    );
  }

  /// Helper method to parse a single CSV row for amended girls data (decimal age format).
  /// Uses RWTFinalHeightWeights.fromDecimalYears.
  RWTFinalHeightWeights _parseAmendedGirlRow(List<String> values) {
    // Column order: age_decimal,regression_intercept,height_length_coefficient,weight_coefficient,midparental_height_coefficient,bone_age_coefficient
    return RWTFinalHeightWeights.fromDecimalYears(
      decimalYears: double.parse(values[0].trim()),
      regressionIntercept: double.parse(values[1].trim()),
      heightLengthCoefficient: double.parse(values[2].trim()),
      weightCoefficient: double.parse(values[3].trim()),
      midparentalHeightCoefficient: double.parse(values[4].trim()),
      boneAgeCoefficient: double.parse(values[5].trim()),
      sex: Sex.female,
    );
  }

  /// Returns an immutable list of all loaded original growth data.
  List<RWTFinalHeightWeights> get allDataOriginal =>
      List.unmodifiable(_allDataOriginal);

  /// Returns an immutable list of all loaded amended growth data.
  List<RWTFinalHeightWeights> get allDataAmended =>
      List.unmodifiable(_allDataAmended);

  /// Filters the growth data by age (years) and sex from the specified dataset.
  ///
  /// Returns a list of [RWTFinalHeightWeights] objects matching the criteria.
  List<RWTFinalHeightWeights> getDataByAgeAndSex({
    int? ageYears,
    Sex? sex,
    bool useAmendedData = false, // New parameter
  }) {
    final List<RWTFinalHeightWeights> dataSource =
        useAmendedData ? _allDataAmended : _allDataOriginal;
    return dataSource.where((data) {
      bool matchesAge = (ageYears == null || data.ageYears == ageYears);
      bool matchesSex = (sex == null || data.sex == sex);
      return matchesAge && matchesSex;
    }).toList();
  }

  /// Retrieves a specific [RWTFinalHeightWeights] object by exact age and sex from the specified dataset.
  ///
  /// Returns null if no matching data is found.
  RWTFinalHeightWeights? getExactData({
    required int ageYears,
    required int ageMonths,
    required Sex sex,
    bool useAmendedData = false, // New parameter
  }) {
    final List<RWTFinalHeightWeights> dataSource =
        useAmendedData ? _allDataAmended : _allDataOriginal;
    try {
      return dataSource.firstWhere(
        (data) =>
            data.ageYears == ageYears &&
            data.ageMonths == ageMonths &&
            data.sex == sex,
      );
    } catch (e) {
      return null;
    }
  }

  /// Helper function to perform linear interpolation.
  double _linearInterpolate(
      double x, double x1, double y1, double x2, double y2) {
    if (x1 == x2) {
      return y1;
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
  /// final adult height in centimeters. It uses the specified growth data
  /// to find appropriate coefficients, either directly or through linear interpolation.
  ///
  /// Parameters:
  /// - [currentHeightCm]: The child's current height in centimeters.
  /// - [ageDecimalYears]: The child's current age in decimal years.
  /// - [weightKg]: The child's current weight in kilograms.
  /// - [boneAgeDecimalYears]: The child's bone age in decimal years.
  /// - [midparentalHeightCm]: The midparental height in centimeters.
  /// - [sex]: The sex of the child (male or female).
  /// - [useAmendedData]: A boolean flag to determine whether to use the amended
  ///   dataset (`true`) or the original dataset (`false`, default).
  ///
  /// Returns the estimated final adult height in centimeters.
  ///
  /// Throws an [ArgumentError] if the provided [ageDecimalYears] is outside
  /// the supported range for the given [sex] in the selected dataset.
  double estimateFinalAdultHeight({
    required double currentHeightCm,
    required double ageDecimalYears,
    required double weightKg,
    required double boneAgeDecimalYears,
    required double midparentalHeightCm,
    required Sex sex,
    bool useAmendedData = false, // New parameter
  }) {
    final List<RWTFinalHeightWeights> dataSource =
        useAmendedData ? _allDataAmended : _allDataOriginal;

    final List<RWTFinalHeightWeights> dataForSex = dataSource
        .where((data) => data.sex == sex)
        .toList()
      ..sort((a, b) => a.decimalYears.compareTo(b.decimalYears));

    if (dataForSex.isEmpty) {
      throw ArgumentError(
          'No growth data available for $sex in the selected dataset. Cannot estimate height.');
    }

    final double minAge = dataForSex.first.decimalYears;
    final double maxAge = dataForSex.last.decimalYears;

    if (ageDecimalYears < minAge || ageDecimalYears > maxAge) {
      throw ArgumentError(
        'Age $ageDecimalYears is beyond the supported range for $sex '
        'in the ${useAmendedData ? "amended" : "original"} dataset. '
        'Supported range: $minAge to $maxAge decimal years.',
      );
    }

    RWTFinalHeightWeights? exactMatch;
    for (var data in dataForSex) {
      if ((data.decimalYears - ageDecimalYears).abs() < 0.00001) {
        exactMatch = data;
        break;
      }
    }

    if (exactMatch != null) {
      return _calculateHeight(
        currentHeightCm,
        weightKg,
        boneAgeDecimalYears,
        midparentalHeightCm,
        exactMatch,
      );
    } else {
      RWTFinalHeightWeights lowerBound = dataForSex.lastWhere(
        (data) => data.decimalYears < ageDecimalYears,
        orElse: () => dataForSex.first,
      );
      RWTFinalHeightWeights upperBound = dataForSex.firstWhere(
        (data) => data.decimalYears > ageDecimalYears,
        orElse: () => dataForSex.last,
      );

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
      final double interpolatedMidparentalHeightCoefficient =
          _linearInterpolate(
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
      final RWTFinalHeightWeights interpolatedCoefficients =
          RWTFinalHeightWeights.fromDecimalYears(
        decimalYears:
            ageDecimalYears, // Use the actual decimal age for the interpolated object
        heightLengthCoefficient: interpolatedHeightLengthCoefficient,
        weightCoefficient: interpolatedWeightCoefficient,
        midparentalHeightCoefficient: interpolatedMidparentalHeightCoefficient,
        boneAgeCoefficient: interpolatedBoneAgeCoefficient,
        regressionIntercept: interpolatedRegressionIntercept,
        sex: sex,
      );

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
