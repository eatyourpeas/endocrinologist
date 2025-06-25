import '../enums/enums.dart';

class ScatterData {
  final int x; // Gestational week or age
  final double y; // SPL value

  ScatterData(this.x, this.y);
}

class DecimalAgeScatterData {
  final double x; // decimal age
  final double y; // SPL value

  DecimalAgeScatterData(this.x, this.y);
}

class ChildSPLDataPoint {
  final int age;
  final double value;
  final Centile centile;

  ChildSPLDataPoint({
    required this.age,
    required this.value,
    required this.centile,
  });
}
