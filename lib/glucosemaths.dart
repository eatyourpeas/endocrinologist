import "package:endocrinologist/milk.dart";
import "package:endocrinologist/referencedata/milks.dart";

  // These functions do the calculations required to return glucose related results.


  double calculateGlucoseInfusionRate(double glucoseConcentration, double infusionRate, double weight){
  //   Glucose infusion rate is returned at mg/kg/min
  //   the calculation is: return rate * percentage / weight / 6
  //   the rate must be in ml/hr the weight must be in kg
    return infusionRate * glucoseConcentration / weight / 6;
  }

  double hourlyMilkRateForDailyVolume(double dailyVolume, double weight){
    return (dailyVolume * weight) / 24;
  }

  double returnGlucoseConcentrationForMilk({required String milk}){
    try {
      return milks.firstWhere((referenceMilk)=> milk == referenceMilk.name).carbsPer100ml;
    } catch (e){
      throw Exception("Milk not found in list: $milk");
    }
  }