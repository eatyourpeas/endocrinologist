import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../calculations/spltermpretermnormativevalues.dart';
import '../classes/scatterdata.dart';

class FetalSPLChart extends StatefulWidget {
  final int selectedGestationWeek;
  final double spl;
  final bool showScatterPoint;

  const FetalSPLChart({
    super.key,
    required this.selectedGestationWeek,
    required this.spl,
    required this.showScatterPoint
  });

  @override
  State <FetalSPLChart> createState() => _FetalSPLChartState();
}

class _FetalSPLChartState extends State<FetalSPLChart>{
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [SfCartesianChart(
        primaryXAxis: NumericAxis(title: AxisTitle(text: 'Gestational Weeks')),
        primaryYAxis: NumericAxis(title: AxisTitle(text: 'Size (cm)')),
        series: <ChartSeries>[
          LineSeries<FetalSPLData, int>(
            dataSource: FetalSPLData.dataList,
            xValueMapper: (FetalSPLData data, _) => data.gestationalWeeks,
            yValueMapper: (FetalSPLData data, _) => data.medianSize,
            name: 'Median Size',
          ),
          LineSeries<FetalSPLData, int>(
            dataSource: FetalSPLData.dataList,
            xValueMapper: (FetalSPLData data, _) => data.gestationalWeeks,
            yValueMapper: (FetalSPLData data, _) => data.minimumSize,
            name: 'Minimum Size',
          ),
          LineSeries<FetalSPLData, int>(
            dataSource: FetalSPLData.dataList,
            xValueMapper: (FetalSPLData data, _) => data.gestationalWeeks,
            yValueMapper: (FetalSPLData data, _) => data.maximumSize,
            name: 'Maximum Size',
          ),
          if (widget.showScatterPoint)
            ScatterSeries<ScatterData, int>(
              dataSource: [ScatterData(widget.selectedGestationWeek, widget.spl)], // Use user input
              xValueMapper: (ScatterData data, _) => data.x,
              yValueMapper: (ScatterData data, _) => data.y,
              markerSettings: const MarkerSettings(
                isVisible: true,
                height: 10,
                width: 10,
                shape: DataMarkerType.circle,
                borderWidth: 2,
                borderColor: Colors.red, // Customize color as needed
              ),
            ),
        ],
        title: ChartTitle(text: 'Stretched Penile Length for Gestation'),
      ),
      const Padding(
        padding: EdgeInsets.all(8.0),
        child: Text(
          'Reference: Halil H, Oğuz ŞS. Establishment of normative data for stretched penile length in Turkish preterm and term newborns. Turk J Pediatr. 2017;59(3):269-273.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12),
        ),
      ),]
    );
  }

}