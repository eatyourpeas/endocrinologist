import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../calculations/cllpretermnormativevalues.dart';
import '../classes/scatterdata.dart';

class FetalCLLChart extends StatefulWidget {
  final int selectedGestationWeek;
  final double cll;
  final bool showScatterPoint;
  final bool isWidth;

  const FetalCLLChart({
    super.key,
    required this.selectedGestationWeek,
    required this.cll,
    required this.showScatterPoint,
    required this.isWidth
  });

  @override
  State <FetalCLLChart> createState() => _FetalCLLChartState();
}

class _FetalCLLChartState extends State<FetalCLLChart>{
  @override
  Widget build(BuildContext context) {
    return Column(
        children: [SfCartesianChart(
          legend: Legend(
            isVisible: true,
            isResponsive: true
          ),
          primaryXAxis: NumericAxis(title: AxisTitle(text: 'Gestational Weeks')),
          primaryYAxis: NumericAxis(title: AxisTitle(text: 'Size (cm)'), minimum: 2.0),
          series: <CartesianSeries>[
            LineSeries<FetalCLLData, int>(
              dataSource: FetalCLLData.dataList,
              xValueMapper: (FetalCLLData data, _) => data.gestationalWeeks,
              yValueMapper: (FetalCLLData data, _) => widget.isWidth ? data.meanWidth : data.meanLength,
              color: Colors.blue,
              name: 'Mean Width',
            ),
            LineSeries<FetalCLLData, int>(
              dataSource: FetalCLLData.dataList,
              xValueMapper: (FetalCLLData data, _) => data.gestationalWeeks,
              yValueMapper: (FetalCLLData data, _) => widget.isWidth ? data.meanWidthOneSDS : data.meanLengthOneSDS,
              color: Colors.blue,
              name: '+1 SDS',
            ),
            LineSeries<FetalCLLData, int>(
              dataSource: FetalCLLData.dataList,
              xValueMapper: (FetalCLLData data, _) => data.gestationalWeeks,
              yValueMapper: (FetalCLLData data, _) => widget.isWidth ? data.meanWidthTwoSDS : data.meanLengthTwoSDS,
              color: Colors.blue,
              name: '+2 SDS',
            ),
            LineSeries<FetalCLLData, int>(
              dataSource: FetalCLLData.dataList,
              xValueMapper: (FetalCLLData data, _) => data.gestationalWeeks,
              yValueMapper: (FetalCLLData data, _) => widget.isWidth ? data.meanWidthThreeSDS : data.meanLengthThreeSDS,
              color: Colors.blue,
              name: '+3 SDS',
            ),
            if (widget.showScatterPoint)
              ScatterSeries<ScatterData, int>(
                dataSource: [ScatterData(widget.selectedGestationWeek, widget.cll)], // Use user input
                xValueMapper: (ScatterData data, _) => data.x,
                yValueMapper: (ScatterData data, _) => data.y,
                markerSettings: const MarkerSettings(
                  isVisible: true,
                  height: 10,
                  width: 10,
                  shape: DataMarkerType.circle,
                  borderWidth: 2,
                  borderColor: Colors.green, // Customize color as needed
                ),
              ),
          ],
          title: ChartTitle(text: widget.isWidth ? 'Clitoral Width for Gestation' : 'Clitoral Length for Gestation'),
        ),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              "Alaei M, Rohani F, Norouzi E, Hematian Boroujeni N, Tafreshi RI, Salehiniya H, Soheilipour F. The Nomogram of Clitoral Length and Width in Iranian Term and Preterm Neonates. Front Endocrinol (Lausanne). 2020;11:297.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12),
            ),
          ),]
    );
  }

}