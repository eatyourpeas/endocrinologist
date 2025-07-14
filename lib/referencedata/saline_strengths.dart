import 'package:endocrinologist/classes/saline.dart';

final List<Saline> saline_strengths = [
  Saline(gramsPer100ml: 0.18, name: 'Fifth normal saline', mmolperlitre: 31),
  Saline(gramsPer100ml: 0.45, name: 'Half normal saline', mmolperlitre: 77),
  Saline(gramsPer100ml: 0.9, name: 'Normal saline', mmolperlitre: 154),
  Saline(gramsPer100ml: 1.8, name: 'Twice normal saline', mmolperlitre: 308),
  Saline(gramsPer100ml: 2.7, name: 'Three percent saline', mmolperlitre: 462),
  Saline(gramsPer100ml: 0.6, name: "Hartmann's (Compound Lactate)", mmolperlitre: 131),
  Saline(gramsPer100ml: 0.526, name: "Plasma-Lyte 148", mmolperlitre: 140),
  Saline(gramsPer100ml: 0.526, name: 'Plasma-Lyte A', mmolperlitre: 140),
];

List<Saline> sortedSalineStrengths(List<Saline> saline_strengths) {
  List<Saline> sorted =  List.from(saline_strengths);
  sorted.sort((a, b) => a.mmolperlitre > b.mmolperlitre ? 1 : -1);
  return sorted;
}