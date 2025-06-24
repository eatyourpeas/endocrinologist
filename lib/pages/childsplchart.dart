import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../classes/scatterdata.dart';
import '../classes/bulgarianspl.dart';
import '../referencedata/bulgarianspldata.dart';

import '../enums/enums.dart';

/*
Child specific data is likely ethnicity-sensitive.
The largest and newest cohort of Indian data is from April 2025
https://www.jpurol.com/article/S1477-5131(24)00621-1/abstract
Pediatric penile anthropometry nomogram: Establishing standardized reference values
Goel, Prabudh et al.
Journal of Pediatric Urology, Volume 21, Issue 2, 454 - 459

A large Bulgarian reference
Tomova A, Deepinder F, Robeva R, Lalabonova H, Kumanov P, Agarwal A.
Growth and Development of Male External Genitalia: A Cross-sectional Study of 6200 Males Aged 0 to 19 Years.
Arch Pediatr Adolesc Med. 2010;164(12):1152–1157.
doi:10.1001/archpediatrics.2010.223
https://jamanetwork.com/journals/jamapediatrics/fullarticle/384064
*/

class ChildSPLChart extends StatefulWidget {
  final double decimal_age;
  final double spl;
  final bool showScatterPoint;

  const ChildSPLChart({
    super.key,
    required this.decimal_age,
    required this.spl,
    required this.showScatterPoint
  });

  @override
  State <ChildSPLChart> createState() => _ChildSPLChartState();
}

class _ChildSPLChartState extends State<ChildSPLChart>{
  @override
  Widget build(BuildContext context) {

    // filter the reference data into centile lines
    final p5Data = childSPLData.where((data) => data.centile == Centile.P5).toList();
    final p50Data = childSPLData.where((data) => data.centile == Centile.P50).toList();
    final p95Data = childSPLData.where((data) => data.centile == Centile.P95).toList();

    return Column(
        children: [SfCartesianChart(
          primaryXAxis: NumericAxis(title: AxisTitle(text: 'Age (y)')),
          primaryYAxis: NumericAxis(title: AxisTitle(text: 'Size (cm)')),
          legend: Legend(
              isVisible: true,
              isResponsive: true
          ),
          series: <CartesianSeries>[
            LineSeries<ChildSPLDataPoint, int>(
              dataSource: p5Data,
              xValueMapper: (ChildSPLDataPoint data, _) => data.age,
              yValueMapper: (ChildSPLDataPoint data, _) => data.penileLengthCm,
              color: Colors.blue,
              name: '5th Percentile',
            ),
            LineSeries<ChildSPLDataPoint, int>(
              dataSource: p50Data,
              xValueMapper: (ChildSPLDataPoint data, _) => data.age,
              yValueMapper: (ChildSPLDataPoint data, _) => data.penileLengthCm,
              color: Colors.blue,
              name: '50th percentile',
            ),
            LineSeries<ChildSPLDataPoint, int>(
              dataSource: p95Data,
              xValueMapper: (ChildSPLDataPoint data, _) => data.age,
              yValueMapper: (ChildSPLDataPoint data, _) => data.penileLengthCm,
              color: Colors.blue,
              name: '95th percentile',
            ),
            if (widget.showScatterPoint)
              ScatterSeries<DecimalAgeScatterData, double>(
                dataSource: [DecimalAgeScatterData(widget.decimal_age, widget.spl)], // Use user input
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
              'Reference: Tomova A, Deepinder F, Robeva R, Lalabonova H, Kumanov P, Agarwal A.Growth and Development of Male External Genitalia: A Cross-sectional Study of 6200 Males Aged 0 to 19 Years., Arch Pediatr Adolesc Med. 210;164(12):1152–1157.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12),
            ),
          ),]
    );
  }

}