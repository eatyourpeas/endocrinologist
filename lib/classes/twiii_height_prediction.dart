class TWIIIAdultHeightPrediction {
  final String sex;
  final String? menarchealStatus;
  final String age;
  final double heightCoefficient;
  final double chronologicalAgeCoefficient;
  final double boneAgeCoefficient;
  final int constant;
  final double residualSD;
  final double r;

  TWIIIAdultHeightPrediction({
    required this.sex,
    this.menarchealStatus,
    required this.age,
    required this.heightCoefficient,
    required this.chronologicalAgeCoefficient,
    required this.boneAgeCoefficient,
    required this.constant,
    required this.residualSD,
    required this.r,
  });
}