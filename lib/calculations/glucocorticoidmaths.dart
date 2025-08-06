import 'package:endocrinologist/classes/glucocorticoid.dart';

double maintenanceHydrocortisoneDoseMin(double bodySurfaceArea){
  // maintenance hydrocortisone in 8-10 mg/m2/d
  return 8*bodySurfaceArea;
}

double maintenanceHydrocortisoneDoseMax(double bodySurfaceArea){
  // maintenance hydrocortisone in 8-10 mg/m2/d
  return 10*bodySurfaceArea;
}

double oralStressHydrocortisoneDoseMax(double bodySurfaceArea){
  // oral stress hydrocortisone dose is 30 mg/m2/d
  return 30*bodySurfaceArea;
}

double hydrocortisoneEquivalentDose(double dose, Glucocorticoid steroid){
  return dose * steroid.potency;
}

List<double> dividedDoses(double originalDose, int numberOfDoses) {
  if (numberOfDoses <= 0) {
    throw ArgumentError("Number of doses must be positive.");
  }
  if (originalDose < 0) {
    throw ArgumentError("Original dose cannot be negative.");
  }

  if (originalDose == 0) { // Handle zero dose explicitly for clarity
    return List.filled(numberOfDoses, 0.0);
  }

  // Calculate the target total dose.
  double targetTotalDose = (originalDose / 1.0).ceil() * 1.0;

  List<double> doses = [];
  double remainingOverallDoseToDistribute = targetTotalDose;
  double doseIncrement = 1.0;

  double baseIndividualDoseNotRounded = targetTotalDose / numberOfDoses;

  for (int i = 0; i < numberOfDoses; i++) {
    // For the current dose, round it UP to the nearest multiple of doseIncrement
    double currentPortion = (baseIndividualDoseNotRounded / doseIncrement).ceil() * doseIncrement;
    doses.add(currentPortion); // Initialize
  }

  double baseDosePerPortion = ( (targetTotalDose / numberOfDoses) / doseIncrement ).floor() * doseIncrement;
  for(int i=0; i < numberOfDoses; i++){
    doses[i] = baseDosePerPortion;
  }

  double sumOfBaseDoses = baseDosePerPortion * numberOfDoses;
  double remainingToDistributeInIncrements = targetTotalDose - sumOfBaseDoses;

  const double tolerance = 0.00001; // For double comparisons
  int k = 0;
  while(remainingToDistributeInIncrements >= (doseIncrement - tolerance)){
    doses[k % numberOfDoses] += doseIncrement;
    remainingToDistributeInIncrements -= doseIncrement;
    k++;
  }

  return doses;
}
