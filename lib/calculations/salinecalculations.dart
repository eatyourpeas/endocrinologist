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

double totalBodyWater({
      required double age,
      required double height,
      required double weight,
      required Sex sex
}){
  // This function calculates total body water in infants, children and adolescents, based on two references:
  // Wells JC, Fewtrell MS, Davies PS, Williams JE, Coward WA, Cole TJ. Prediction of total body water in infants and children. Arch Dis Child. 2005 Sep;90(9):965-71. doi: 10.1136/adc.2004.067538. PMID: 16113134; PMCID: PMC1720559.
  // and
  // Chumlea WC, Schubert CM, Reo NV, Sun SS, Siervogel RM. Total body water volume for white children and adolescents and anthropometric prediction equations: the Fels Longitudinal Study. Kidney Int. 2005 Nov;68(5):2317-22. doi: 10.1111/j.1523-1755.2005.00692.x. PMID: 16221235.
  // Both use the deuterium dilution method. The Wells et al paper is acurate to 12y.
  // This function therefore uses the Wells et al. method for the under 12s, Chumlea et al. method for > 12y
  // Both methods accept the same parameters and return total body water in litres.

  if (age <= 12) {
    // Wells JC, Fewtrell MS, Davies PS, Williams JE, Coward WA, Cole TJ. Prediction of total body water in infants and children. Arch Dis Child. 2005 Sep;90(9):965-71. doi: 10.1136/adc.2004.067538. PMID: 16113134; PMCID: PMC1720559.
    double constant = -2.952;
    double lnWt = 0.551;
    double lnHt = 0.796;
    double femaleConstant = -0.047;
    double ageConstant = 0.008;

    double lnTotalBodyWater = constant + lnWt * Math.log(weight) +
        lnHt * Math.log(height) + ageConstant * age;
    if (sex == Sex.female) {
      lnTotalBodyWater += femaleConstant;
    }

    return Math.exp(lnTotalBodyWater);
  } else {
    // Chumlea WC, Schubert CM, Reo NV, Sun SS, Siervogel RM. Total body water volume for white children and adolescents and anthropometric prediction equations: the Fels Longitudinal Study. Kidney Int. 2005 Nov;68(5):2317-22. doi: 10.1111/j.1523-1755.2005.00692.x. PMID: 16221235.
    // TBW = −25.87 + 0.23 (stature) + 0.37(weight) for boys
    // TBW = −14.77 + 0.18 (stature) + 0.25(weight) for girls.
    double constant = sex == Sex.male ? -25.87 : -14.77;
    return sex == Sex.male ? constant + (0.23 * height) + (0.37 * weight) : constant + (0.18 * height) + (0.25 * weight);;
  }
}