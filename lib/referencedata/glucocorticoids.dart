import "../classes/glucocorticoid.dart";

List<Glucocorticoid> glucocorticoids = [
  Glucocorticoid(name: "Hydrocortisone", potency: 1),
  Glucocorticoid(name: "Cortisone", potency: 0.8),
  Glucocorticoid(name: "Prednisone", potency: 4),
  Glucocorticoid(name: "Prednisolone", potency: 4),
  Glucocorticoid(name: "Methylprednisolone", potency: 5),
  Glucocorticoid(name: "Triamcinolone", potency: 5),
  Glucocorticoid(name: "Betamethasone", potency: 25),
  Glucocorticoid(name: "Dexamethasone", potency: 40),
  Glucocorticoid(name: "Fludrocortisone", potency: 10),
  Glucocorticoid(name: "Desonide", potency: 3),
  Glucocorticoid(name: "Fluocinolone", potency: 150),
  Glucocorticoid(name: "Clobetasol", potency: 300),
];

List<Glucocorticoid> sortedGlucocorticoids(
    List<Glucocorticoid> glucocorticoids) {
  List<Glucocorticoid> sorted = List.from(glucocorticoids);
  sorted.sort((a, b) => a.name.compareTo(b.name));
  return sorted;
}
