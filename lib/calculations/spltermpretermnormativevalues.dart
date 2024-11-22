// Import for statistical calculations
import 'package:normal/normal.dart';

class FetalSPLData {

  /*
  Halil H, Oğuz ŞS.
  Establishment of normative data for stretched penile length in Turkish preterm and term newborns.
  Turk J Pediatr. 2017;59(3):269-273.
  doi: 10.24953/turkjped.2017.03.006.
  PMID: 29376571.
  */

  // data
  static List<List<dynamic>> _rawData = [
    [26,30,1.9,1.9,0.32,1.1,2.5],
    [27,31,2.1,2.0,0.28,1.1,2.6],
    [28,32,2.0,1.9,0.31,1.3,2.9],
    [29,29,2.3,2.3,0.39,1.3,2.9],
    [30,31,2.4,2.4,0.32,1.6,3.0],
    [31,33,2.4,2.4,0.38,1.8,3.3],
    [32,32,2.9,2.6,0.44,2.0,3.2],
    [33,28,2.9,2.8,0.45,1.9,3.4],
    [34,30,2.9,2.8,0.43,2.0,3.6],
    [35,29,3.1,2.9,0.61,2.0,4.1],
    [36,31,3.1,3.0,0.50,2.2,4.0],
    [37,29,3.1,3.0,0.47,2.2,4.1],
    [38,44,3.1,3.1,0.54,2.1,4.5],
    [39,82,3.2,3.2,0.55,2.0,4.2],
    [40,65,3.5,3.4,0.53,2.2,4.4],
    [41,29,3.6,3.5,0.47,2.6,4.3]
  ];

  // Static list to store the data
  static List<FetalSPLData> dataList = _createFetalSPLDataList(_rawData);

  // class members and definition
  final int gestationalWeeks;
  final int numberOfCases;
  final double medianSize;
  final double meanSize;
  final double sds;
  final double minimumSize;
  final double maximumSize;
  static String reference = "Establishment of normative data for stretched penile length in Turkish preterm and term newborns. Halil H, Oğuz ŞS. Turk J Pediatr. 2017;59(3):269-273.";



  // Private constructor to prevent direct instantiation
  FetalSPLData._({
    required this.gestationalWeeks,
    required this.numberOfCases,
    required this.medianSize,
    required this.meanSize,
    required this.sds,
    required this.minimumSize,
    required this.maximumSize,
  });

  static List<FetalSPLData> _createFetalSPLDataList(List<List<dynamic>> rawData) {
    List<FetalSPLData> dataList = [];
    for (var row in _rawData) {
      dataList.add(FetalSPLData._(
        gestationalWeeks: row[0] as int,
        numberOfCases: row[1] as int,
        medianSize: row[2] as double,
        meanSize: row[3] as double,
        sds: row[4] as double,
        minimumSize: row[5] as double,
        maximumSize: row[6] as double,
      ));
    }
    return dataList;
  }

  // Factory constructor to call createFetalSPLDataList
  factory FetalSPLData.fromRawData(List<List<dynamic>> rawData) {
    _rawData = rawData; // Assign rawData to the private member
    dataList = _createFetalSPLDataList(rawData);
    // You might want to return a specific instance or throw an exception here
    // depending on your use case. For now, returning the first element:
    return dataList.isNotEmpty ? dataList[0] : throw Exception('Empty data');
  }

  // Class method to find the nearest gestation data
  static FetalSPLData? findNearestGestationSPLSizesForGestation(int gestation) {
    // Find the nearest gestation
    FetalSPLData? nearestData;
    int minDifference = double.maxFinite.toInt(); // Initialize with a large value
    for (var data in dataList) {
      int difference = (data.gestationalWeeks - gestation).abs();
      if (difference < minDifference) {
        minDifference = difference;
        nearestData = data;
      }
    }
    return nearestData;
  }

  static (double, double) calculateSDSAndCentile(int gestation, double spl){
    final nearestGestationData = findNearestGestationSPLSizesForGestation(gestation);
    if (nearestGestationData != null){
      final sds = (spl - nearestGestationData.meanSize)/nearestGestationData.sds;
      final normal = Normal();
      final centile = normal.cdf(sds) + nearestGestationData.meanSize;
      return (sds, centile.toDouble());
    } else {
      return (double.nan, double.nan);
    }
  }
}





