import 'dart:math'; // Needed for sqrt function

enum BsaCalculationMethod {
  mostellar,
  boyd,
  dubois,
  gehangeorge
}

double calculateBSA(double heightCm, double weightKg, BsaCalculationMethod method) {

  double bsa = 0.0;

  switch (method) {
    case BsaCalculationMethod.mostellar:
      bsa = sqrt((heightCm * weightKg) / 3600);
      break;

    case BsaCalculationMethod.boyd:
      // Boyd requires weight to be converted to grams
      double weightGrams = weightKg * 1000; // Convert weight from kg to grams
      double exponent = 0.7285 - 0.0188 * log(weightGrams);
      bsa = 0.0003207 * pow((heightCm / 0.3), 0.3) * pow(weightGrams, exponent);
      break;

    case BsaCalculationMethod.dubois:
      bsa = 0.007184 * pow(heightCm, 0.725) * pow(weightKg, 0.425);
      break;

    case BsaCalculationMethod.gehangeorge:
      bsa = 0.0235 * pow(heightCm, 0.42246) * pow(weightKg, 0.51456);
      break;
  }

  return bsa;
}