import 'package:endocrinologist/classes/twiii_height_prediction.dart';
import 'package:endocrinologist/enums/enums.dart';
import 'package:endocrinologist/referencedata/twiii_data.dart';
// Predicted adult height = a present height+b chronological age+c RUS bone age+d,a constant.

double predictAdultHeight({
  required Sex sex,
  required double height,
  required double chronologicalAge,
  required double rusBoneAge,
  bool menarchealStatus = false,
}) {
  final List<TWIIIAdultHeightPrediction> relevantData;
  if (sex == Sex.male) {
    // Assuming male data is available in a similar list
    relevantData = twiiiMaleAdultHeightPredictions; // Placeholder for male data list
  } else if (sex == Sex.female) {
    relevantData = twiiiFemaleAdultHeightPredictions;
    if (menarchealStatus) {
      // Filter for postmenarcheal data
          relevantData.where((item) => item.menarchealStatus == 'postmenarcheal')
          .toList();
    } else {
      // Filter for premenarcheal data
      relevantData.where((item) => item.menarchealStatus == 'premenarcheal')
          .toList();
    }
  } else {
    throw ArgumentError('Invalid sex. Must be "male" or "female".');
  }

  // NEW: Check for an exact match before attempting range checks or interpolation
  for (final dataEntry in relevantData) {
    final double entryAgeLowerBound = _parseAgeToDouble(dataEntry.age);
    print("Checking for exact match for age $chronologicalAge against $entryAgeLowerBound.");
    // Use a small epsilon for floating point comparison if necessary,
    // or ensure your decimal ages are precise enough.
    // For simplicity here, we'll assume direct comparison works if _parseAgeToDouble is consistent.
    if (chronologicalAge == entryAgeLowerBound) {
      print("Exact match found for chronological age $chronologicalAge. Using direct data.");
      return height * dataEntry.heightCoefficient +
          chronologicalAge * dataEntry.chronologicalAgeCoefficient +
          rusBoneAge * dataEntry.boneAgeCoefficient +
          dataEntry.constant;
    }
  }

  // Handle cases where the chronological age is outside the range of the data
  // Get the lower bound of the first entry
  final double firstEntryLowerBound = _parseAgeToDouble(relevantData.first.age);
  if (chronologicalAge < firstEntryLowerBound) {
    // Chronological age is before the first data entry's range.
    // Use the first entry's coefficients without interpolation.
    // This assumes it's appropriate to extrapolate using the earliest data.
    // You might want to throw an error or handle this differently based on clinical practice.
    print("Warning: Chronological age ($chronologicalAge) is below the first data entry range starting at $firstEntryLowerBound. Using first entry.");
    final prediction = relevantData.first;

    return height * prediction.heightCoefficient +
        chronologicalAge * prediction.chronologicalAgeCoefficient +
        rusBoneAge * prediction.boneAgeCoefficient +
        prediction.constant;
  }

  // Get the lower bound of the last entry.
  // The interpretation of the "last entry" for upper bound check needs care.
  // If the last entry's age is "16,+", _parseAgeToDouble("16,+") will give 16.0.
  // This means any age >= 16.0 should use this last entry.
  final double lastEntryLowerBound = _parseAgeToDouble(relevantData.last.age);
  if (chronologicalAge >= lastEntryLowerBound) { // Use >= for the last entry
    // Chronological age is within or beyond the last data entry's start range.
    // Use the last entry's coefficients without interpolation.
    print("Chronological age ($chronologicalAge) is within or beyond the last data entry range starting at $lastEntryLowerBound. Using last entry.");
    final prediction = relevantData.last;
    return height * prediction.heightCoefficient +
        chronologicalAge * prediction.chronologicalAgeCoefficient +
        rusBoneAge * prediction.boneAgeCoefficient +
        prediction.constant;
  }

  // Find the two closest data points for interpolation
  // The chronologicalAge is guaranteed to be >= firstEntryLowerBound
  // and < lastEntryLowerBound at this point.

  TWIIIAdultHeightPrediction lower = relevantData.first;
  TWIIIAdultHeightPrediction upper = relevantData.last; // Should be updated in loop

  for (int i = 0; i < relevantData.length - 1; i++) {
    // Current entry's lower bound
    final double currentEntryLowerBound = _parseAgeToDouble(relevantData[i].age);
    // Next entry's lower bound
    final double nextEntryLowerBound = _parseAgeToDouble(relevantData[i + 1].age);

    if (chronologicalAge >= currentEntryLowerBound && chronologicalAge < nextEntryLowerBound) {
      lower = relevantData[i];
      upper = relevantData[i + 1];
      break;
    }
  }

  // Linear interpolation logic:
  // The 't' value should be calculated based on the lower bounds of the 'lower' and 'upper' entries.
  double interpolate(double lowerValue, double upperValue) {
    final double lowerBoundAgeForLowerEntry = _parseAgeToDouble(lower.age);
    final double lowerBoundAgeForUpperEntry = _parseAgeToDouble(upper.age);

    // Ensure denominator is not zero (shouldn't happen if data is distinct and sorted)
    if (lowerBoundAgeForUpperEntry == lowerBoundAgeForLowerEntry) {
      // This case implies data points are at the same age or an issue with parsing.
      // Return the lower value or average, or handle as an error.
      print("Warning: Interpolation age points are identical ($lowerBoundAgeForLowerEntry). Using lower value.");
      return lowerValue;
    }

    final t = (chronologicalAge - lowerBoundAgeForLowerEntry) / (lowerBoundAgeForUpperEntry - lowerBoundAgeForLowerEntry);
    return lowerValue + t * (upperValue - lowerValue);
  }

  final interpolatedHeightCoefficient =
  interpolate(lower.heightCoefficient, upper.heightCoefficient);
  final interpolatedChronologicalAgeCoefficient =
  interpolate(lower.chronologicalAgeCoefficient, upper.chronologicalAgeCoefficient);
  final interpolatedBoneAgeCoefficient =
  interpolate(lower.boneAgeCoefficient, upper.boneAgeCoefficient);
  final interpolatedConstant =
  interpolate(lower.constant.toDouble(), upper.constant.toDouble());

  // Predicted adult height equation
  return height * interpolatedHeightCoefficient +
      chronologicalAge * interpolatedChronologicalAgeCoefficient +
      rusBoneAge * interpolatedBoneAgeCoefficient +
      interpolatedConstant;
}

/// Parses the age string from TWIIIAdultHeightPrediction data to a decimal year value.
/// It specifically extracts the lower bound of the age range for comma-separated entries,
/// or parses the string directly if it's a single decimal age.
///
/// - For comma-separated format (e.g., "4, 5, 6, 7+"), it takes the FIRST number
///   as the lower bound of the age range this data entry applies to.
/// - For single string entries (e.g., "8.0", "12.5", "16+"), it parses them directly
///   as decimal years.
/// - Handles "+" by removing it.
double _parseAgeToDouble(String ageString) {
  String cleanedAgeString = ageString.trim().replaceAll('+', '');

  if (cleanedAgeString.contains(',')) {
    // Comma-separated list, e.g., "4, 5, 6, 7" or "4, 5"
    // We take the FIRST part as the lower bound of this entry's applicability.
    List<String> parts = cleanedAgeString.split(',');
    if (parts.isNotEmpty) {
      try {
        return double.parse(parts.first.trim());
      } catch (e) {
        throw FormatException(
            "Invalid number format in comma-separated age: ${parts.first} from '$ageString'");
      }
    } else {
      throw FormatException(
          "Empty string after splitting comma-separated age: '$ageString'");
    }
  } else {
    // Assumed to be a single decimal year string, e.g., "8.0", "12.5"
    try {
      return double.parse(cleanedAgeString);
    } catch (e) {
      throw FormatException(
          "Invalid single number format for age: '$cleanedAgeString' from '$ageString'");
    }
  }
}




