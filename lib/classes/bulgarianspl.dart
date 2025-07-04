import '../enums/enums.dart';

class ChildBulgarianSPLDataPoint {
  final int age;
  final Centile centile;
  final double heightCm;
  final double weightKg;
  final double penileLengthCm;
  final double penileCircumferenceCm;
  final double rightTestisVolumeMl;
  final double leftTestisVolumeMl;

  ChildBulgarianSPLDataPoint({
    required this.age,
    required this.centile,
    required this.heightCm,
    required this.weightKg,
    required this.penileLengthCm,
    required this.penileCircumferenceCm,
    required this.rightTestisVolumeMl,
    required this.leftTestisVolumeMl,
  });
}
