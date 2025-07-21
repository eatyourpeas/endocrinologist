
import 'package:endocrinologist/calculations/cllpretermnormativevalues.dart';
import 'package:endocrinologist/pages/childbulgariansplchart.dart';
import 'package:endocrinologist/pages/childindiansplchart.dart';
import 'package:endocrinologist/pages/fetalsplchart.dart';
import 'package:flutter/material.dart';
import '../calculations/spltermpretermnormativevalues.dart';
import '../calculations/splchildcalculation.dart';
import 'cllchart.dart';
import '../enums/enums.dart';
import '../calculations/centile.dart';

class GenitalTab extends StatefulWidget{
  final Sex initialSex;
  const GenitalTab({super.key, required this.initialSex});

  @override
  State <GenitalTab> createState() => _GenitalTabState();
}

class _GenitalTabState extends State<GenitalTab>{
  late Sex _currentSex;
  int selectedGestationWeek = 40; // Initial value
  String _sdsString = '';
  String _centileString = '';
  double spl = 0; // Stretched Penile length
  double cll = 0; // Clitoral Length
  double cwl = 0; // Clitoral Width
  bool showScatterPoint=false;
  bool showCLL = false;
  final List<bool> _neonateSelected = [true, false];
  double decimalAge = 0.0;
  final List<bool> _ethnicityIsSelected = [true, false];

  final _cllController = TextEditingController();
  final _cwlController = TextEditingController();
  final _splController = TextEditingController();
  final _decimalAgeController = TextEditingController();
  final List<int> gestationWeeks = List.generate(19, (index) => 41-index);

  @override
  void initState(){
    super.initState();
    _currentSex = widget.initialSex;
  }

  void _restart() {
    _splController.clear();
    _cllController.clear();
    _cwlController.clear();
    _decimalAgeController.clear();
    setState(() {
      _sdsString = '';
      _centileString = '';
      showScatterPoint = false;
      selectedGestationWeek = 40;
    });
  }

  void _calculateResult() {
    double inputValue;
    double sds;
    double centile;

    decimalAge = double.tryParse(_decimalAgeController.text) ?? 0;

    if (_currentSex == Sex.male){
      spl = double.tryParse(_splController.text) ?? 0;
      inputValue = spl;

      if (_neonateSelected[0]) {
        (sds, centile) = FetalSPLData.calculateSDSAndCentile(
            selectedGestationWeek, spl);
      } else {
        if (_ethnicityIsSelected[0]) {
          sds = PenileStatsCalculator.calculateStretchedPenileLengthSDS(
              measuredStretchedPenileLength: spl,
              decimalAgeYears: decimalAge,
              ethnicity: Ethnicity.Bulgarian);
        } else {
          sds = PenileStatsCalculator.calculateStretchedPenileLengthSDS(
              measuredStretchedPenileLength: spl,
              decimalAgeYears: decimalAge,
              ethnicity: Ethnicity.Indian);
        }
        centile = sdsToCentile(sds);

        setState(() {
          _sdsString = 'SDS: ${sds.toStringAsFixed(1)}';
          _centileString = 'Centile: ${centile.toStringAsFixed(1)}';
          showScatterPoint = true;
        });
      }

    } else {
      if (showCLL){
        cll = double.tryParse(_cllController.text) ?? 0;
        inputValue = cll;
        (sds, centile) = FetalCLLData.calculateSDSAndCentile(
            gestation: selectedGestationWeek, inputValue: inputValue, measurementType: CLLMeasurementType.length);
      } else {
        cwl = double.tryParse(_cwlController.text) ?? 0;
        inputValue = cwl;
        (sds, centile) = FetalCLLData.calculateSDSAndCentile(gestation: selectedGestationWeek, inputValue: inputValue, measurementType: CLLMeasurementType.width);
      }
      setState(() {
        _sdsString = 'SDS: ${sds.toStringAsFixed(1)}';
        _centileString = 'Centile: ${centile.toStringAsFixed(1)}';
        showScatterPoint = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine which input field and chart to show based on _currentSex
    bool isMale = _currentSex == Sex.male;

    Widget inputSpecificFields;
    Widget chartSpecificWidget;

    if (isMale) {
      inputSpecificFields = TextField(
        controller: _splController,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: _neonateSelected[0] ? 'SPL Neonate (cm)' : 'SPL Child (cm)',
        ),
      );
      if (_neonateSelected[0]) {
        chartSpecificWidget = FetalSPLChart(
          selectedGestationWeek: selectedGestationWeek,
          spl: spl,
          showScatterPoint: showScatterPoint,
        );
      } else {
        if (_ethnicityIsSelected[0]) {
          chartSpecificWidget = ChildBulgarianSPLChart(
            decimal_age: decimalAge,
            spl: spl,
            showScatterPoint: showScatterPoint,
          );
        } else {
          chartSpecificWidget = ChildIndianSPLChart(
              decimal_age: decimalAge,
              spl: spl,
              showScatterPoint: showScatterPoint
          );
        }
      }

    } else { // Female
      inputSpecificFields = Column(children: [
        if (showCLL)
          TextField(
              controller: _cllController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: _neonateSelected[0]
                    ? 'Clitoral Length Neonate (cm)'
                    : 'Clitoral Length Child (cm)',
              ))
        else
          TextField(
              controller: _cwlController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: _neonateSelected[0]
                    ? 'Clitoral Width Neonate (cm)'
                    : 'Clitoral Width Child (cm)',
              )),
        // Switch for CLL/CWL if applicable for females
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(showCLL
                  ? 'Showing Clitoral Length'
                  : 'Showing Clitoral Width'),
            Switch(
                value: showCLL,
                onChanged: (value) {
                  setState(() {
                    showCLL = value;
                    // Clear other input field when switching
                    if (showCLL) {
                      _cwlController.clear();
                      cwl = 0;
                    } else {
                      _cllController.clear();
                      cll = 0;
                    }
                    _sdsString = ''; // Clear results
                    _centileString = '';
                    showScatterPoint = false;
                  });
                },
            ),
          ],
        ),
      ]);
      // Use FetalCLLChart or a more general chart
      chartSpecificWidget = FetalCLLChart(
        selectedGestationWeek: selectedGestationWeek,
        cll: showCLL ? cll : cwl, // Pass correct value
        showScatterPoint: showScatterPoint,
        isWidth: !showCLL, // Pass if it's width or length
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Your new toggle for Neonate vs Child
            if (isMale)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ToggleButtons(
                      isSelected: _neonateSelected,
                      onPressed: (int index) {
                        setState(() {
                          for (int buttonIndex = 0; buttonIndex < _neonateSelected.length; buttonIndex++) {
                            if (buttonIndex == index) {
                              _neonateSelected[buttonIndex] = !_neonateSelected[buttonIndex];
                            } else {
                              _neonateSelected[buttonIndex] = false;
                            }
                          }
                        });
                      },
                      selectedBorderColor: Colors.blue,
                      selectedColor: Colors.blue,
                      children: [
                        SizedBox(width: (MediaQuery.of(context).size.width - 37)/2, child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[ SizedBox(width: 4.0), Text("Neonate", style: TextStyle(fontSize: 10),)],)),
                        SizedBox(width: (MediaQuery.of(context).size.width - 37)/2, child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[ SizedBox(width: 4.0), Text("Child",style: TextStyle(fontSize: 10),)],)),
                      ]
                  )
                ]),
            const SizedBox(height: 6),

            // Gestational Age Dropdown (Consider if this is always needed,
            // or if 'Child' mode uses a different input like age in months/years)
            if (_neonateSelected[0]) // Only show GA for neonates, or adapt for child
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(labelText: "Gestational Age (weeks)"),
                items: gestationWeeks.map((week) {
                  return DropdownMenuItem<int>(
                    value: week,
                    child: Text('$week'),
                  );
                }).toList(),
                onChanged: (int? newValue) {
                  setState(() {
                    selectedGestationWeek = newValue!;
                    _sdsString = ''; // Clear results
                    _centileString = '';
                    showScatterPoint = false;
                  });
                },
                value: selectedGestationWeek,
              )
            else
              if (_currentSex == Sex.male)
                Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    ToggleButtons(
                      isSelected: _ethnicityIsSelected,
                      onPressed: (int index) {
                      setState(() {
                        for (int buttonIndex = 0; buttonIndex < _ethnicityIsSelected.length; buttonIndex++) {
                          if (buttonIndex == index) {
                            _ethnicityIsSelected[buttonIndex] = !_ethnicityIsSelected[buttonIndex];
                          } else {
                            _ethnicityIsSelected[buttonIndex] = false;
                          }
                        }
                      });
                    },
                    selectedBorderColor: Colors.blue,
                    selectedColor: Colors.blue,
                    children: [
                      SizedBox(width: (MediaQuery.of(context).size.width - 37)/2, child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[ SizedBox(width: 4.0), Text("Bulgarian", style: TextStyle(fontSize: 14),)],)),
                      SizedBox(width: (MediaQuery.of(context).size.width - 37)/2, child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[ SizedBox(width: 4.0), Text("Indian",style: TextStyle(fontSize: 14),)],)),
                    ],
                  )
                ],
              ),
              if (_neonateSelected[0]==false)
                TextField(
                    controller: _decimalAgeController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'decimal age (years)',
                    )),
            const SizedBox(height: 6),
            inputSpecificFields, // Show SPL or CLL/CWL input
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                    child:ElevatedButton(
                      onPressed: _calculateResult,
                      child: const Text('Calculate'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightBlueAccent,
                      ),
                    ),
                ),
                Expanded(
                    child:ElevatedButton(
                      onPressed: _restart,
                      child: const Text('Restart'),
                    ),
                )
              ]
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
              Text(_sdsString,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: TextTheme.of(context).headlineSmall?.fontSize
                  )),
              const SizedBox(width: 10),
              Text(_centileString,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold, fontSize: TextTheme.of(context).headlineSmall?.fontSize
                  )),
              ]
            ),
            const SizedBox(height: 10),
            chartSpecificWidget, // Show correct chart
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