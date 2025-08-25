import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../classes/bulgarianspl.dart';
import '../classes/scatterdata.dart';
import '../enums/enums.dart';
import '../referencedata/bulgarianspldata.dart';

/*
Child specific data is likely ethnicity-sensitive.
The largest and newest cohort of Indian data is from April 2025
https://www.jpurol.com/article/S1477-5131(24)00621-1/abstract
Pediatric penile anthropometry nomogram: Establishing standardized reference values
Goel, Prabudh et al.
Journal of Pediatric Urology, Volume 21, Issue 2, 454 - 459
*/

class ChildBulgarianSPLChart extends StatefulWidget {
  final double decimalAge;
  final double spl;
  final bool showScatterPoint;

  const ChildBulgarianSPLChart(
      {super.key,
      required this.decimalAge,
      required this.spl,
      required this.showScatterPoint});

  @override
  State<ChildBulgarianSPLChart> createState() => _ChildBulgarianSPLChartState();
}

// Tomova A, Deepinder F, Robeva R, Lalabonova H, Kumanov P, Agarwal A. Growth and Development of Male External Genitalia: A Cross-sectional Study of 6200 Males Aged 0 to 19 Years. Arch Pediatr Adolesc Med. 2010;164(12):1152–1157. doi:10.1001/archpediatrics.2010.223
class _ChildBulgarianSPLChartState extends State<ChildBulgarianSPLChart> {
  @override
  Widget build(BuildContext context) {
    // filter the reference data into centile lines
    final p5Data = childBulgarianSPLData
        .where((data) => data.centile == Centile.p5)
        .toList();
    final p50Data = childBulgarianSPLData
        .where((data) => data.centile == Centile.p50)
        .toList();
    final p95Data = childBulgarianSPLData
        .where((data) => data.centile == Centile.p95)
        .toList();

    return Column(children: [
      SfCartesianChart(
        primaryXAxis: NumericAxis(title: AxisTitle(text: 'Age (y)')),
        primaryYAxis: NumericAxis(title: AxisTitle(text: 'Size (cm)')),
        legend: Legend(isVisible: true, isResponsive: true),
        series: <CartesianSeries>[
          LineSeries<ChildBulgarianSPLDataPoint, int>(
            dataSource: p5Data,
            xValueMapper: (ChildBulgarianSPLDataPoint data, _) => data.age,
            yValueMapper: (ChildBulgarianSPLDataPoint data, _) =>
                data.penileLengthCm,
            color: Colors.blue,
            name: '5th Percentile',
            dashArray: [5, 5],
          ),
          LineSeries<ChildBulgarianSPLDataPoint, int>(
            dataSource: p50Data,
            xValueMapper: (ChildBulgarianSPLDataPoint data, _) => data.age,
            yValueMapper: (ChildBulgarianSPLDataPoint data, _) =>
                data.penileLengthCm,
            color: Colors.blue,
            name: '50th percentile',
          ),
          LineSeries<ChildBulgarianSPLDataPoint, int>(
            dataSource: p95Data,
            xValueMapper: (ChildBulgarianSPLDataPoint data, _) => data.age,
            yValueMapper: (ChildBulgarianSPLDataPoint data, _) =>
                data.penileLengthCm,
            color: Colors.blue,
            name: '95th percentile',
            dashArray: [5, 5],
          ),
          if (widget.showScatterPoint)
            ScatterSeries<DecimalAgeScatterData, double>(
              dataSource: [
                DecimalAgeScatterData(widget.decimalAge, widget.spl)
              ], // Use user input
              xValueMapper: (DecimalAgeScatterData data, _) => data.x,
              yValueMapper: (DecimalAgeScatterData data, _) => data.y,
              markerSettings: const MarkerSettings(
                isVisible: true,
                height: 10,
                width: 10,
                shape: DataMarkerType.circle,
                borderWidth: 2,
                borderColor: Colors.orange, // Customize color as needed
              ),
            ),
        ],
        title: ChartTitle(text: 'Stretched Penile Length for Age'),
      ),
      const Padding(
        padding: EdgeInsets.all(8.0),
        child: Text(
          'Tomova A, Deepinder F, Robeva R, Lalabonova H, Kumanov P, Agarwal A. Growth and Development of Male External Genitalia: A Cross-sectional Study of 6200 Males Aged 0 to 19 Years. Arch Pediatr Adolesc Med. 2010;164(12):1152–1157. doi:10.1001/archpediatrics.2010.223',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12),
        ),
      ),
    ]);
  }
}
