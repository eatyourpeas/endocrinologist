import 'package:endocrinologist/classes/glucocorticoid.dart';

double maintenanceHydrocortisoneDoseMin(double bodySurfaceArea){
  // maintenance hydrocortisone in 8-10 mg/m2/d
  return 8/bodySurfaceArea;
}

double maintenanceHydrocortisoneDoseMax(double bodySurfaceArea){
  // maintenance hydrocortisone in 8-10 mg/m2/d
  return 10/bodySurfaceArea;
}

double oralStressHydrocortisoneDoseMax(double bodySurfaceArea){
  // oral stress hydrocortisone dose is 30 mg/m2/d
  return 30/bodySurfaceArea;
}

double hydrocortisoneEquivalentDose(double dose, Glucocorticoid steroid){
  return dose * steroid.potency;
}

List<double> dividedDoses(double dose, int numberOfDoses) {
  // Rounds dose to be divisible by 2.5mg then returns 3 divided doses (not necessarily equal)

  // Round the dose to the nearest value divisible by 2.5
  double roundedDose = (dose / 2.5).round() * 2.5;

  // Initialize an empty list to store each dose
  List<double> doses = [];

  // Total dose should be divided into 'numberOfDoses' parts
  double totalDose = roundedDose;

  // Calculate the base dose that is divisible by 2.5
  double baseDose = (totalDose / numberOfDoses / 2.5).floor() * 2.5;

  // Calculate how much remains after evenly distributing the base doses
  double remainingDose = totalDose - (baseDose * numberOfDoses);

  // Distribute doses such that each is divisible by 2.5
  for (int i = 0; i < numberOfDoses; i++) {
    if (remainingDose >= 2.5) {
      doses.add(baseDose + 2.5); // Add extra 2.5 where possible
      remainingDose -= 2.5;
    } else {
      doses.add(baseDose);
    }
  }

  return doses;
}
