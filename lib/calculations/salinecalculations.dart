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