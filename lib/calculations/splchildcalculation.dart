import 'dart:math';

import 'package:endocrinologist/classes/bulgarianspl.dart'; // Defines ChildBulgarianSPLDataPoint
import 'package:endocrinologist/enums/enums.dart';
import 'package:endocrinologist/referencedata/bulgarianspldata.dart'; // Defines childBulgarianSPLData
import 'package:endocrinologist/referencedata/indian_data.dart'; // Defines IndianStretchedPenileLengthList and IndianStretchedPenileLength
import 'package:logging/logging.dart';

class PenileStatsCalculator {
  static final _logger = Logger('PenileStatsCalculator'); // For logging

  static double calculateStretchedPenileLengthSDS({
    required double measuredStretchedPenileLength,
    required double decimalAgeYears,
    required Ethnicity ethnicity,
  }) {
    // --- Path for Indian Ethnicity (uses LMS method) ---
    if (ethnicity == Ethnicity.indian) {
      return _sdsForIndianMeasurement(
          decimalAgeYears, measuredStretchedPenileLength);
    }

    // --- Path for Bulgarian Ethnicity (uses Centile Interpolation method) ---
    else if (ethnicity == Ethnicity.bulgarian) {
      List<ChildBulgarianSPLDataPoint> referenceData = childBulgarianSPLData;

      // --- 1. Interpolate P5, P50, and P95 values for the decimal age ---
      final int lowerAge = decimalAgeYears.floor();
      final int upperAge = decimalAgeYears.ceil();
      final double fraction = decimalAgeYears - lowerAge;

      final p5Lower = _getStretchedPenileLengthForAgeAndCentile(
          referenceData, lowerAge, Centile.p5);
      final p50Lower = _getStretchedPenileLengthForAgeAndCentile(
          referenceData, lowerAge, Centile.p50);
      final p95Lower = _getStretchedPenileLengthForAgeAndCentile(
          referenceData, lowerAge, Centile.p95);

      if (p5Lower == null || p50Lower == null || p95Lower == null) {
        _logger.warning(
            "Insufficient data for Bulgarian SPL lower age boundary ($lowerAge years).");
        if (upperAge == lowerAge) return double.nan;
        // If not strictly at an integer age and lower is missing, we might still proceed if upper is present
        // but the current logic for `else` block below will handle missing upper,
        // and if both are missing, it will eventually fail.
        // For simplicity, if critical lower boundary data is missing, it's hard to proceed reliably.
        // However, if upperAge != lowerAge, the 'else' block below will check p5Upper etc.
      }

      double interpolatedP5, interpolatedP50, interpolatedP95;

      if (lowerAge == upperAge) {
        // Age is an exact integer
        if (p5Lower == null || p50Lower == null || p95Lower == null) {
          _logger.warning(
              "Data missing for exact integer age $lowerAge for Bulgarian SPL.");
          return double.nan; // Can't proceed if exact age data is missing
        }
        interpolatedP5 = p5Lower;
        interpolatedP50 = p50Lower;
        interpolatedP95 = p95Lower;
      } else {
        // Linear interpolation for non-integer age
        final p5Upper = _getStretchedPenileLengthForAgeAndCentile(
            referenceData, upperAge, Centile.p5);
        final p50Upper = _getStretchedPenileLengthForAgeAndCentile(
            referenceData, upperAge, Centile.p50);
        final p95Upper = _getStretchedPenileLengthForAgeAndCentile(
            referenceData, upperAge, Centile.p95);

        if (p5Upper == null || p50Upper == null || p95Upper == null) {
          _logger.warning(
              "Insufficient data for Bulgarian SPL upper age boundary ($upperAge years). Cannot interpolate.");
          return double.nan;
        }
        // Re-check lower bounds if they were potentially null but not caught by exact age check
        if (p5Lower == null || p50Lower == null || p95Lower == null) {
          _logger.warning(
              "Insufficient data for Bulgarian SPL lower age boundary ($lowerAge years) when attempting interpolation. Cannot interpolate.");
          return double.nan;
        }

        interpolatedP5 = p5Lower + (p5Upper - p5Lower) * fraction;
        interpolatedP50 = p50Lower + (p50Upper - p50Lower) * fraction;
        interpolatedP95 = p95Lower + (p95Upper - p95Lower) * fraction;
      }

      if (interpolatedP5.isNaN ||
          interpolatedP50.isNaN ||
          interpolatedP95.isNaN) {
        _logger.severe(
            "Could not determine interpolated centiles for Bulgarian SPL at age $decimalAgeYears.");
        return double.nan;
      }

      final double meanStretchedPenileLength = interpolatedP50;

      if (interpolatedP95 <= interpolatedP5) {
        _logger.warning(
            "P95 (${interpolatedP95.toStringAsFixed(2)}) is not greater than P5 (${interpolatedP5.toStringAsFixed(2)}) for Bulgarian SPL at age $decimalAgeYears. Cannot reliably calculate SD.");
        return double.nan;
      }
      final double standardDeviation =
          (interpolatedP95 - interpolatedP5) / (2 * 1.64485);

      if (standardDeviation <= 0) {
        _logger.warning(
            "Calculated Standard Deviation is zero or negative for Bulgarian SPL at age $decimalAgeYears.");
        return double.nan;
      }

      final double sds =
          (measuredStretchedPenileLength - meanStretchedPenileLength) /
              standardDeviation;
      return sds;
    }

    // --- Fallback for unsupported ethnicities ---
    else {
      _logger.warning("Unsupported ethnicity for SDS calculation: $ethnicity");
      return double.nan;
    }
  }

  /// Helper function to get penile length for a specific integer age and centile from Bulgarian data.
  static double? _getStretchedPenileLengthForAgeAndCentile(
    List<ChildBulgarianSPLDataPoint> referenceData, // Now specifically typed
    int age,
    Centile centile,
  ) {
    try {
      // Ensure your ChildBulgarianSPLDataPoint has 'age' and 'centile' fields accessible
      // and a 'penileLengthCm' field (or similar).
      final dataPoint = referenceData.firstWhere(
        (dp) => dp.age == age && dp.centile == centile,
      );
      return dataPoint.penileLengthCm;
    } catch (e) {
      _logger.finer(
          "Bulgarian SPL data point not found for age $age and centile $centile.");
      return null;
    }
  }

  static double _sdsForIndianMeasurement(
      double decimalAgeYears, double measuredStretchedPenileLength) {
    LmsResult? lmsResult = getLmsForAge(
        decimalAge: decimalAgeYears,
        referenceData: indianStretchedPenileLengthList);

    if (lmsResult == null) {
      _logger.warning(
          "Could not retrieve LMS parameters for Indian SPL at age $decimalAgeYears.");
      return double.nan;
    }

    double l = lmsResult.l;
    double m = lmsResult.m;
    double s = lmsResult.s;

    if (m <= 0) {
      _logger.warning(
          "M value ($m) must be positive for Indian SPL at age $decimalAgeYears.");
      return double.nan;
    }
    if (s <= 0) {
      _logger.warning(
          "S value ($s) must be positive for Indian SPL at age $decimalAgeYears.");
      return double.nan;
    }

    double sds;
    if (l != 0) {
      sds = (pow(measuredStretchedPenileLength / m, l) - 1) / (l * s);
    } else {
      if (measuredStretchedPenileLength <= 0) {
        _logger.warning(
            "Measurement ($measuredStretchedPenileLength) must be positive when L=0 for Indian SPL at age $decimalAgeYears.");
        return double.nan;
      }
      sds = log(measuredStretchedPenileLength / m) / s;
    }
    return sds;
  }
}

// LmsResult class remains the same
class LmsResult {
  final double l;
  final double m;
  final double s;
  final double t; // t is present in Indian data, keep it in LmsResult for now

  LmsResult(
      {required this.l, required this.m, required this.s, required this.t});

  @override
  String toString() {
    return 'LMSResult(L: ${l.toStringAsFixed(3)}, M: ${m.toStringAsFixed(3)}, S: ${s.toStringAsFixed(3)}, T: ${t.toStringAsFixed(3)})';
  }
}

// getLmsForAge function remains largely the same, but good to add logging
final _getLmsLogger =
    Logger('getLmsForAge'); // Logger for this top-level function

LmsResult? getLmsForAge({
  required double decimalAge,
  required List<IndianStretchedPenileLength> referenceData,
}) {
  if (referenceData.isEmpty) {
    _getLmsLogger.severe("Indian reference data is empty.");
    return null;
  }

  var sortedData = List<IndianStretchedPenileLength>.from(referenceData);
  sortedData.sort((a, b) => a.ageYears.compareTo(b.ageYears));

  IndianStretchedPenileLength? lowerBoundData;
  IndianStretchedPenileLength? upperBoundData;

  for (int i = 0; i < sortedData.length; i++) {
    if (sortedData[i].ageYears == decimalAge) {
      final exactMatch = sortedData[i];
      return LmsResult(
          l: exactMatch.l, m: exactMatch.m, s: exactMatch.s, t: exactMatch.t);
    }
    if (sortedData[i].ageYears < decimalAge) {
      lowerBoundData = sortedData[i];
    }
    if (sortedData[i].ageYears > decimalAge) {
      upperBoundData = sortedData[i];
      break;
    }
  }

  if (lowerBoundData == null && upperBoundData != null) {
    _getLmsLogger.finer(
        // Finer, as it's an expected edge case handled by using bounds
        "Age $decimalAge is below the minimum age (${upperBoundData.ageYears}) in Indian reference data. Using values from the lowest age.");
    return LmsResult(
        l: upperBoundData.l,
        m: upperBoundData.m,
        s: upperBoundData.s,
        t: upperBoundData.t);
  }

  if (upperBoundData == null && lowerBoundData != null) {
    _getLmsLogger.finer(
        "Age $decimalAge is above the maximum age (${lowerBoundData.ageYears}) in Indian reference data. Using values from the highest age.");
    return LmsResult(
        l: lowerBoundData.l,
        m: lowerBoundData.m,
        s: lowerBoundData.s,
        t: lowerBoundData.t);
  }

  if (lowerBoundData == null && upperBoundData == null) {
    // This case occurs if the loop finishes without finding any bounds,
    // which implies the data might be empty or decimalAge is outside any reasonable range
    // or there's only one data point not matching decimalAge.
    // Already handled by initial empty check, but good to be robust.
    _getLmsLogger.warning(
        "Could not find suitable bounds for age $decimalAge in Indian reference data. Data count: ${sortedData.length}");
    return null;
  }

  if (lowerBoundData != null && upperBoundData != null) {
    // ... (rest of the interpolation logic for LMS remains the same) ...
    // (Ensure you handle the case where lowerBoundData.ageYears == upperBoundData.ageYears before division)
    if (lowerBoundData.ageYears == upperBoundData.ageYears) {
      // Should have been caught by exact match earlier, but as a safeguard
      return LmsResult(
          l: lowerBoundData.l,
          m: lowerBoundData.m,
          s: lowerBoundData.s,
          t: lowerBoundData.t);
    }
    final double lowerAge = lowerBoundData.ageYears.toDouble();
    final double upperAge = upperBoundData.ageYears.toDouble();

    // Check for division by zero if upperAge can be equal to lowerAge after all checks
    if (upperAge == lowerAge) {
      _getLmsLogger.severe(
          "Upper and lower age bounds are identical ($lowerAge) during LMS interpolation for age $decimalAge, preventing division.");
      return LmsResult(
          l: lowerBoundData.l,
          m: lowerBoundData.m,
          s: lowerBoundData.s,
          t: lowerBoundData.t); // return one of them
    }

    final double fraction = (decimalAge - lowerAge) / (upperAge - lowerAge);

    // It's possible due to floating point inaccuracies or edge cases that fraction might be slightly outside [0,1]
    // when decimalAge is very close to lowerAge or upperAge.
    // Clamping fraction to [0,1] can make it more robust if such small deviations are acceptable.
    // Or, as you have, return the boundary data.
    if (fraction < 0) {
      // decimalAge is slightly less than lowerBoundData.ageYears
      _getLmsLogger.finer(
          "Fraction $fraction < 0 for age $decimalAge. Using lower bound LMS values.");
      return LmsResult(
          l: lowerBoundData.l,
          m: lowerBoundData.m,
          s: lowerBoundData.s,
          t: lowerBoundData.t);
    }
    if (fraction > 1) {
      // decimalAge is slightly more than upperBoundData.ageYears
      _getLmsLogger.finer(
          "Fraction $fraction > 1 for age $decimalAge. Using upper bound LMS values.");
      return LmsResult(
          l: upperBoundData.l,
          m: upperBoundData.m,
          s: upperBoundData.s,
          t: upperBoundData.t);
    }

    final double interpolatedL =
        lowerBoundData.l + (upperBoundData.l - lowerBoundData.l) * fraction;
    final double interpolatedM =
        lowerBoundData.m + (upperBoundData.m - lowerBoundData.m) * fraction;
    final double interpolatedS =
        lowerBoundData.s + (upperBoundData.s - lowerBoundData.s) * fraction;
    final double interpolatedT = // t is specific to Indian data
        lowerBoundData.t + (upperBoundData.t - lowerBoundData.t) * fraction;

    return LmsResult(
        l: interpolatedL, m: interpolatedM, s: interpolatedS, t: interpolatedT);
  }

  _getLmsLogger.warning(
      "LMS data interpolation failed for age $decimalAge. No suitable data found or bounds issue.");
  return null;
}
