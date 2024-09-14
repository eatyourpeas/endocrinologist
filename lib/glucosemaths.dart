import "package:endocrinologist/milk.dart";
import "package:endocrinologist/referencedata/milks.dart";

class GlucoseMaths {

  double calculateGlucoseInfusionRate({required glucoseConcentration, required infusionRate, required weight}){
  //   Glucose infusion rate is returned at mg/kg/min
  //   the calculation is: return rate * percentage / weight / 6
  //   the rate must be in ml/hr the weight must be in kg
    return infusionRate * glucoseConcentration / weight / 6;
  }

  double returnGlucoseConcentrationForMilk({required String milk}){
    try {
      return milks.firstWhere((referenceMilk)=> milk == referenceMilk.name).carbsPer100ml;
    } catch (e){
      throw Exception("Milk not found in list: $milk");
    }
  }
}