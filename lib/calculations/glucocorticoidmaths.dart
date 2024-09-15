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
