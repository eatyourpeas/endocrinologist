import 'dart:math' as Math;
import "package:endocrinologist/enums/enums.dart";

double calculateDeltaSodium({
  required double infusateSodiumConcentration, // Infusate sodium concentration in mmol/L
  required double plasmaSodium, // Plasma sodium concentration in mmol/L
  required double totalBodyWater, // Total body water in litres
}) {
  // Ensure totalBodyWater + 1 is not zero to prevent division by zero errors.
  // Although with body water typically being positive, totalBodyWater + 1 shouldn't be zero.
  // However, it's good practice for robustness if inputs could be unexpected.
  if ((totalBodyWater + 1) == 0) {
    throw ArgumentError("totalBodyWater + 1 cannot be zero, as it would lead to division by zero.");
  }

  // Formula: (infusateSodiumConcentration - plasmaSodium) / (totalBodyWater + 1)
  double deltaSodium = (infusateSodiumConcentration - plasmaSodium) / (totalBodyWater + 1);

  return deltaSodium;
}

double totalBodyWaterUnderElevens({
      required double age,
      required double height,
      required double weight,
      required Sex sex
}){
  // Wells JC, Fewtrell MS, Davies PS, Williams JE, Coward WA, Cole TJ. Prediction of total body water in infants and children. Arch Dis Child. 2005 Sep;90(9):965-71. doi: 10.1136/adc.2004.067538. PMID: 16113134; PMCID: PMC1720559.
  double constant = -2.952;
  double lnWt = 0.551;
  double lnHt = 0.796;
  double femaleConstant = -0.047;
  double ageConstant = 0.008;

  double lnTotalBodyWeight = constant + lnWt * Math.log(weight) + lnHt * Math.log(height) + ageConstant * age;
  if (sex == Sex.female) {
    lnTotalBodyWeight += femaleConstant;
  }

  return Math.exp(lnTotalBodyWeight);
}