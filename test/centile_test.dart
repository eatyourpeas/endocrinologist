import 'package:endocrinologist/calculations/centile.dart'; // Or the correct path
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('sdsToCentile', () {
    // Helper to get expected centiles from a Z-table or online calculator
    // (approximations, as the function itself is an approximation)
    // Common Z-scores and their corresponding percentiles:
    // Z = 0.0  => 50th percentile
    // Z = 1.0  => ~84.13th percentile
    // Z = -1.0 => ~15.87th percentile
    // Z = 2.0  => ~97.72th percentile
    // Z = -2.0 => ~2.28th percentile
    // Z = 1.645 => ~95th percentile
    // Z = -1.645 => ~5th percentile
    // Z = 1.96 => ~97.5th percentile
    // Z = -1.96 => ~2.5th percentile
    // Z = 3.0 => ~99.87th percentile
    // Z = -3.0 => ~0.13th percentile

    // The precision of your function depends on the approximation used.
    // We'll use closeTo with a reasonable delta.

    test('should return 50.0 for SDS of 0.0', () {
      expect(sdsToCentile(0.0), equals(50.0));
    });

    test('should return ~84.13 for SDS of 1.0', () {
      // From Z-table, Φ(1.0) ≈ 0.84134
      expect(sdsToCentile(1.0), closeTo(84.134, 0.01)); // Delta of 0.01 percent
    });

    test('should return ~15.87 for SDS of -1.0', () {
      // From Z-table, Φ(-1.0) ≈ 0.15866
      expect(sdsToCentile(-1.0), closeTo(15.866, 0.01));
    });

    test('should return ~97.72 for SDS of 2.0', () {
      // From Z-table, Φ(2.0) ≈ 0.97725
      expect(sdsToCentile(2.0), closeTo(97.725, 0.01));
    });

    test('should return ~2.28 for SDS of -2.0', () {
      // From Z-table, Φ(-2.0) ≈ 0.02275
      expect(sdsToCentile(-2.0), closeTo(2.275, 0.01));
    });

    test('should return ~95.0 for SDS of 1.645 (P95)', () {
      // Φ(1.645) ≈ 0.9500
      expect(sdsToCentile(1.645),
          closeTo(95.0, 0.05)); // Approximation might be less precise here
    });

    test('should return ~5.0 for SDS of -1.645 (P5)', () {
      // Φ(-1.645) ≈ 0.0500
      expect(sdsToCentile(-1.645), closeTo(5.0, 0.05));
    });

    test('should return ~97.5 for SDS of 1.96 (P97.5)', () {
      // Φ(1.96) ≈ 0.9750
      expect(sdsToCentile(1.96), closeTo(97.5, 0.02));
    });

    test('should return ~2.5 for SDS of -1.96 (P2.5)', () {
      // Φ(-1.96) ≈ 0.0250
      expect(sdsToCentile(-1.96), closeTo(2.5, 0.02));
    });

    test('should return ~99.865 for SDS of 3.0', () {
      // From Z-table, Φ(3.0) ≈ 0.99865
      expect(sdsToCentile(3.0), closeTo(99.865, 0.01));
    });

    test('should return ~0.135 for SDS of -3.0', () {
      // From Z-table, Φ(-3.0) ≈ 0.00135
      expect(sdsToCentile(-3.0), closeTo(0.135, 0.01));
    });

    test('should handle very large positive SDS values, approaching 100.0', () {
      double largeSDS = 6.0;
      // Φ(6.0) is very close to 1.0 (approx 0.999999999013)
      // The approximation might clip to 100.0 earlier.
      // Your function has: if (probability > 1.0) probability = 1.0;
      expect(sdsToCentile(largeSDS), closeTo(100.0, 0.001));
    });

    test('should handle very large negative SDS values, approaching 0.0', () {
      double largeNegativeSDS = -6.0;
      // Φ(-6.0) is very close to 0.0 (approx 0.000000000987)
      // Your function has: if (probability < 0.0) probability = 0.0;
      expect(sdsToCentile(largeNegativeSDS), closeTo(0.0, 0.001));
    });

    // Test the clamping behavior specifically
    test(
        'result should be clamped to 0.0 if approximation yields negative probability',
        () {
      // This is hard to trigger with valid SDS inputs for this specific approximation,
      // as it's designed for the normal CDF.
      // However, if we could somehow force `cdfApprox` to be > 1 for z < 0,
      // then `1.0 - cdfApprox` would be negative.
      // Or for z > 0, if `cdfApprox` was < 0.
      // The internal clamping `if (probability < 0.0) probability = 0.0;` is tested by extreme values.
      // For instance, an SDS of -8 should produce a value extremely close to 0.
      expect(sdsToCentile(-8.0), closeTo(0.0, 0.00001));
    });

    test(
        'result should be clamped to 100.0 if approximation yields probability > 1',
        () {
      // Similarly, an SDS of 8 should produce a value extremely close to 100.
      expect(sdsToCentile(8.0), closeTo(100.0, 0.00001));
    });
  });
}
