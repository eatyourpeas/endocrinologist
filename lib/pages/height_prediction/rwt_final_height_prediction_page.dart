import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:endocrinologist/enums/enums.dart';
import 'package:endocrinologist/calculations/rwt_final_height_service.dart';

class RWTPredictionPage extends StatefulWidget {
  const RWTPredictionPage({super.key});

  @override
  State<RWTPredictionPage> createState() => _RWTPredictionPageState();
}

class _RWTPredictionPageState extends State<RWTPredictionPage> {
  final _formKey = GlobalKey<FormState>();
  final RWTFinalHeightPredictionService _heightPredictionService = RWTFinalHeightPredictionService();

  // Text Editing Controllers
  final TextEditingController _currentHeightController = TextEditingController();
  final TextEditingController _ageDecimalYearsController = TextEditingController();
  final TextEditingController _weightKgController = TextEditingController();
  final TextEditingController _boneAgeDecimalYearsController = TextEditingController();
  final TextEditingController _midparentalHeightController = TextEditingController();

  // State variables
  Sex _selectedSex = Sex.male;
  bool _canCalculate = false;

  // To store the result
  double? _predictedHeightResult;

  @override
  void initState() {
    super.initState();
    // Add listeners to all controllers to check form validity
    _currentHeightController.addListener(_checkFormValidity);
    _ageDecimalYearsController.addListener(_checkFormValidity);
    _weightKgController.addListener(_checkFormValidity);
    _boneAgeDecimalYearsController.addListener(_checkFormValidity);
    _midparentalHeightController.addListener(_checkFormValidity);
  }

  @override
  void dispose() {
    _currentHeightController.removeListener(_checkFormValidity);
    _ageDecimalYearsController.removeListener(_checkFormValidity);
    _weightKgController.removeListener(_checkFormValidity);
    _boneAgeDecimalYearsController.removeListener(_checkFormValidity);
    _midparentalHeightController.removeListener(_checkFormValidity);

    _currentHeightController.dispose();
    _ageDecimalYearsController.dispose();
    _weightKgController.dispose();
    _boneAgeDecimalYearsController.dispose();
    _midparentalHeightController.dispose();
    super.dispose();
  }

  void _checkFormValidity() {
    // Basic check for non-empty. Actual validation rules are in TextFormField validators.
    bool allFieldsFilled = _currentHeightController.text.isNotEmpty &&
        _ageDecimalYearsController.text.isNotEmpty &&
        _weightKgController.text.isNotEmpty &&
        _boneAgeDecimalYearsController.text.isNotEmpty &&
        _midparentalHeightController.text.isNotEmpty;

    if (allFieldsFilled != _canCalculate) {
      setState(() {
        _canCalculate = allFieldsFilled;
      });
    }
  }

  void _resetForm() {
    _formKey.currentState?.reset(); // Resets validation state
    _currentHeightController.clear();
    _ageDecimalYearsController.clear();
    _weightKgController.clear();
    _boneAgeDecimalYearsController.clear();
    _midparentalHeightController.clear();
    setState(() {
      _selectedSex = Sex.male;
      _canCalculate = false;
      _predictedHeightResult = null; // Clear previous result
    });
    // Explicitly re-validate after reset if you want errors to clear immediately
    // or rely on user interaction if autovalidateMode is onUserInteraction.
    // _formKey.currentState?.validate(); // Optional: force revalidation
  }

  void _calculateHeight() {
    // First, validate the form.
    if (!_formKey.currentState!.validate()) {
      // If form is not valid, ensure button reflects this (though _checkFormValidity should also do it)
      setState(() {
        _canCalculate = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please correct the errors in the form before calculating.')),
      );
      return;
    }

    // If form is valid, parse the values
    final double currentHeight = double.parse(_currentHeightController.text);
    final double ageDecimal = double.parse(_ageDecimalYearsController.text);
    final double weight = double.parse(_weightKgController.text);
    final double boneAgeDecimal = double.parse(_boneAgeDecimalYearsController.text);
    final double midparentalHeight = double.parse(_midparentalHeightController.text);

    try {
      final double estimatedHeight = _heightPredictionService.estimateFinalAdultHeight(
        currentHeightCm: currentHeight,
        ageDecimalYears: ageDecimal,
        weightKg: weight,
        boneAgeDecimalYears: boneAgeDecimal,
        midparentalHeightCm: midparentalHeight,
        sex: _selectedSex,
      );
      setState(() {
        _predictedHeightResult = estimatedHeight;
      });
      _showResultModal(estimatedHeight, currentHeight, ageDecimal, weight, boneAgeDecimal, midparentalHeight);
    } catch (e) {
      _showErrorModal('Calculation Error: ${e.toString()}');
      setState(() {
        _predictedHeightResult = null;
      });
    }
  }

  void _showResultModal(double predictedHeight, double currentH, double ageD, double w, double boneAgeD, double mph) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('RWT Predicted Adult Height'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Sex: ${_selectedSex == Sex.male ? "Male" : "Female"}'),
                Text('Current Height: ${currentH.toStringAsFixed(1)} cm'),
                Text('Age: ${ageD.toStringAsFixed(1)} years'),
                Text('Weight: ${w.toStringAsFixed(1)} kg'),
                Text('Bone Age: ${boneAgeD.toStringAsFixed(1)} years'),
                Text('Mid-parental Height: ${mph.toStringAsFixed(1)} cm'),
                const SizedBox(height: 16),
                Text(
                  'Predicted Adult Height: ${predictedHeight.toStringAsFixed(1)} cm',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
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

  // Validator for decimal inputs (height, weight, etc.)
  String? _validateDecimal(String? value, String fieldName, {double min = 0.01}) {
    if (value == null || value.isEmpty) return 'Enter $fieldName';
    final double? val = double.tryParse(value);
    if (val == null || val < min) return 'Invalid $fieldName (must be >= $min)';
    return null;
  }

  // Validator for age with sex-specific upper limits
  String? _validateAge(String? value) {
    if (value == null || value.isEmpty) return 'Enter age';
    final double? age = double.tryParse(value);
    if (age == null || age <= 0) return 'Invalid age';

    if (_selectedSex == Sex.female && age > 14) {
      return 'Age for females cannot exceed 14 years for this model';
    }
    if (_selectedSex == Sex.male && age > 16) {
      return 'Age for males cannot exceed 16 years for this model';
    }
    return null;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RWT Height Prediction'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
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
                    // Important: Force re-validation of age field when sex changes
                    _formKey.currentState?.validate();
                    _checkFormValidity();
                  });
                },
              ),
              const SizedBox(height: 16),

              // Current Height
              TextFormField(
                controller: _currentHeightController,
                decoration: const InputDecoration(
                  labelText: 'Current Height (cm)',
                  hintText: 'e.g., 150.5',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.height),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                validator: (value) => _validateDecimal(value, 'height'),
              ),
              const SizedBox(height: 16),

              // Age (Decimal Years)
              TextFormField(
                controller: _ageDecimalYearsController,
                decoration: const InputDecoration(
                  labelText: 'Current Age (decimal years)',
                  hintText: 'e.g., 12.5',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                validator: _validateAge, // Uses sex-specific validation
              ),
              const SizedBox(height: 16),

              // Weight (kg)
              TextFormField(
                controller: _weightKgController,
                decoration: const InputDecoration(
                  labelText: 'Weight (kg)',
                  hintText: 'e.g., 45.0',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.scale),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                validator: (value) => _validateDecimal(value, 'weight'),
              ),
              const SizedBox(height: 16),

              // Bone Age (Decimal Years)
              TextFormField(
                controller: _boneAgeDecimalYearsController,
                decoration: const InputDecoration(
                  labelText: 'Bone Age (decimal years)',
                  hintText: 'e.g., 11.0',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.science_outlined), // Example icon for bone age
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                validator: (value) => _validateDecimal(value, 'bone age'),
              ),
              const SizedBox(height: 16),

              // Mid-parental Height (cm)
              TextFormField(
                controller: _midparentalHeightController,
                decoration: const InputDecoration(
                  labelText: 'Mid-parental Height (cm)',
                  hintText: 'e.g., 170.0',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.family_restroom),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                validator: (value) => _validateDecimal(value, 'mid-parental height'),
              ),
              const SizedBox(height: 32),

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
                      onPressed: _canCalculate ? _calculateHeight : null,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        textStyle: const TextStyle(fontSize: 16),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Theme.of(context).colorScheme.onPrimary,
                        disabledBackgroundColor: Colors.grey[300],
                        disabledForegroundColor: Colors.grey[700],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
