import 'dart:math';

double sdsToCentile(double sds) {
  // Using a direct approximation for the standard normal CDF (Φ(z))
  // This is a variation of the Abramowitz and Stegun approximation.
  const p = 0.2316419;
  const b1 = 0.319381530;
  const b2 = -0.356563782;
  const b3 = 1.781477937;
  const b4 = -1.821255978;
  const b5 = 1.330274429;

  double z = sds; // Use sds as z

  if (z == 0.0) {
    return 50.0;
  }

  double t = 1.0 / (1.0 + p * z.abs());
  double pdf = (1.0 / sqrt(2 * pi)) *
      exp(-0.5 * z * z); // PDF: Probability Density Function
  double cdfApprox = 1.0 -
      pdf *
          (b1 * t +
              b2 * pow(t, 2) +
              b3 * pow(t, 3) +
              b4 * pow(t, 4) +
              b5 * pow(t, 5));

  double probability;
  if (z >= 0) {
    probability = cdfApprox;
  } else {
    probability = 1.0 -
        cdfApprox; // Due to symmetry: P(X <= z) = 1 - P(X <= -z) for z < 0
  }

  // Ensure probability is within [0, 1] range due to approximation limits
  if (probability < 0.0) probability = 0.0;
  if (probability > 1.0) probability = 1.0;

  return probability * 100.0;
}
