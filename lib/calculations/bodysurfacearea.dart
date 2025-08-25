import 'dart:math';
import '../enums/enums.dart';

double calculateBSA(
    double heightCm, double weightKg, BsaCalculationMethod method) {
  double bsa = 0.0;

  switch (method) {
    case BsaCalculationMethod.mosteller:
      /*
      BSA = = 0.016667 × W0.5 × H0.5
      Mosteller RD. "Simplified calculation of body-surface area". N Engl J Med 1987; 317:1098. PMID 3657876.
      */
      bsa = sqrt((heightCm * weightKg) / 3600);
      break;

    case BsaCalculationMethod.boyd:
      // Boyd requires weight to be converted to grams
      // Boyd, Edith (1935). The Growth of the Surface Area of the Human Body. University of Minnesota. The Institute of Child Welfare, Monograph Series, No. x. London: Oxford University Press
      if (weightKg <= 0 || heightCm <= 0) {
        bsa = 0.0; // BSA cannot be non-positive, log is undefined for <=0
        break;
      }

      double weightGrams = weightKg * 1000.0;
      double log10WeightGrams = log(weightGrams) / log(10.0); // log10

      double exponent = 0.7285 - (0.0188 * log10WeightGrams);
      bsa = 0.0003207 * pow(heightCm, 0.3) * pow(weightGrams, exponent);
      break;

    case BsaCalculationMethod.dubois:
      /*
      BSA = 0.007184 × W0.425 × H0.725
      Du Bois D, Du Bois EF (Jun 1916). "A formula to estimate the approximate surface area if height and weight be known". Archives of Internal Medicine 17 (6): 863-71. PMID 2520314. Retrieved 2012-09-09.
       */
      bsa = 0.007184 * pow(heightCm, 0.725) * pow(weightKg, 0.425);
      break;

    case BsaCalculationMethod.gehangeorge:
      /*
      BSA = 0.0235 × W0.51456 × H0.42246
      Gehan EA, George SL, Cancer Chemother Rep 1970, 54:225-235
       */
      bsa = 0.0235 * pow(heightCm, 0.42246) * pow(weightKg, 0.51456);
      break;
  }

  return bsa;
}
