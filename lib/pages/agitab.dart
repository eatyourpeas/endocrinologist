import 'package:flutter/cupertino.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class TermAGITab extends StatefulWidget{
  const TermAGITab({super.key});

  @override
  State <TermAGITab> createState() => _TermAGITabState();
}

class _TermAGITabState extends State<TermAGITab>{

  @override
  Widget build(BuildContext context){
    return SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              SfCartesianChart(
                legend: Legend(
                    isVisible: true,
                    isResponsive: true
                ),
                primaryXAxis: NumericAxis(title: AxisTitle(text: 'Gestational Weeks')),
                primaryYAxis: NumericAxis(title: AxisTitle(text: 'Size (cm)'), minimum: 2.0),
                series: <CartesianSeries>[

                ],
            title: ChartTitle(text: 'Reference Ranges for Anogenital Distance and Anogenital Index in Term Neonates'),
              )
            ])
      )
    );
  }
}