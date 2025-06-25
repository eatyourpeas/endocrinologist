import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../classes/scatterdata.dart';
import '../referencedata/indian_data.dart';

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

class ChildIndianSPLChart extends StatefulWidget {
  final double decimal_age;
  final double spl;
  final bool showScatterPoint;

  const ChildIndianSPLChart({
    super.key,
    required this.decimal_age,
    required this.spl,
    required this.showScatterPoint
  });

  @override
  State <ChildIndianSPLChart> createState() => _ChildIndianSPLChartState();
}

class _ChildIndianSPLChartState extends State<ChildIndianSPLChart>{
  @override
  Widget build(BuildContext context) {
    // --- Data Transformation ---
    List<ChildSPLDataPoint> p5Data = [];
    List<ChildSPLDataPoint> p50Data = [];
    List<ChildSPLDataPoint> p95Data = [];
    // You can add more lists for other centiles if needed (e.g., p5, p10, p25, p75, p90, p97)

    for (var dataEntry in IndianStretchedPenileLengthList) {
      int? age = dataEntry.ageYears;
      if (age == null) {
        // print("Warning: Could not parse age '${dataEntry.ageYears}' to int. Skipping entry.");
        continue; // Skip this entry if age is not a valid integer
      }

      // Add data point for 3rd percentile
      p5Data.add(ChildSPLDataPoint(
        age: age,
        centile: Centile.P5, // Tagging with the Centile enum
        value: dataEntry.percentile5th,
      ));

      // Add data point for 50th percentile
      p50Data.add(ChildSPLDataPoint(
        age: age,
        centile: Centile.P50,
        value: dataEntry.percentile50th,
      ));

      // Add data point for 95th percentile
      p95Data.add(ChildSPLDataPoint(
        age: age,
        centile: Centile.P95,
        value: dataEntry.percentile95th,
      ));
    }

    // Sort data by age for correct line drawing (important!)
    p5Data.sort((a, b) => a.age.compareTo(b.age));
    p50Data.sort((a, b) => a.age.compareTo(b.age));
    p95Data.sort((a, b) => a.age.compareTo(b.age));
    // if (p5Data.isNotEmpty) p5Data.sort((a, b) => a.age.compareTo(b.age));


    // --- Chart Building ---
    return Column(
      children: [
        SfCartesianChart(
          primaryXAxis: NumericAxis(
            title: AxisTitle(text: 'Age (Years)'),
            interval: 1,
          ),
          primaryYAxis: NumericAxis(title: AxisTitle(text: 'Stretched Penile Length (cm)')),
          legend: Legend(isVisible: true, position: LegendPosition.bottom),
          series: <CartesianSeries>[
            // 3rd Percentile Line
            LineSeries<ChildSPLDataPoint, int>(
              dataSource: p5Data,
              xValueMapper: (ChildSPLDataPoint data, _) => data.age,
              yValueMapper: (ChildSPLDataPoint data, _) => data.value,
              name: '5th Percentile',
              color: Colors.blue,
              dashArray: [5,5],
            ),

            // 50th Percentile Line (Median)
            LineSeries<ChildSPLDataPoint, int>(
              dataSource: p50Data,
              xValueMapper: (ChildSPLDataPoint data, _) => data.age,
              yValueMapper: (ChildSPLDataPoint data, _) => data.value,
              name: '50th Percentile',
              color: Colors.blue,
            ),

            // 95th Percentile Line
            LineSeries<ChildSPLDataPoint, int>(
              dataSource: p95Data,
              xValueMapper: (ChildSPLDataPoint data, _) => data.age,
              yValueMapper: (ChildSPLDataPoint data, _) => data.value,
              name: '95th Percentile',
              color: Colors.blue,
              dashArray: [5,5],
            ),

            // Patient's Data Scatter Plot
            if (widget.showScatterPoint) // Assuming showScatterPoint comes from widget
              ScatterSeries<DecimalAgeScatterData, double>(
                dataSource: [DecimalAgeScatterData(widget.decimal_age, widget.spl)], // Use patient input
                xValueMapper: (DecimalAgeScatterData data, _) => data.x,
                yValueMapper: (DecimalAgeScatterData data, _) => data.y,
                name: 'Patient Data',
                color: Colors.orange,
                markerSettings: const MarkerSettings(
                  isVisible: true,
                  height: 10,
                  width: 10,
                  shape: DataMarkerType.circle,
                  borderWidth: 2,
                  borderColor: Colors.black,
                ),
              ),
          ],
          title: ChartTitle(text: 'Stretched Penile Length for Age (Indian Reference)'),
          tooltipBehavior: TooltipBehavior(enable: true),
        ),
        // Optional: Reference text
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            'Reference: Pediatric penile anthropometry nomogram: Establishing standardized reference values, Goel, Prabudh et al., Journal of Pediatric Urology, Volume 21, Issue 2, 454 - 459',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 10),
          ),
        ),
      ],
    );
  }

}