// Import for statistical calculations
import 'package:endocrinologist/calculations/centile.dart';
import 'package:endocrinologist/enums/enums.dart';

class FetalCLLData {
  /*
  Alaei M, Rohani F, Norouzi E, Hematian Boroujeni N, Tafreshi RI, Salehiniya H, Soheilipour F.
  The Nomogram of Clitoral Length and Width in Iranian Term and Preterm Neonates.
  Front Endocrinol (Lausanne). 2020;11:297.
  */

  // data
  static List<List<dynamic>> _rawData = [
    [28, 30, 3.28, 3.87, 4.46, 5.05, 5.03, 5.91, 6.79, 7.67],
    [30, 57, 3.32, 3.68, 4.04, 4.4, 5.03, 5.52, 6.01, 6.5],
    [32, 74, 3.41, 3.77, 4.13, 4.49, 5.14, 5.65, 6.16, 6.67],
    [34, 104, 3.69, 4.17, 4.65, 5.13, 5.53, 6.12, 6.71, 7.3],
    [36, 128, 4.08, 4.5, 4.92, 5.34, 5.83, 6.29, 6.75, 7.21],
    [38, 187, 4.21, 4.64, 5.07, 5.5, 6.11, 6.49, 6.87, 7.25],
    [42, 187, 4.21, 4.64, 5.07, 5.5, 6.11, 6.49, 6.87, 7.25]
  ];

// Static list to store the data
  static List<FetalCLLData> dataList = _createFetalCLLDataList(_rawData);

// class members and definition
  final int gestationalWeeks;
  final int numberOfCases;
  final double meanWidth;
  final double meanWidthOneSDS;
  final double meanWidthTwoSDS;
  final double meanWidthThreeSDS;
  final double meanLength;
  final double meanLengthOneSDS;
  final double meanLengthTwoSDS;
  final double meanLengthThreeSDS;
  static String reference =
      "Alaei M, Rohani F, Norouzi E, Hematian Boroujeni N, Tafreshi RI, Salehiniya H, Soheilipour F. The Nomogram of Clitoral Length and Width in Iranian Term and Preterm Neonates. Front Endocrinol (Lausanne). 2020;11:297.";

  FetalCLLData._(
      {required this.gestationalWeeks,
      required this.numberOfCases,
      required this.meanWidth,
      required this.meanWidthOneSDS,
      required this.meanWidthTwoSDS,
      required this.meanWidthThreeSDS,
      required this.meanLength,
      required this.meanLengthOneSDS,
      required this.meanLengthTwoSDS,
      required this.meanLengthThreeSDS});

  static List<FetalCLLData> _createFetalCLLDataList(
      List<List<dynamic>> rawData) {
    List<FetalCLLData> dataList = [];
    for (var row in _rawData) {
      dataList.add(FetalCLLData._(
          gestationalWeeks: row[0] as int,
          numberOfCases: row[1] as int,
          meanWidth: row[2] as double,
          meanWidthOneSDS: row[3] as double,
          meanWidthTwoSDS: row[4] as double,
          meanWidthThreeSDS: row[5] as double,
          meanLength: row[6] as double,
          meanLengthOneSDS: row[7] as double,
          meanLengthTwoSDS: row[8] as double,
          meanLengthThreeSDS: row[9] as double));
    }
    return dataList;
  }

  // Factory constructor to call createFetalSPLDataList
  factory FetalCLLData.fromRawData(List<List<dynamic>> rawData) {
    _rawData = rawData; // Assign rawData to the private member
    dataList = _createFetalCLLDataList(rawData);
    // returning the first element:
    return dataList.isNotEmpty ? dataList[0] : throw Exception('Empty data');
  }

  // Class method to find the nearest gestation data
  static FetalCLLData? findNearestGestationCLLSizesForGestation(int gestation) {
    // Find the nearest gestation
    FetalCLLData? nearestData;
    int minDifference =
        double.maxFinite.toInt(); // Initialize with a large value
    for (var data in dataList) {
      int difference = (data.gestationalWeeks - gestation).abs();
      if (difference < minDifference) {
        minDifference = difference;
        nearestData = data;
      }
    }
    return nearestData;
  }

  // Calculates SDS and Centile using interpolation from normative data points.
  static (double sds, double centile) calculateSDSAndCentile({
    required int gestation,
    required double inputValue,
    required CLLMeasurementType measurementType,
  }) {
    FetalCLLData? nearestData =
        findNearestGestationCLLSizesForGestation(gestation);

    if (nearestData == null) {
      return (double.nan, double.nan);
    }

    double mean, val1SD, val2SD, val3SD;

    switch (measurementType) {
      case CLLMeasurementType.length:
        mean = nearestData.meanLength;
        val1SD = nearestData.meanLengthOneSDS;
        val2SD = nearestData.meanLengthTwoSDS;
        val3SD = nearestData.meanLengthThreeSDS;
        break;
      case CLLMeasurementType.width:
        mean = nearestData.meanWidth;
        val1SD = nearestData.meanWidthOneSDS;
        val2SD = nearestData.meanWidthTwoSDS;
        val3SD = nearestData.meanWidthThreeSDS;
        break;
    }

    // Define the points on the measurement vs. SDS scale
    // Each point is a record: (measurement_value, sds_score)
    // Access them later as point.$1 for value, point.$2 for sds

    // Symmetrical negative points are inferred based on the positive SD values.
    final List<(double, double)> sortedPoints = [
      (mean - (val3SD - mean), -3.0), // -3SD_value, -3.0 SDS
      (mean - (val2SD - mean), -2.0), // -2SD_value, -2.0 SDS
      (mean - (val1SD - mean), -1.0), // -1SD_value, -1.0 SDS
      (mean, 0.0), //  Mean_value,  0.0 SDS
      (val1SD, 1.0), // +1SD_value,  1.0 SDS
      (val2SD, 2.0), // +2SD_value,  2.0 SDS
      (val3SD, 3.0), // +3SD_value,  3.0 SDS
    ];

    // Check for values outside the +/-3SD range defined by your data points
    // sortedPoints.last is the (+3SD_value, 3.0) record
    // sortedPoints.first is the (-3SD_value, -3.0) record
    if (inputValue >= sortedPoints.last.$1) {
      // inputValue >= +3SD_value
      double sds = 3.0; // Cap at +3.0 SDS
      // Optional extrapolation logic can be added here if desired
      return (sds, sdsToCentile(sds));
    }
    if (inputValue <= sortedPoints.first.$1) {
      // inputValue <= -3SD_value
      double sds = -3.0; // Cap at -3.0 SDS
      // Optional extrapolation logic can be added here if desired
      return (sds, sdsToCentile(sds));
    }

    // Find the segment for interpolation
    for (int i = 0; i < sortedPoints.length - 1; i++) {
      var p0 =
          sortedPoints[i]; // Lower point of the segment: (value_low, sds_low)
      var p1 = sortedPoints[
          i + 1]; // Upper point of the segment: (value_high, sds_high)

      // Check if inputValue falls between p0's value and p1's value
      if (inputValue >= p0.$1 && inputValue <= p1.$1) {
        // Handle cases where the segment has zero width (p0 value == p1 value)
        // This indicates an issue with the normative data points.
        if ((p1.$1 - p0.$1).abs() < 1e-9) {
          // Using a small tolerance for double comparison
          // If inputValue is effectively at p0's value, use p0's SDS.
          // Otherwise (it's effectively at p1's value, or segment width is zero), use p1's SDS.
          // This is a simplification; you might log an error or handle differently.
          if ((inputValue - p0.$1).abs() < 1e-9) {
            double sds = p0.$2; // sds_low
            return (sds, sdsToCentile(sds));
          } else {
            double sds = p1.$2; // sds_high
            return (sds, sdsToCentile(sds));
          }
        }

        // Linearly interpolate for SDS
        // SDS = y0 + (inputValue - x0) * (y1 - y0) / (x1 - x0)
        // y0 = p0.$2 (sds_low)
        // x0 = p0.$1 (value_low)
        // y1 = p1.$2 (sds_high)
        // x1 = p1.$1 (value_high)
        double sds =
            p0.$2 + (inputValue - p0.$1) * (p1.$2 - p0.$2) / (p1.$1 - p0.$1);
        return (sds, sdsToCentile(sds));
      }
    }

    // Fallback: Should not be reached if inputValue is within the range of sortedPoints
    // or handled by the capping logic. This might occur for NaN inputValue or
    // if there's an unexpected issue with the sortedPoints data.
    return (double.nan, double.nan);
  }
}
