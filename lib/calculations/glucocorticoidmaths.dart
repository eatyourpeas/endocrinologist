import 'package:endocrinologist/classes/glucocorticoid.dart'; // Assuming this is still needed for other functions

double maintenanceHydrocortisoneDoseMin(double bodySurfaceArea) {
  // maintenance hydrocortisone in 8-10 mg/m2/d
  return 8 * bodySurfaceArea;
}

double maintenanceHydrocortisoneDoseMax(double bodySurfaceArea) {
  // maintenance hydrocortisone in 8-10 mg/m2/d
  return 10 * bodySurfaceArea;
}

double oralStressHydrocortisoneDoseMax(double bodySurfaceArea) {
  // oral stress hydrocortisone dose is 30 mg/m2/d
  return 30 * bodySurfaceArea;
}

double hydrocortisoneEquivalentDose(double dose, Glucocorticoid steroid) {
  return dose * steroid.potency;
}

List<double> dividedDoses(double originalDose, int numberOfDoses) {
  if (numberOfDoses <= 0) {
    throw ArgumentError("Number of doses must be positive.");
  }
  if (originalDose < 0) {
    throw ArgumentError("Original dose cannot be negative.");
  }

  if (originalDose == 0) {
    return List.filled(numberOfDoses, 0.0);
  }

  const double tolerance = 0.00001; // For double comparisons

  // Determine the dose increment first.
  // This decision is based on whether the original dose suggests 1.25 is feasible.
  // A common approach might be to check if originalDose itself is 'close' or naturally a multiple.
  // However, the provided code structure effectively recalculates targetTotalDose *after* choosing increment.

  // Let's refine the initial choice of increment and then the target total dose:
  double tentativeInitialTarget = originalDose.ceilToDouble(); // A starting point for consideration
  double doseIncrement;

  // If the *originalDose* itself (or its ceiling) is a multiple of 1.25, prefer 1.25 increments.
  // A practical way to check if 1.25 is a "natural fit" for the originalDose.
  // We check if originalDose * 4 is an integer. If so, originalDose is a multiple of 0.25.
  // And if originalDose * 100 is divisible by 125.
  bool canUse125Increment = ((originalDose * 100).round() % 125 == 0) ||
      (((originalDose / 1.25).ceil() * 1.25) - originalDose < 1.0); // Or if rounding to 1.25 is "closer" than rounding to 1.0

  // More direct: If the original dose, when rounded up to the nearest 1.25,
  // is "sensible" (e.g. not drastically increasing the dose just to hit a 1.25 multiple
  // if a 1.0 multiple is closer).
  // The provided code from the file makes a decision for `doseIncrement` and then
  // calculates `finalTargetTotalDose`. Let's stick to that structure for clarity of the fix.

  // Determine the dose increment (as per the file's logic structure)
  // This was the logic block from the file you had:
  double tempTargetForIncrementCheck = originalDose.ceilToDouble();
  if ((tempTargetForIncrementCheck * 100).round() % 125 == 0) {
    doseIncrement = 1.25;
  } else {
    doseIncrement = 1.0;
  }

  // Now, calculate the *actual* targetTotalDose based on the chosen increment.
  // This is the crucial part that implements your request:
  double finalTargetTotalDose;
  if (doseIncrement == 1.25) {
    // Round up the originalDose to the NEAREST multiple of 1.25
    finalTargetTotalDose = (originalDose / 1.25).ceil() * 1.25;
  } else { // doseIncrement == 1.0
    // Round up the originalDose to the NEAREST whole number (multiple of 1.0)
    finalTargetTotalDose = originalDose.ceilToDouble();
  }

  // Recalculate doses based on this finalTargetTotalDose and chosen doseIncrement
  List<double> doses = List.filled(numberOfDoses, 0.0);
  double baseIndividualDoseNotRounded = finalTargetTotalDose / numberOfDoses;
  double baseDosePerPortion = (baseIndividualDoseNotRounded / doseIncrement).floor() * doseIncrement;

  for (int i = 0; i < numberOfDoses; i++) {
    doses[i] = baseDosePerPortion;
  }

  double sumOfBaseDoses = baseDosePerPortion * numberOfDoses;
  // Ensure remainingToDistribute is calculated precisely
  double remainingToDistribute = (finalTargetTotalDose * 100 - sumOfBaseDoses * 100).round() / 100.0;

  int k = 0;
  while (remainingToDistribute >= (doseIncrement - tolerance)) {
    doses[k % numberOfDoses] += doseIncrement;
    doses[k % numberOfDoses] = (doses[k % numberOfDoses] * 100).round() / 100.0; // Round for precision
    remainingToDistribute -= doseIncrement;
    remainingToDistribute = (remainingToDistribute * 100).round() / 100.0; // Round for precision
    k++;
  }
  return doses;
}
