
import 'package:endocrinologist/pages/splchart.dart';
import 'package:flutter/material.dart';
import '../calculations/spltermpretermnormativevalues.dart';
import 'cllchart.dart';

class FetalSPLTab extends StatefulWidget{
  const FetalSPLTab({super.key});

  @override
  State <FetalSPLTab> createState() => _FetalSPLTabState();
}

class _FetalSPLTabState extends State<FetalSPLTab>{

  int selectedGestationWeek = 40; // Initial value
  String _sdsString = '';
  String _centileString = '';
  double spl = 0;
  double cll = 0;
  double cwl = 0;
  bool showScatterPoint=false;
  bool showSPL = true;
  bool showCLL = true;

  final _cllController = TextEditingController();
  final _cwlController = TextEditingController();
  final _splController = TextEditingController();
  final List<int> gestationWeeks = List.generate(19, (index) => 41-index);

  void _calculateResult() {
    // Replace with your actual calculation logic
    if (showSPL){
      spl = double.tryParse(_splController.text) ?? 0;
    } else {
      if (showCLL){
        cll = double.tryParse(_cllController.text) ?? 0;
      } else {
        cwl = double.tryParse(_cwlController.text) ?? 0;
      }
    }
    double sds;
    double centile;
    (sds, centile) = FetalSPLData.calculateSDSAndCentile(selectedGestationWeek, spl);

    setState(() {
      _sdsString = 'SDS: ${sds.toStringAsFixed(1)}';
      _centileString = 'Centile: ${centile.toStringAsFixed(1)}';
      showScatterPoint = true;
    });
  }

  @override
  Widget build(BuildContext context){
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(showSPL ? 'Stretched Penile Length' : 'Clitoral Length/Width'),
            Switch(
              value: showSPL,
              onChanged: (value) {
                setState(() {
                  showSPL = value;
                });
              },
            ),
            DropdownButtonFormField(
              decoration: InputDecoration(
                  labelText: "Gestational Age"
              ),
              items: gestationWeeks.map((week) {
                return DropdownMenuItem<int>(
                  value: week,
                  child: Text('$week'),
                );
              }).toList(),
              onChanged: (int? newValue) {
                setState(() {
                  selectedGestationWeek = newValue!;
                });
              },
              value: selectedGestationWeek, // Initialize with a default value
            ),

            ...[
              if (showSPL)
                TextField(
                  controller: _splController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'SPL (cm)',
                  ),
                )
              else
                Column(
                    children:[
                      TextField(
                          controller: _cllController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Clitoral Length (cm)',
                          )),
                      TextField(
                          controller: _cwlController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Clitoral Width (cm)',
                          ))
                    ]
                )
            ],
            ElevatedButton(
              onPressed: _calculateResult,
              child: const Text('Calculate'),
            ),
            Column(
              children: [
                Text(_sdsString),
                Text(_centileString),
                if (!showSPL)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(showCLL ? 'Clitoral Length' : 'Clitoral Width'),
                      ),
                      Expanded(child: Switch(
                        value: showCLL,
                        onChanged: (value) {
                          setState(() {
                            showCLL = value;
                          });
                        },
                      ),)
                    ],
                  ),
                ...[
                  if (showSPL)
                    FetalSPLChart(
                      selectedGestationWeek: selectedGestationWeek,
                      spl: spl,
                      showScatterPoint: showScatterPoint,
                    )
                  else
                    if (showCLL)
                      FetalCLLChart(
                          selectedGestationWeek: selectedGestationWeek,
                          cll: cll,
                          showScatterPoint: showScatterPoint,
                          isWidth: showCLL
                      )
                    else
                      FetalCLLChart(
                          selectedGestationWeek: selectedGestationWeek,
                          cll: cll,
                          showScatterPoint: showScatterPoint,
                          isWidth: showCLL
                      ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
  @override
  void dispose() {
    _cllController.dispose();
    _cwlController.dispose();
    _splController.dispose();
    super.dispose();
  }
}