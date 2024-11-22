import 'package:endocrinologist/pages/splchart.dart';
import 'package:flutter/material.dart';
import '../calculations/spltermpretermnormativevalues.dart';


class AuxologyPage extends StatefulWidget {
  const AuxologyPage({super.key});

  @override
  State<AuxologyPage> createState() => _AuxologyPageState();
}

class _AuxologyPageState extends State<AuxologyPage> {
  final _splController = TextEditingController();
  final List<int> gestationWeeks = List.generate(19, (index) => index + 23);
  int selectedGestationWeek = 23; // Initial value
  String _sdsString = '';
  String _centileString = '';
  double spl = 0;
  bool showScatterPoint=false;

  void _calculateResult() {
    // Replace with your actual calculation logic
    spl = double.tryParse(_splController.text) ?? 0;
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Auxology Calculator'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                    child: DropdownButtonFormField(
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
                ),
                Expanded(child:
                TextField(
                  controller: _splController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'SPL (cm)',
                  ),
                ),
                )

              ],
            ),

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _calculateResult,
              child: const Text('Calculate'),
            ),
            const SizedBox(height: 20),
            Column(
              children: [
                Text(_sdsString),
                Text(_centileString),
              ],
            ),
            FetalSPLChart(
              selectedGestationWeek: selectedGestationWeek,
              spl: spl,
              showScatterPoint: showScatterPoint,
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _splController.dispose();
    super.dispose();
  }
}