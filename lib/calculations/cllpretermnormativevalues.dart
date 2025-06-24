// Import for statistical calculations

class FetalCLLData {

  /*
  Alaei M, Rohani F, Norouzi E, Hematian Boroujeni N, Tafreshi RI, Salehiniya H, Soheilipour F.
  The Nomogram of Clitoral Length and Width in Iranian Term and Preterm Neonates.
  Front Endocrinol (Lausanne). 2020;11:297.
  */

  // data
  static List<List<dynamic>> _rawData = [
    [28, 30, 3.28, 3.87, 4.46, 5.05, 5.03, 5.91, 6.79, 7.67],
    [30, 57, 3.32, 3.68, 4.04, 4.4, 5.03, 5.52, 6.01, 6.5],
    [32, 74, 3.41, 3.77, 4.13, 4.49, 5.14, 5.65, 6.16, 6.67],
    [34, 104, 3.69, 4.17, 4.65, 5.13, 5.53, 6.12, 6.71, 7.3],
    [36, 128, 4.08, 4.5, 4.92, 5.34, 5.83, 6.29, 6.75, 7.21],
    [38, 187, 4.21, 4.64, 5.07, 5.5, 6.11, 6.49, 6.87, 7.25],
    [42, 187, 4.21, 4.64, 5.07, 5.5, 6.11, 6.49, 6.87, 7.25]
  ];


// Static list to store the data
  static List<FetalCLLData> dataList = _createFetalCLLDataList(_rawData);

// class members and definition
  final int gestationalWeeks;
  final int numberOfCases;
  final double meanWidth;
  final double meanWidthOneSDS;
  final double meanWidthTwoSDS;
  final double meanWidthThreeSDS;
  final double meanLength;
  final double meanLengthOneSDS;
  final double meanLengthTwoSDS;
  final double meanLengthThreeSDS;
  static String reference = "Alaei M, Rohani F, Norouzi E, Hematian Boroujeni N, Tafreshi RI, Salehiniya H, Soheilipour F. The Nomogram of Clitoral Length and Width in Iranian Term and Preterm Neonates. Front Endocrinol (Lausanne). 2020;11:297.";

  FetalCLLData._({
    required this.gestationalWeeks,
    required this.numberOfCases,
    required this.meanWidth,
    required this.meanWidthOneSDS,
    required this.meanWidthTwoSDS,
    required this.meanWidthThreeSDS,
    required this.meanLength,
    required this.meanLengthOneSDS,
    required this.meanLengthTwoSDS,
    required this.meanLengthThreeSDS
  });

  static List<FetalCLLData> _createFetalCLLDataList(List<List<dynamic>> rawData) {
    List<FetalCLLData> dataList = [];
    for (var row in _rawData) {
      dataList.add(FetalCLLData._(
          gestationalWeeks: row[0] as int,
          numberOfCases: row[1] as int,
          meanWidth: row[2] as double,
          meanWidthOneSDS: row[3] as double,
          meanWidthTwoSDS: row[4] as double,
          meanWidthThreeSDS: row[5] as double,
          meanLength: row[6] as double,
          meanLengthOneSDS: row[7] as double,
          meanLengthTwoSDS: row[8] as double,
          meanLengthThreeSDS: row[9] as double
      ));
    }
    return dataList;
  }

  // Factory constructor to call createFetalSPLDataList
  factory FetalCLLData.fromRawData(List<List<dynamic>> rawData) {
    _rawData = rawData; // Assign rawData to the private member
    dataList = _createFetalCLLDataList(rawData);
    // returning the first element:
    return dataList.isNotEmpty ? dataList[0] : throw Exception('Empty data');
  }

  // Class method to find the nearest gestation data
  static FetalCLLData? findNearestGestationCLLSizesForGestation(int gestation) {
    // Find the nearest gestation
    FetalCLLData? nearestData;
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

}