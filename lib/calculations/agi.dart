class AnoGenitalDistance {

  // final _rawData = [
  //   5th	10th	25th	50th	75th	90th	95th
  //   Males
  //   AGD (mm)	18.47	19.44	21.00	22.68	25.20	27.80	29.08
  //   AGI (mm/kg)	5.59	5.83	6.30	6.93	7.62	8.22	8.57
  //   Females
  //   AGD (mm)	9.40	9.85	10.55	11.65	12.60	13.45	14.10
  //   AGI (mm/kg)	3.04	3.15	3.38	3.59	3.80	4.00	4.19
  // ]

  // Reference Ranges for Anogenital Distance and Anogenital Index in Term Neonates
  // Flück CE, Güran T. Ambiguous Genitalia in the Newborn. [Updated 2023 Nov 13]. In: Feingold KR, Anawalt B, Blackman MR, et al., editors. Endotext [Internet]. South Dartmouth (MA): MDText.com, Inc.; 2000-. Available from: https://www.ncbi.nlm.nih.gov/books/NBK279168/

  static List<int> _centiles = [5,10,25,50,75,90,95];
  static List<double> _maleAGD = [18.47,19.44,21.00,22.68,25.20,27.80,29.08];
  static List<double> _femaleAGD = [9.40,9.85,10.55,11.65,12.60,13.45,14.10];
  static List<double> _maleAGI = [5.59,5.83,6.30,6.93,7.62,8.22,8.57];
  static List<double> _femaleAGI = [3.04,3.15,3.38,3.59,3.80,4.00,4.19];

  // class members and definition
  final double anoGenitalDistance;
  final double anoGenitalIndex;
  final int centile;
  final String sex;

  AnoGenitalDistance._({
    required this.anoGenitalDistance,
    required this.anoGenitalIndex,
    required this.centile,
    required this.sex
  });

  static List<AnoGenitalDistance> _createAnoGenitalDistanceList(String sex){
    List<AnoGenitalDistance> dataList = [];
    List<double> agiData = [];
    List<double> agdData = [];
    if (sex=="male"){
      agiData = _maleAGI;
      agdData = _maleAGD;
    }
    if (sex=="female"){
      agiData = _femaleAGI;
      agdData = _femaleAGD;
    }
    for (int index=0; index < _centiles.length; index ++) {
      dataList.add(AnoGenitalDistance._(
          anoGenitalDistance: agdData[index],
          anoGenitalIndex: agiData[index],
          centile: _centiles[index],
          sex: sex
      ));
    }
    return dataList;
  }

  // Static list to store the data
  static List<AnoGenitalDistance> dataList = [];

  // Factory constructor to call createAnoGenitalDistanceList
  factory AnoGenitalDistance() {
    dataList += _createAnoGenitalDistanceList("male");
    dataList += _createAnoGenitalDistanceList("female");
    // You might want to return a specific instance or throw an exception here
    // depending on your use case. For now, returning the first element:
    return dataList.isNotEmpty ? dataList[0] : throw Exception('Empty data');
  }

}
