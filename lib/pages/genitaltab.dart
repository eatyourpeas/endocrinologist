
import 'package:endocrinologist/calculations/cllpretermnormativevalues.dart';
import 'package:endocrinologist/pages/childbulgariansplchart.dart';
import 'package:endocrinologist/pages/childindiansplchart.dart';
import 'package:endocrinologist/pages/fetalsplchart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final _formKey = GlobalKey<FormState>();
  late Sex _currentSex;
  AgeGroup _selectedAgeGroup = AgeGroup.neonate;
  Ethnicity _selectedEthnicity = Ethnicity.Bulgarian;
  int selectedGestationWeek = 40; // Initial value
  String _sdsString = '';
  String _centileString = '';
  double spl = 0; // Stretched Penile length
  double cll = 0; // Clitoral Length
  double cwl = 0; // Clitoral Width
  bool showScatterPoint=false;
  bool showCLL = false;

  double decimalAge = 0.0;


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

  @override
  void didUpdateWidget(GenitalTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Check if the initialSex passed from the parent has actually changed
    if (widget.initialSex != oldWidget.initialSex) {
      setState(() {
        _currentSex = widget.initialSex; // Update the internal state
        _restart();
      });
    }
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

    if (_currentSex == Sex.male) {
      spl = double.tryParse(_splController.text) ?? 0;
      inputValue = spl;

      if (_selectedAgeGroup == AgeGroup.neonate) { // Updated condition
        (sds, centile) = FetalSPLData.calculateSDSAndCentile(
            selectedGestationWeek, spl);
      } else { // Child
        // Ensure you have an Ethnicity enum defined in your calculations
        // For example, in PenileStatsCalculator.calculateStretchedPenileLengthSDS
        Ethnicity calculationEthnicity = _selectedEthnicity == Ethnicity.Bulgarian
            ? Ethnicity.Bulgarian // Make sure this matches your enum in calculations
            : Ethnicity.Indian;  // Make sure this matches your enum in calculations

        sds = PenileStatsCalculator.calculateStretchedPenileLengthSDS(
            measuredStretchedPenileLength: spl,
            decimalAgeYears: decimalAge,
            ethnicity: calculationEthnicity); // Use the mapped ethnicity
        centile = sdsToCentile(sds);
      }
      setState(() {
        _sdsString = 'SDS: ${sds.toStringAsFixed(1)}';
        _centileString = 'Centile: ${centile.toStringAsFixed(1)}';
        showScatterPoint = true;
      });

    } else { // Female
      if (_selectedAgeGroup == AgeGroup.neonate) {
        if (showCLL) {
          cll = double.tryParse(_cllController.text) ?? 0;
          inputValue = cll;
          (sds, centile) = FetalCLLData.calculateSDSAndCentile(
              gestation: selectedGestationWeek,
              inputValue: inputValue,
              measurementType: CLLMeasurementType.length);
        } else {
          cwl = double.tryParse(_cwlController.text) ?? 0;
          inputValue = cwl;
          (sds, centile) = FetalCLLData.calculateSDSAndCentile(
              gestation: selectedGestationWeek,
              inputValue: inputValue,
              measurementType: CLLMeasurementType.width);
        }
        setState(() {
          _sdsString = 'SDS: ${sds.toStringAsFixed(1)}';
          _centileString = 'Centile: ${centile.toStringAsFixed(1)}';
          showScatterPoint = true;
        });
      } else { // Child (Female) - Placeholder if you add this later
        setState(() {
          _sdsString = 'Child calculations for females not implemented yet.';
          _centileString = '';
          showScatterPoint = false;
        });
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    bool isMale = _currentSex == Sex.male;
    // Determine which input field and chart to show based on _currentSex and _selectedAgeGroup
    Widget inputSpecificFields;
    Widget chartSpecificWidget;

    if (isMale) {
      inputSpecificFields = TextField(
        controller: _splController,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: _selectedAgeGroup == AgeGroup.neonate ? 'SPL Neonate (cm)' : 'SPL Child (cm)',
          border: const OutlineInputBorder(), // Added for consistency
        ),
      );
      if (_selectedAgeGroup == AgeGroup.neonate) {
        chartSpecificWidget = FetalSPLChart(
          selectedGestationWeek: selectedGestationWeek,
          spl: spl,
          showScatterPoint: showScatterPoint,
        );
      } else { // Child Male
        if (_selectedEthnicity == Ethnicity.Bulgarian) {
          chartSpecificWidget = ChildBulgarianSPLChart(
            decimal_age: decimalAge,
            spl: spl,
            showScatterPoint: showScatterPoint,
          );
        } else { // Indian
          chartSpecificWidget = ChildIndianSPLChart(
              decimal_age: decimalAge,
              spl: spl,
              showScatterPoint: showScatterPoint
          );
        }
      }
    } else { // Female
      // The original code only shows CLL/CWL inputs for neonates.
      // If female children also need these inputs, you'll need to adjust this.
      if (_selectedAgeGroup == AgeGroup.neonate) {
        inputSpecificFields = Column(children: [
          if (showCLL)
            TextField(
                controller: _cllController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Clitoral Length Neonate (cm)',
                  border: const OutlineInputBorder(),
                ))
          else
            TextField(
                controller: _cwlController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Clitoral Width Neonate (cm)',
                  border: const OutlineInputBorder(),
                )),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(showCLL ? 'Showing Clitoral Length' : 'Showing Clitoral Width'),
              Switch(
                value: showCLL,
                onChanged: (value) {
                  setState(() {
                    showCLL = value;
                    if (showCLL) {
                      _cwlController.clear();
                      cwl = 0;
                    } else {
                      _cllController.clear();
                      cll = 0;
                    }
                    _sdsString = '';
                    _centileString = '';
                    showScatterPoint = false;
                  });
                },
              ),
            ],
          ),
        ]);
        chartSpecificWidget = FetalCLLChart(
          selectedGestationWeek: selectedGestationWeek,
          cll: showCLL ? cll : cwl,
          showScatterPoint: showScatterPoint,
          isWidth: !showCLL,
        );
      } else { // Child Female - Placeholder or specific UI
        inputSpecificFields = const Center(child: Text("Genital measurements for female children not yet implemented."));
        chartSpecificWidget = const SizedBox.shrink(); // No chart or placeholder
        _sdsString = '';
        _centileString = '';
        showScatterPoint = false;
      }
    }
    // --- End of logic for inputSpecificFields and chartSpecificWidget ----


    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch, // To make SegmentedButtons take full width
            children: [
              // Age Group Toggle (Neonate vs Child)
              SegmentedButton<AgeGroup>(
                segments: const <ButtonSegment<AgeGroup>>[
                  ButtonSegment<AgeGroup>(
                      value: AgeGroup.neonate,
                      label: Text('Neonate'),
                      icon: Icon(Icons.baby_changing_station)), // Example Icon
                  ButtonSegment<AgeGroup>(
                      value: AgeGroup.child,
                      label: Text('Child'),
                      icon: Icon(Icons.child_care)), // Example Icon
                ],
                selected: <AgeGroup>{_selectedAgeGroup},
                onSelectionChanged: (Set<AgeGroup> newSelection) {
                  setState(() {
                    _selectedAgeGroup = newSelection.first;
                    // Clear dependent fields and results when changing age group
                    _decimalAgeController.clear();
                    selectedGestationWeek = 40; // Reset to default or last used
                    _sdsString = '';
                    _centileString = '';
                    showScatterPoint = false;
                    // If switching to neonate, clear ethnicity selection if it's only for child
                    if (_selectedAgeGroup == AgeGroup.neonate) {
                      _selectedEthnicity = Ethnicity.Bulgarian; // Reset if needed
                    }
                  });
                },
                // Default styling of SegmentedButton already has rounded corners
                // and generally handles sizing well.
              ),
              const SizedBox(height: 16), // Increased spacing

              // Conditional Fields based on AgeGroup and Sex
              if (_selectedAgeGroup == AgeGroup.neonate)
                DropdownButtonFormField<int>(
                  decoration: const InputDecoration(
                    labelText: "Gestational Age (weeks)",
                    border: OutlineInputBorder(), // Added for consistency
                  ),
                  items: gestationWeeks.map((week) {
                    return DropdownMenuItem<int>(
                      value: week,
                      child: Text('$week'),
                    );
                  }).toList(),
                  onChanged: (int? newValue) {
                    if (newValue != null) {
                      setState(() {
                        selectedGestationWeek = newValue;
                        _sdsString = '';
                        _centileString = '';
                        showScatterPoint = false;
                      });
                    }
                  },
                  value: selectedGestationWeek,
                )
              else if (_selectedAgeGroup == AgeGroup.child) ...[ // Using '...' collection-if
                // Ethnicity Toggle (Only for Male Children)
                if (isMale) ...[ // Show ethnicity only for male children
                  Text("Ethnicity (for Child SPL):", style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 8),
                  SegmentedButton<Ethnicity>(
                    segments: const <ButtonSegment<Ethnicity>>[
                      ButtonSegment<Ethnicity>(
                          value: Ethnicity.Bulgarian,
                          label: Text('Bulgarian')),
                      ButtonSegment<Ethnicity>(
                          value: Ethnicity.Indian,
                          label: Text('Indian')),
                    ],
                    selected: <Ethnicity>{_selectedEthnicity},
                    onSelectionChanged: (Set<Ethnicity> newSelection) {
                      setState(() {
                        _selectedEthnicity = newSelection.first;
                        _sdsString = ''; // Clear results on ethnicity change
                        _centileString = '';
                        showScatterPoint = false;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                ],
                // Decimal Age input (for Children of both sexes, if applicable)
                TextFormField(
                  controller: _decimalAgeController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                  decoration: const InputDecoration(
                    labelText: 'Decimal Age (years)',
                    hintText: 'e.g., 2.5 for 2 years 6 months',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value){ // Add validator if needed
                    if (value == null || value.isEmpty) return 'Please enter age.';
                    if (double.tryParse(value) == null || double.parse(value) < 0) return 'Invalid age.';
                    return null;
                  },
                ),
              ],
              const SizedBox(height: 16), // Increased spacing

              inputSpecificFields,
              const SizedBox(height: 20), // Increased spacing

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon( // Added icon for consistency
                      icon: const Icon(Icons.calculate_outlined),
                      onPressed: _calculateResult,
                      label: const Text('Calculate'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary, // Use theme color
                        foregroundColor: Theme.of(context).colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton.icon( // Changed to OutlinedButton for visual difference
                      icon: const Icon(Icons.refresh),
                      onPressed: _restart,
                      label: const Text('Restart'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 16), // Increased spacing

              if (_sdsString.isNotEmpty || _centileString.isNotEmpty) // Show only if there are results
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(_sdsString,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: Theme.of(context).textTheme.titleLarge?.fontSize // Using theme for font size
                        )),
                    const SizedBox(width: 16), // Increased spacing
                    Text(_centileString,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: Theme.of(context).textTheme.titleLarge?.fontSize
                        )),
                  ],
                ),
              const SizedBox(height: 10),
              chartSpecificWidget,
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _cllController.dispose();
    _cwlController.dispose();
    _splController.dispose();
    _decimalAgeController.dispose(); // Make sure this is disposed
    super.dispose();
  }
}