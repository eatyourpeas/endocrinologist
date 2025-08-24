import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:endocrinologist/enums/enums.dart';
import 'package:endocrinologist/calculations/twiii_height_prediction.dart';

class TWIIIHeightPredictionPage extends StatefulWidget {
  const TWIIIHeightPredictionPage({super.key});

  @override
  State<TWIIIHeightPredictionPage> createState() => _TWIIIHeightPredictionPageState();
}

class _TWIIIHeightPredictionPageState extends State<TWIIIHeightPredictionPage> {
  final _formKey = GlobalKey<FormState>();

  // Text Editing Controllers
  final TextEditingController _currentHeightController = TextEditingController();
  final TextEditingController _chronologicalAgeYearsController = TextEditingController();
  final TextEditingController _chronologicalAgeMonthsController = TextEditingController();
  final TextEditingController _rusBoneAgeYearsController = TextEditingController();
  final TextEditingController _rusBoneAgeMonthsController = TextEditingController();
  final TextEditingController _midParentalHeightController = TextEditingController();

  // State variables
  Sex _selectedSex = Sex.male;
  bool _isPostMenarcheal = false; // Default to premenarcheal or not applicable
  bool _canCalculate = false; // To control button enable state
  bool _useMidParentalHeight = false;

  @override
  void initState() {
    super.initState();
    // Add listeners to all controllers to check form validity
    _currentHeightController.addListener(_checkFormValidity);
    _chronologicalAgeYearsController.addListener(_checkFormValidity);
    _chronologicalAgeMonthsController.addListener(_checkFormValidity);
    _rusBoneAgeYearsController.addListener(_checkFormValidity);
    _rusBoneAgeMonthsController.addListener(_checkFormValidity);
    _midParentalHeightController.addListener(_checkFormValidity);
  }

  @override
  void dispose() {
    _currentHeightController.removeListener(_checkFormValidity);
    _chronologicalAgeYearsController.removeListener(_checkFormValidity);
    _chronologicalAgeMonthsController.removeListener(_checkFormValidity);
    _rusBoneAgeYearsController.removeListener(_checkFormValidity);
    _rusBoneAgeMonthsController.removeListener(_checkFormValidity);

    _currentHeightController.dispose();
    _chronologicalAgeYearsController.dispose();
    _chronologicalAgeMonthsController.dispose();
    _rusBoneAgeYearsController.dispose();
    _rusBoneAgeMonthsController.dispose();
    _midParentalHeightController.dispose();
    super.dispose();
  }

  void _checkFormValidity() {
    bool isChronAgeYearsValid = _chronologicalAgeYearsController.text.isNotEmpty && int.tryParse(_chronologicalAgeYearsController.text) != null;
    bool isChronAgeMonthsValid = _chronologicalAgeMonthsController.text.isNotEmpty && int.tryParse(_chronologicalAgeMonthsController.text) != null;
    bool isRusBoneAgeYearsValid = _rusBoneAgeYearsController.text.isNotEmpty && int.tryParse(_rusBoneAgeYearsController.text) != null;
    bool isRusBoneAgeMonthsValid = _rusBoneAgeMonthsController.text.isNotEmpty && int.tryParse(_rusBoneAgeMonthsController.text) != null;
    bool isHeightValid = _currentHeightController.text.isNotEmpty && double.tryParse(_currentHeightController.text) != null;
    bool isMidParentalHeightValid = true;

    if (_useMidParentalHeight) {
      isMidParentalHeightValid =
          _midParentalHeightController.text.isNotEmpty &&
              double.tryParse(_midParentalHeightController.text) != null;
    }

    // The menarcheal status toggle doesn't have a controller, its state is _isPostMenarcheal.
    // It's always "valid" in terms of input, its relevance is handled by the _selectedSex.

    bool allFieldsFilled = isHeightValid &&
        isChronAgeYearsValid &&
        isChronAgeMonthsValid &&
        isRusBoneAgeYearsValid &&
        isRusBoneAgeMonthsValid;

    if (allFieldsFilled != _canCalculate) {
      setState(() {
        _canCalculate = allFieldsFilled;
      });
    }
  }


  void _resetForm() {
    _formKey.currentState?.reset(); // Resets validation state
    _currentHeightController.clear();
    _chronologicalAgeYearsController.clear();
    _chronologicalAgeMonthsController.clear();
    _rusBoneAgeYearsController.clear();
    _rusBoneAgeMonthsController.clear();
    _midParentalHeightController.clear();
    setState(() {
      _selectedSex = Sex.male;
      _isPostMenarcheal = false;
      _useMidParentalHeight = false;
      _canCalculate = false; // Reset button state
    });
  }

  // Helper to convert years and months to decimal years
  double _convertToDecimalYears(String yearsStr, String monthsStr) {
    final int years = int.tryParse(yearsStr) ?? 0;
    final int months = int.tryParse(monthsStr) ?? 0;
    return years + (months / 12.0);
  }

  void _calculateHeight() {
    if (!_formKey.currentState!.validate()) {
      setState(() {
        _canCalculate = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please correct the errors in the form.')),
      );
      return;
    }

    final double height = double.parse(_currentHeightController.text);
    final double chronologicalAge = _convertToDecimalYears(
        _chronologicalAgeYearsController.text,
        _chronologicalAgeMonthsController.text);
    final double rusBoneAge = _convertToDecimalYears(
        _rusBoneAgeYearsController.text, _rusBoneAgeMonthsController.text);
    bool statusForCalculation =
    (_selectedSex == Sex.female) ? _isPostMenarcheal : false;

    double? midParentalHeightValue;
    if (_useMidParentalHeight) {
      midParentalHeightValue =
          double.tryParse(_midParentalHeightController.text);
      // Validator ensures it's not null if _useMidParentalHeight is true and field is filled
    }

    try {
      // Call the service, which now returns a record (double, double)
      final (double predicted, double predictedAdjusted) = predictAdultHeight( // Destructuring the record
        sex: _selectedSex,
        height: height,
        chronologicalAge: chronologicalAge,
        rusBoneAge: rusBoneAge,
        menarchealStatus: statusForCalculation,
        useMidParentalHeight: _useMidParentalHeight,
        midParentalHeight: midParentalHeightValue,
      );

      _showResultModal(
        predicted, // Pass the base prediction
        predictedAdjusted, // Pass the (potentially) adjusted prediction
        height,
        chronologicalAge,
        rusBoneAge,
        statusForCalculation,
        _useMidParentalHeight, // Pass the flag indicating if MPH was used
      );
    } catch (e) {
      _showErrorModal('Calculation Error: ${e.toString()}');
    }
  }

  // In _TWIIIHeightPredictionPageState:

  void _showResultModal(
      double basePredictedHeight, // The first value from the tuple
      double adjustedPredictedHeight, // The second value from the tuple
      double currentHeight,
      double ca,
      double ba,
      bool menarcheStatus,
      bool usedMph, // This flag tells us if the MPH adjustment was intended by the user
      ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('TWIII Predicted Adult Height'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Current Height: ${currentHeight.toStringAsFixed(1)} cm'),
                Text('Chronological Age: ${ca.toStringAsFixed(2)} yrs'),
                Text('RUS Bone Age: ${ba.toStringAsFixed(2)} yrs'),
                Text('Sex: ${_selectedSex == Sex.male ? "Male" : "Female"}'),
                if (_selectedSex == Sex.female)
                  Text(
                      'Menarcheal Status: ${_isPostMenarcheal ? "Post-menarcheal" : "Pre-menarcheal"}'),
                if (usedMph && _midParentalHeightController.text.isNotEmpty)
                  Text(
                      'Mid-parental Height: ${_midParentalHeightController.text} cm'),
                const SizedBox(height: 16),
                Text(
                  'Predicted Adult Height: ${basePredictedHeight.toStringAsFixed(1)} cm',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                // Conditionally display the adjusted height text
                // Only show if MPH was used AND the adjusted value is different from the base
                if (usedMph) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Predicted Adult Height (Adjusted for MPH): ${adjustedPredictedHeight.toStringAsFixed(1)} cm',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ]
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }


  void _showErrorModal(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }


  String? _validateYears(String? value) {
    if (value == null || value.isEmpty) return 'Enter years';
    final int? years = int.tryParse(value);
    if (years == null || years < 0) return 'Invalid';
    // Add upper bound if necessary, e.g., years > 25
    return null;
  }

  String? _validateMonths(String? value) {
    if (value == null || value.isEmpty) return 'Enter mths';
    final int? months = int.tryParse(value);
    if (months == null || months < 0 || months >= 12) return '0-11';
    return null;
  }

  String? _validateMidParentalHeight(String? value) {
    if (_useMidParentalHeight) {
      // Only validate if the toggle is on
      if (value == null || value.isEmpty) {
        return 'Enter mid-parental height';
      }
      final double? height = double.tryParse(value);
      if (height == null || height <= 50 || height > 250) { // Example realistic range
        return 'Invalid (50-250 cm)';
      }
    }
    return null; // No error if not used or if valid
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TW-III Height Prediction'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction, // Validate as user interacts
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Sex Toggle
              Text('Biological Sex:', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              SegmentedButton<Sex>(
                segments: const <ButtonSegment<Sex>>[
                  ButtonSegment<Sex>(value: Sex.male, label: Text('Male'), icon: Icon(Icons.male)),
                  ButtonSegment<Sex>(value: Sex.female, label: Text('Female'), icon: Icon(Icons.female)),
                ],
                selected: <Sex>{_selectedSex},
                onSelectionChanged: (Set<Sex> newSelection) {
                  setState(() {
                    _selectedSex = newSelection.first;
                    if (_selectedSex == Sex.male) {
                      _isPostMenarcheal = false; // Reset if switching to male
                    }
                    _checkFormValidity(); // Re-check validity when sex changes
                  });
                },
              ),
              const SizedBox(height: 16),

              // Menarcheal Status (Conditional)
              if (_selectedSex == Sex.female) ...[
                Text('Menarcheal Status:', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                SegmentedButton<bool>(
                  segments: const <ButtonSegment<bool>>[
                    ButtonSegment<bool>(value: false, label: Text('Pre-menarcheal')),
                    ButtonSegment<bool>(value: true, label: Text('Post-menarcheal')),
                  ],
                  selected: <bool>{_isPostMenarcheal},
                  onSelectionChanged: (Set<bool> newSelection) {
                    setState(() {
                      _isPostMenarcheal = newSelection.first;
                      _checkFormValidity(); // This field doesn't have a controller, but its state matters
                    });
                  },
                ),
                const SizedBox(height: 16),
              ],

              // Current Height
              TextFormField(
                controller: _currentHeightController,
                decoration: const InputDecoration(
                  labelText: 'Current Height (cm)',
                  hintText: 'e.g., 120.5',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.height),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Enter height';
                  final double? height = double.tryParse(value);
                  if (height == null || height <= 0) return 'Invalid height';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Chronological Age
              Text('Chronological Age:', style: Theme.of(context).textTheme.titleMedium),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _chronologicalAgeYearsController,
                      decoration: const InputDecoration(labelText: 'Years', border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(2)],
                      validator: _validateYears,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _chronologicalAgeMonthsController,
                      decoration: const InputDecoration(labelText: 'Months', border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(2)],
                      validator: _validateMonths,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // RUS Bone Age
              Text('RUS TWIII Bone Age:', style: Theme.of(context).textTheme.titleMedium),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _rusBoneAgeYearsController,
                      decoration: const InputDecoration(labelText: 'Years', border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(2)],
                      validator: _validateYears,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _rusBoneAgeMonthsController,
                      decoration: const InputDecoration(labelText: 'Months', border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(2)],
                      validator: _validateMonths,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16), // Spacing before MPH toggle

              // Mid-parental Height Toggle and Input
              SwitchListTile(
                title: const Text('Adjust for Mid-parental Height'),
                value: _useMidParentalHeight,
                onChanged: (bool value) {
                  setState(() {
                    _useMidParentalHeight = value;
                    if (!_useMidParentalHeight) {
                      _midParentalHeightController.clear(); // Clear if toggled off
                    }
                    // Crucial: Re-validate the form when toggle changes,
                    // especially to trigger validation of MPH field if it becomes visible and required.
                    _formKey.currentState?.validate();
                    _checkFormValidity(); // Update button state
                  });
                },
                activeColor: Theme.of(context).colorScheme.primary,
                contentPadding: const EdgeInsets.symmetric(horizontal: 0), // Adjust padding
              ),
              // Conditionally display the Mid-parental Height TextFormField
              if (_useMidParentalHeight) ...[
                const SizedBox(height: 8),
                TextFormField(
                  controller: _midParentalHeightController,
                  decoration: const InputDecoration(
                    labelText: 'Mid-parental Height (cm)',
                    hintText: 'e.g., 170.0',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.family_restroom),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))
                  ],
                  validator: _validateMidParentalHeight, // Use the new validator
                ),
              ],
              const SizedBox(height: 32), // Spacing before buttons

              // Action Buttons
              Row(
                children: <Widget>[
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reset'),
                      onPressed: _resetForm,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.calculate_outlined),
                      label: const Text('Calculate'),
                      onPressed: _canCalculate ? _calculateHeight : null, // Enable/disable button
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        textStyle: const TextStyle(fontSize: 16),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Theme.of(context).colorScheme.onPrimary,
                        disabledBackgroundColor: Colors.grey[300], // Style for disabled button
                        disabledForegroundColor: Colors.grey[700],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8.0),
              const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Prediction of adult height from height, bone age, and occurrence ofmenarche, at ages 4 to 16 with allowance for midparent height, J. M. TANNER, R. H. WHITEHOUSE, W. A. MARSHALL, and B. S. CARTER, From the Department of Growth and Development, Institute of Child Health, University of London',
                    textAlign: TextAlign.left,
                    style: TextStyle(fontSize: 12),
                  )),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
