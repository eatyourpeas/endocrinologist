import 'package:endocrinologist/referencedata/saline_strengths.dart';
import 'package:flutter/material.dart';
import 'package:endocrinologist/classes/saline.dart';
import 'package:endocrinologist/calculations/salinecalculations.dart';
import 'package:endocrinologist/enums/enums.dart';
import 'package:flutter/services.dart';

class _SodiumPageState extends State<SodiumPage>{
  // Global key for form state
  final _formKey = GlobalKey<FormState>();
  bool _showInfoBox = true;

  Saline? _selectedSaline;
  final List<Saline> _salines = sortedSalineStrengths(saline_strengths);

  final _plasmaSodiumController = TextEditingController();
  final _totalBodyWaterController = TextEditingController();
  final _tbwAgeController = TextEditingController();
  final _tbwHeightController = TextEditingController();
  final _tbwWeightController = TextEditingController();

  // State for the switch and TBW calculation inputs
  bool _isTbwKnown = true; // Defaults to true, showing direct TBW input
  Sex _tbwSex = Sex.male; // Default sex for TBW calculation

  bool _canCalculate = false; // To control button enable state

  void _checkFormValidity() {
    bool isSalineSelected = _selectedSaline != null;
    bool isPlasmaSodiumValid = _plasmaSodiumController.text.isNotEmpty &&
        double.tryParse(_plasmaSodiumController.text) != null;

    bool isTbwSectionValid;
    if (_isTbwKnown) {
      isTbwSectionValid = _totalBodyWaterController.text.isNotEmpty &&
          double.tryParse(_totalBodyWaterController.text) != null;
    } else {
      isTbwSectionValid = _tbwAgeController.text.isNotEmpty &&
          double.tryParse(_tbwAgeController.text) != null &&
          _tbwHeightController.text.isNotEmpty &&
          double.tryParse(_tbwHeightController.text) != null &&
          _tbwWeightController.text.isNotEmpty &&
          double.tryParse(_tbwWeightController.text) != null;
      // _tbwSex is always valid as it's a SegmentedButton selection
    }

    bool allValidAndFilled =
        isSalineSelected && isPlasmaSodiumValid && isTbwSectionValid;

    if (allValidAndFilled != _canCalculate) {
      setState(() {
        _canCalculate = allValidAndFilled;
      });
    }
  }

  // Add initState and dispose for new controllers and listeners
  @override
  void initState() {
    super.initState();
    _plasmaSodiumController.addListener(_checkFormValidity);
    _totalBodyWaterController.addListener(_checkFormValidity);
    _tbwAgeController.addListener(_checkFormValidity);
    _tbwHeightController.addListener(_checkFormValidity);
    _tbwWeightController.addListener(_checkFormValidity);
    // Initial check
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkFormValidity());
  }

  @override
  void dispose() {
    _plasmaSodiumController.removeListener(_checkFormValidity);
    _totalBodyWaterController.removeListener(_checkFormValidity);
    _tbwAgeController.removeListener(_checkFormValidity);
    _tbwHeightController.removeListener(_checkFormValidity);
    _tbwWeightController.removeListener(_checkFormValidity);

    _plasmaSodiumController.dispose();
    _totalBodyWaterController.dispose();
    _tbwAgeController.dispose();
    _tbwHeightController.dispose();
    _tbwWeightController.dispose();
    super.dispose();
  }



  // In _SodiumPageState:

  void _submitForm() {
    // Always trigger validation before proceeding
    if (!(_formKey.currentState?.validate() ?? false)) {
      // If validation fails, ensure the button state reflects this.
      // _checkFormValidity might have already set it, but this is a safeguard.
      if (_canCalculate) {
        setState(() {
          _canCalculate = false;
        });
      }
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please correct errors in the form.')));
      return;
    }

    // At this point, _formKey.currentState.validate() has passed.
    // We can proceed with parsing, but tryParse is still good for robustness.

    double infusateSodiumConcentration;
    double plasmaSodium;
    double totalBodyWaterValue; // Renamed for clarity

    final selectedSalineMmol = _selectedSaline?.mmolperlitre;
    if (selectedSalineMmol == null) {
      // This should be caught by validator, but as a safeguard:
      _showErrorDialog("Input Error", "Please select a saline strength.");
      return;
    }
    infusateSodiumConcentration = selectedSalineMmol.toDouble();

    final parsedPlasmaSodium = double.tryParse(_plasmaSodiumController.text);
    if (parsedPlasmaSodium == null) {
      _showErrorDialog("Input Error", "Invalid plasma sodium value.");
      return;
    }
    plasmaSodium = parsedPlasmaSodium;

    if (_isTbwKnown) {
      final parsedDirectTbw = double.tryParse(_totalBodyWaterController.text);
      if (parsedDirectTbw == null || parsedDirectTbw <= 0) {
        _showErrorDialog("Input Error", "Invalid Total Body Water input.");
        return;
      }
      totalBodyWaterValue = parsedDirectTbw;
    } else {
      // Calculate TBW
      final double? age = double.tryParse(_tbwAgeController.text);
      final double? height = double.tryParse(_tbwHeightController.text);
      final double? weight = double.tryParse(_tbwWeightController.text);

      if (age == null || height == null || weight == null || age <= 0 || height <= 0 || weight <= 0) {
        _showErrorDialog("Input Error", "Invalid inputs for TBW calculation.");
        return;
      }
      // Assuming your totalBodyWaterUnderElevens is available and correctly imported
      totalBodyWaterValue = totalBodyWaterUnderElevens(
        age: age,
        height: height,
        weight: weight,
        sex: _tbwSex,
      );
      if (totalBodyWaterValue <= 0) {
        _showErrorDialog("Calculation Error", "Calculated Total Body Water is invalid. Please check inputs.");
        return;
      }
    }

    double deltaSodium = calculateDeltaSodium(
        infusateSodiumConcentration: infusateSodiumConcentration,
        plasmaSodium: plasmaSodium,
        totalBodyWater: totalBodyWaterValue); // Use totalBodyWaterValue

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Estimated Change in Sodium (mmol/L)"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!_isTbwKnown) // Show calculated TBW if it was calculated
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      "Calculated TBW: ${totalBodyWaterValue.toStringAsFixed(2)} L",
                      style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 13),
                    ),
                  ),
                Text(
                    "One litre of selected infusate should increase plasma sodium by ${deltaSodium.toStringAsFixed(2)} mmol/L"),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK"),
              )
            ],
          );
        });
  }

// Helper for error dialogs (if you don't have one already)
  Future<void> _showErrorDialog(String title, String message) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }

  String? _validateDecimalField(String? value, String fieldName, {double min = 0.01, double? max}) {
    if (value == null || value.isEmpty) {
      return "Enter $fieldName";
    }
    final double? val = double.tryParse(value);
    if (val == null) {
      return 'Invalid $fieldName (not a number)';
    }
    if (val < min) {
      return '$fieldName too low (min $min)';
    }
    if (max != null && val > max) {
      return '$fieldName too high (max $max)';
    }
    return null;
  }

  // In _SodiumPageState:

  void _resetForm() {
    _formKey.currentState?.reset(); // Resets validation state

    // Clear all text controllers
    _plasmaSodiumController.clear();
    _totalBodyWaterController.clear();
    _tbwAgeController.clear();
    _tbwHeightController.clear();
    _tbwWeightController.clear();

    setState(() {
      _selectedSaline = null; // Reset dropdown
      _isTbwKnown = true;     // Reset switch to default
      _tbwSex = Sex.male;     // Reset sex selector to default for TBW calc
      _canCalculate = false;  // Reset button enable state
      _showInfoBox = true;    // Optionally reset the info box visibility
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _formKey.currentState?.validate(); // Clear validation messages from now-empty fields
      _checkFormValidity(); // Recalculate button state based on empty form
    });
  }



  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
      // Close the keyboard if user taps anywhere outside the TextField
      FocusScope.of(context).unfocus();
    },
    child:
    SingleChildScrollView(
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey, autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
            Visibility(
              visible: _showInfoBox,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0), // Adjust padding
                  decoration: BoxDecoration(
                    color: Colors.lightBlueAccent[100],
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(
                      color: Colors.lightBlueAccent,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start, // Align items to the top
                    children: <Widget>[
                      // Info Icon (at the beginning)
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0, top: 2.0), // Adjust padding for alignment
                        child: Icon(
                          Icons.info_outline,
                          color: Colors.blue[700], // Choose a suitable color for the icon
                          size: 20,
                        ),
                      ),
                      // Your Text (takes up available space)
                      const Expanded(
                        child: Text(
                          'Calculate the expected rise in plasma sodium from a single litre of infusate.',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      // Close Icon (at the end)
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0), // Add some space before the close icon
                        child: InkWell( // Makes the icon clickable
                          onTap: () {
                            setState(() {
                              _showInfoBox = false; // Update state to hide the box
                            });
                          },
                          borderRadius: BorderRadius.circular(12), // Optional: for ripple effect shape
                          child: Icon(
                            Icons.close,
                            color: Colors.grey[700], // Choose a suitable color
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              child: DropdownButtonFormField<Saline>(
                menuMaxHeight: 200,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "fluid",
                ),
                validator: (value){
                  if (value == null) {
                    return "Please select a fluid type";
                  }
                  return null;
                },
                value: _selectedSaline,
                items: _salines.map((Saline saline) {
                  return DropdownMenuItem<Saline>(
                      value: saline,
                      child: SizedBox(
                        width: 300,
                        child:Text("${saline.name} (${saline.mmolperlitre} mmol/L)"),
                      )
                  );
                }).toList(),
                onChanged: (Saline? newValue) {
                  setState(() {
                    _selectedSaline = newValue;
                  });
                },
                hint: const Text('Select a saline strength'),
              ),
            ),
            const SizedBox(height: 16),
          TextFormField(
              controller: _plasmaSodiumController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
              validator: (value) => _validateDecimalField(value, 'plasma sodium', min: 80, max: 200), // Example range
              decoration: const InputDecoration(
                labelText: 'Plasma Sodium (mmol/L)',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => _checkFormValidity(),
            ),
            const SizedBox(height: 16),
              // TBW Known Switch
              SwitchListTile(
                title: const Text('Total Body Water (TBW) Known?'),
                value: _isTbwKnown,
                onChanged: (bool value) {
                  setState(() {
                    _isTbwKnown = value;
                    // Clear other fields if switching, and re-validate
                    if (_isTbwKnown) {
                      _tbwAgeController.clear();
                      _tbwHeightController.clear();
                      _tbwWeightController.clear();
                    } else {
                      _totalBodyWaterController.clear();
                    }
                    _formKey.currentState?.validate(); // Important to re-evaluate validation
                    _checkFormValidity(); // Update button state
                  });
                },
                activeColor: Theme.of(context).colorScheme.primary,
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 8),

              // Conditional TBW Input Fields
              if (_isTbwKnown)
                TextFormField(
                  controller: _totalBodyWaterController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                  validator: (value) {
                    if (!_isTbwKnown) return null; // Don't validate if hidden
                    return _validateDecimalField(value, 'total body water', min: 1, max: 100); // Example range
                  },
                  decoration: const InputDecoration(
                    labelText: 'Total Body Water (L)',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (_) => _checkFormValidity(),
                )
              else ...[
                // Inputs for TBW Calculation
                TextFormField(
                  controller: _tbwAgeController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                  validator: (value) {
                    if (_isTbwKnown) return null;
                    return _validateDecimalField(value, 'age (decimal years)', min: 0.01, max: 11); // Max 11 for this func
                  },
                  decoration: const InputDecoration(
                    labelText: 'Age (decimal years, <11)',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (_) => _checkFormValidity(),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _tbwHeightController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                  validator: (value) {
                    if (_isTbwKnown) return null;
                    return _validateDecimalField(value, 'height (cm)', min: 20, max: 200);
                  },
                  decoration: const InputDecoration(
                    labelText: 'Height (cm)',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (_) => _checkFormValidity(),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _tbwWeightController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                  validator: (value) {
                    if (_isTbwKnown) return null;
                    return _validateDecimalField(value, 'weight (kg)', min: 1, max: 150);
                  },
                  decoration: const InputDecoration(
                    labelText: 'Weight (kg)',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (_) => _checkFormValidity(),
                ),
                const SizedBox(height: 16),
                Text('Biological Sex (for TBW calc):', style: Theme.of(context).textTheme.bodyLarge),
                SegmentedButton<Sex>(
                  segments: const <ButtonSegment<Sex>>[
                    ButtonSegment<Sex>(
                        value: Sex.male,
                        label: Text('Male'),
                        icon: Icon(Icons.male)),
                    ButtonSegment<Sex>(
                        value: Sex.female,
                        label: Text('Female'),
                        icon: Icon(Icons.female)),
                  ],
                  selected: <Sex>{_tbwSex},
                  onSelectionChanged: (Set<Sex> newSelection) {
                    setState(() {
                      _tbwSex = newSelection.first;
                      _checkFormValidity(); // Potentially re-check if TBW calc depends on sex directly for validity ranges
                    });
                  },
                ),
              ],
              const SizedBox(height: 24),
              Row(
                children: <Widget>[
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reset Form'), // Changed label slightly for clarity
                      onPressed: _resetForm, // You'll need to create this method
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        textStyle: const TextStyle(fontSize: 16),
                        side: BorderSide(color: Theme.of(context).colorScheme.primary), // Optional: style reset button
                        foregroundColor: Theme.of(context).colorScheme.primary, // Text/icon color
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.calculate_outlined),
                      label: const Text('Calculate'), // Kept it short as "Calculate"
                      onPressed: _canCalculate ? _submitForm : null,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        textStyle: const TextStyle(fontSize: 16),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Theme.of(context).colorScheme.onPrimary,
                        disabledBackgroundColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.12), // Material 3 disable style
                        disabledForegroundColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.38), // Material 3 disable style
                      ),
                    ),
                  ),
                ],
              ),
          Padding( // You can keep the outer padding for spacing from other elements
            padding: const EdgeInsets.symmetric(vertical: 8.0), // Adjust vertical padding as needed
            child: Container(
              padding: const EdgeInsets.all(12.0), // Padding inside the colored box
              decoration: BoxDecoration(
                  color: Colors.amber[100], // A light amber/yellow for warning
                  borderRadius: BorderRadius.circular(8.0), // Optional: rounded corners
                  border: Border.all( // Optional: a thin border
                    color: Colors.amber[400]!,
                    width: 1,
                  )
              ),
              child: const Text(
                'Plasma sodium should rise by no more than 0.5 to 1.0 mmol/L per hour and by less than 10 to 12 mmol/L over the first 24 hours',
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black87, // Ensure text is readable on the background
                ),
              ),
            ),
          ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Reference: Baran D, Hutchinson TA. The outcome of hyponatremia in a general hospital population. Clin Nephrol. 1984;22:72–76.',
                textAlign: TextAlign.left,
                style: TextStyle(fontSize: 12),
              )),
          ]
        )
    )
    )
    ));
  }
}

class SodiumPage extends StatefulWidget {
  const SodiumPage({super.key});
  @override
  _SodiumPageState createState() => _SodiumPageState();
}