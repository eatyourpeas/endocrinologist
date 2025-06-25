import 'dart:math';
import '../enums/enums.dart';
import '../referencedata/bulgarianspldata.dart';
import '../referencedata/indian_data.dart';

class PenileStatsCalculator {
  /// Calculates the Standard Deviation Score (SDS) for stretched penile length.
  ///
  /// [stretchedPenileLength]: The patient's measured stretched penile length in cm
  /// [decimalAgeYears]: The patient's age in decimal years.
  /// [referenceData]: The list of ChildSPLDataPoint forming the reference population.
  ///
  /// Returns the calculated SDS, or double.nan if data is insufficient.
  static double calculateStretchedPenileLengthSDS({
    required double measuredStretchedPenileLength,
    required double decimalAgeYears,
    required Ethnicity ethnicity,
  }) {
    var referenceData = childBulgarianSPLData;
    if (ethnicity == Ethnicity.Bulgarian){
      referenceData = childBulgarianSPLData;
    }
    if (ethnicity == Ethnicity.Indian){
      referenceData == IndianStretchedPenileLengthList;
      return _sdsForIndianMeasurement(decimalAgeYears, measuredStretchedPenileLength);
    }

    // --- 1. Interpolate P5, P50, and P95 values for the decimal age ---

    // Find the bounding integer ages
    final int lowerAge = decimalAgeYears.floor();
    final int upperAge = decimalAgeYears.ceil();
    final double fraction = decimalAgeYears - lowerAge;

    // Get reference values for the lower age
    final p5Lower = _getStretchedPenileLengthForAgeAndCentile(ethnicity, referenceData, lowerAge, Centile.P5);
    final p50Lower = _getStretchedPenileLengthForAgeAndCentile(ethnicity, referenceData, lowerAge, Centile.P50);
    final p95Lower = _getStretchedPenileLengthForAgeAndCentile(ethnicity, referenceData, lowerAge, Centile.P95);

    if (p5Lower == null || p50Lower == null || p95Lower == null) {
      // print("Warning: Insufficient data for lower age boundary ($lowerAge years).");
      // Attempt to use values from the closest available single age if only one boundary exists
      if (upperAge == lowerAge) return double.nan; // Can't interpolate if only one age and it's missing data
    }

    double interpolatedP5, interpolatedP50, interpolatedP95;

    if (lowerAge == upperAge) { // Age is an exact integer
      interpolatedP5 = p5Lower ?? double.nan;
      interpolatedP50 = p50Lower ?? double.nan;
      interpolatedP95 = p95Lower ?? double.nan;
    } else {
      // Get reference values for the upper age
      final p5Upper = _getStretchedPenileLengthForAgeAndCentile(ethnicity, referenceData, upperAge, Centile.P5);
      final p50Upper = _getStretchedPenileLengthForAgeAndCentile(ethnicity, referenceData, upperAge, Centile.P50);
      final p95Upper = _getStretchedPenileLengthForAgeAndCentile(ethnicity, referenceData, upperAge, Centile.P95);

      if (p5Upper == null || p50Upper == null || p95Upper == null) {
        // print("Warning: Insufficient data for upper age boundary ($upperAge years).");
        // Handle this case: e.g., extrapolate carefully, use closest, or return NaN
        // For simplicity, if one boundary is missing, we might not be able to interpolate robustly.
        // If critical, you might need more sophisticated extrapolation or error handling.
        return double.nan;
      }
      if (p5Lower == null || p50Lower == null || p95Lower == null) return double.nan; // Re-check after fetching upper

      // Linear interpolation
      interpolatedP5 = p5Lower + (p5Upper - p5Lower) * fraction;
      interpolatedP50 = p50Lower + (p50Upper - p50Lower) * fraction;
      interpolatedP95 = p95Lower + (p95Upper - p95Lower) * fraction;
    }

    if (interpolatedP5.isNaN || interpolatedP50.isNaN || interpolatedP95.isNaN) {
      // print("Error: Could not determine interpolated centiles for age $decimalAgeYears.");
      return double.nan;
    }

    // --- 2. Estimate Mean and Standard Deviation (SD) ---
    final double meanStretchedPenileLength = interpolatedP50; // P50 is our estimate for the mean

    // Estimate SD using the range between P95 and P5
    // P95 ≈ Mean + 1.645 * SD
    // P5  ≈ Mean - 1.645 * SD
    // (P95 - P5) ≈ 3.29 * SD
    // SD ≈ (P95 - P5) / 3.29
    // Ensure P95 > P5 to avoid division by zero or negative SD if data is unusual
    if (interpolatedP95 <= interpolatedP5) {
      // print("Warning: P95 is not greater than P5 for age $decimalAgeYears. Cannot reliably calculate SD.");
      // Alternative SD estimation if P95-P5 is not usable:
      // double sdFromP95 = (interpolatedP95 - meanCircumference) / 1.645;
      // double sdFromP5 = (meanCircumference - interpolatedP5) / 1.645;
      // if (sdFromP95 > 0) return (measuredCircumferenceCm - meanCircumference) / sdFromP95;
      // if (sdFromP5 > 0) return (measuredCircumferenceCm - meanCircumference) / sdFromP5;
      return double.nan; // Or handle as appropriate
    }
    final double standardDeviation = (interpolatedP95 - interpolatedP5) / (2 * 1.64485); // 1.64485 is Z for 95th/5th percentile

    if (standardDeviation <= 0) {
      // print("Warning: Calculated Standard Deviation is zero or negative for age $decimalAgeYears.");
      return double.nan; // Cannot calculate SDS with non-positive SD
    }

    // --- 3. Calculate SDS ---
    final double sds = (measuredStretchedPenileLength - meanStretchedPenileLength) / standardDeviation;

    return sds;
  }

  /// Helper function to get penile circumference for a specific integer age and centile.
  static double? _getStretchedPenileLengthForAgeAndCentile(
      Ethnicity ethnicity, List referenceData, int age, Centile centile) {
    try {
      final dataPoint = referenceData.firstWhere(
            (dp) => dp.age == age && dp.centile == centile,
      );
      return dataPoint.penileLengthCm;
    } catch (e) { // Catches StateError if no element is found
      // print("Data point not found for age $age and centile $centile.");
      return null; // Return null if data point doesn't exist
    }
  }

  static double _sdsForIndianMeasurement(double age, double measurement) {
    LmsResult? lmsResult = getLmsForAge(decimalAge: age, referenceData: IndianStretchedPenileLengthList);

    if (lmsResult == null) {
      // print("Error: Could not retrieve LMS parameters for age $age.");
      return double.nan; // Or throw an exception
    }

    double l = lmsResult.l;
    double m = lmsResult.m;
    double s = lmsResult.s;
    // double t = lmsResult.t; // 't' is not used in the standard BCCG formula for Z-score

    // Validate parameters to prevent division by zero or other math errors
    if (m <= 0) {
      // print("Error: M value ($m) must be positive for age $age.");
      return double.nan;
    }
    if (s <= 0) {
      // print("Error: S value ($s) must be positive for age $age.");
      return double.nan;
    }
    // L can be zero, which requires a special case for the formula.

    double sds;

    if (l != 0) {
      // Standard LMS formula for Z-score (BCCG) when L is not zero
      // Z = ( (Y / M)^L - 1 ) / (L * S)
      sds = (pow(measurement / m, l) - 1) / (l * s);
    } else {
      // Special case when L = 0 (implies a log-normal transformation)
      // Z = ln(Y / M) / S
      if (measurement <= 0) {
        // print("Error: Measurement ($measurement) must be positive when L=0 for age $age.");
        return double.nan; // Log of non-positive number is undefined
      }
      sds = log(measurement / m) / s;
    }

    return sds;
  }

}

class LmsResult {
  final double l;
  final double m;
  final double s;
  final double t;

  LmsResult({required this.l, required this.m, required this.s, required this.t});

  @override
  String toString() {
    return 'LMSResult(L: ${l.toStringAsFixed(3)}, M: ${m.toStringAsFixed(3)}, S: ${s.toStringAsFixed(3)}, T: ${t.toStringAsFixed(3)})';
  }
}

/// Finds and interpolates L, M, S, and T values for a given decimal age.
///
/// Returns an [LmsResult] containing the (potentially interpolated) l, m, s, and t values.
/// Returns null if the age is outside the range of the reference data or if data is insufficient.
LmsResult? getLmsForAge({
  required double decimalAge,
  required List<IndianStretchedPenileLength> referenceData,
}) {
  if (referenceData.isEmpty) {
    // print("Error: Reference data is empty.");
    return null;
  }

  // Ensure referenceData is sorted by ageYears.
  var sortedData = List<IndianStretchedPenileLength>.from(referenceData);
  sortedData.sort((a, b) => a.ageYears.compareTo(b.ageYears));

  IndianStretchedPenileLength? lowerBoundData;
  IndianStretchedPenileLength? upperBoundData;

  // Find the data points that bracket the decimalAge
  for (int i = 0; i < sortedData.length; i++) {
    if (sortedData[i].ageYears == decimalAge) {
      // Exact match for age (if decimalAge happens to be an integer)
      final exactMatch = sortedData[i];
      return LmsResult(l: exactMatch.l, m: exactMatch.m, s: exactMatch.s, t: exactMatch.t);
    }
    if (sortedData[i].ageYears < decimalAge) {
      lowerBoundData = sortedData[i];
    }
    if (sortedData[i].ageYears > decimalAge) {
      upperBoundData = sortedData[i];
      break; // Found the upper bound, no need to continue
    }
  }

  // 1. Age is below the lowest age in reference data
  if (lowerBoundData == null && upperBoundData != null) {
    // print("Warning: Age $decimalAge is below the minimum age (${upperBoundData.ageYears}) in reference data. Using values from the lowest age.");
    return LmsResult(l: upperBoundData.l, m: upperBoundData.m, s: upperBoundData.s, t: upperBoundData.t);
  }

  // 2. Age is above the highest age in reference data
  if (upperBoundData == null && lowerBoundData != null) {
    // print("Warning: Age $decimalAge is above the maximum age (${lowerBoundData.ageYears}) in reference data. Using values from the highest age.");
    return LmsResult(l: lowerBoundData.l, m: lowerBoundData.m, s: lowerBoundData.s, t: lowerBoundData.t);
  }

  // 3. Age is within the range and requires interpolation
  if (lowerBoundData != null && upperBoundData != null) {
    if (lowerBoundData.ageYears == upperBoundData.ageYears) {
      return LmsResult(l: lowerBoundData.l, m: lowerBoundData.m, s: lowerBoundData.s, t: lowerBoundData.t);
    }
    // Perform linear interpolation
    final double lowerAge = lowerBoundData.ageYears.toDouble();
    final double upperAge = upperBoundData.ageYears.toDouble();
    final double fraction = (decimalAge - lowerAge) / (upperAge - lowerAge);

    if (fraction < 0 || fraction > 1) {
      if (decimalAge <= lowerAge) return LmsResult(l: lowerBoundData.l, m: lowerBoundData.m, s: lowerBoundData.s, t: lowerBoundData.t);
      if (decimalAge >= upperAge) return LmsResult(l: upperBoundData.l, m: upperBoundData.m, s: upperBoundData.s, t: upperBoundData.t);
      return null; // Or handle as an error
    }


    final double interpolatedL = lowerBoundData.l + (upperBoundData.l - lowerBoundData.l) * fraction;
    final double interpolatedM = lowerBoundData.m + (upperBoundData.m - lowerBoundData.m) * fraction;
    final double interpolatedS = lowerBoundData.s + (upperBoundData.s - lowerBoundData.s) * fraction;
    final double interpolatedT = lowerBoundData.t + (upperBoundData.t - lowerBoundData.t) * fraction;

    return LmsResult(l: interpolatedL, m: interpolatedM, s: interpolatedS, t: interpolatedT);
  }

  return null;
}

