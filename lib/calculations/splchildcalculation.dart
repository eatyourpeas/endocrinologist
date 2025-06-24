import '../classes/bulgarianspl.dart';
import '../enums/enums.dart';
import '../referencedata/bulgarianspldata.dart';

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
  }) {
    final referenceData = childSPLData;
    // --- 1. Interpolate P5, P50, and P95 values for the decimal age ---

    // Find the bounding integer ages
    final int lowerAge = decimalAgeYears.floor();
    final int upperAge = decimalAgeYears.ceil();
    final double fraction = decimalAgeYears - lowerAge;

    // Get reference values for the lower age
    final p5Lower = _getStretchedPenileLengthForAgeAndCentile(referenceData, lowerAge, Centile.P5);
    final p50Lower = _getStretchedPenileLengthForAgeAndCentile(referenceData, lowerAge, Centile.P50);
    final p95Lower = _getStretchedPenileLengthForAgeAndCentile(referenceData, lowerAge, Centile.P95);

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
      final p5Upper = _getStretchedPenileLengthForAgeAndCentile(referenceData, upperAge, Centile.P5);
      final p50Upper = _getStretchedPenileLengthForAgeAndCentile(referenceData, upperAge, Centile.P50);
      final p95Upper = _getStretchedPenileLengthForAgeAndCentile(referenceData, upperAge, Centile.P95);

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
      List<ChildSPLDataPoint> referenceData, int age, Centile centile) {
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
}