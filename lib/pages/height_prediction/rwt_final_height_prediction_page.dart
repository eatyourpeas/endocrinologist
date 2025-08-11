import 'package:endocrinologist/calculations/rwt_final_height_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:endocrinologist/enums/enums.dart';

class RWTPredictionPage extends StatefulWidget {
  const RWTPredictionPage({super.key});

  @override
  State<RWTPredictionPage> createState() => _RWTPredictionPageState();
}

class _RWTPredictionPageState extends State<RWTPredictionPage> {
  final _formKey = GlobalKey<FormState>();
  final RWTFinalHeightPredictionService _heightPredictionService =
  RWTFinalHeightPredictionService();

  // Text Editing Controllers
  final TextEditingController _currentHeightController = TextEditingController();
  final TextEditingController _weightKgController = TextEditingController();
  final TextEditingController _midparentalHeightController = TextEditingController();

  // Controllers for Chronological Age
  final TextEditingController _chronoAgeDecimalYearsController = TextEditingController();
  final TextEditingController _chronoAgeYearsController = TextEditingController();
  final TextEditingController _chronoAgeMonthsController = TextEditingController();

  // Controllers for Bone Age
  final TextEditingController _boneAgeDecimalYearsController = TextEditingController();
  final TextEditingController _boneAgeYearsController = TextEditingController();
  final TextEditingController _boneAgeMonthsController = TextEditingController();


  // State variables
  Sex _selectedSex = Sex.male;
  AgeInputMode _chronoAgeInputMode = AgeInputMode.decimal; // Default to decimal
  AgeInputMode _boneAgeInputMode = AgeInputMode.decimal;   // Default to decimal
  bool _canCalculate = false;

  double? _predictedHeightResult;

  @override
  void initState() {
    super.initState();
    // Add listeners
    _currentHeightController.addListener(_checkFormValidity);
    _weightKgController.addListener(_checkFormValidity);
    _midparentalHeightController.addListener(_checkFormValidity);

    _chronoAgeDecimalYearsController.addListener(_checkFormValidity);
    _chronoAgeYearsController.addListener(_checkFormValidity);
    _chronoAgeMonthsController.addListener(_checkFormValidity);

    _boneAgeDecimalYearsController.addListener(_checkFormValidity);
    _boneAgeYearsController.addListener(_checkFormValidity);
    _boneAgeMonthsController.addListener(_checkFormValidity);
  }

  @override
  void dispose() {
    // Remove listeners and dispose controllers
    _currentHeightController.removeListener(_checkFormValidity);
    _weightKgController.removeListener(_checkFormValidity);
    _midparentalHeightController.removeListener(_checkFormValidity);
    _chronoAgeDecimalYearsController.removeListener(_checkFormValidity);
    _chronoAgeYearsController.removeListener(_checkFormValidity);
    _chronoAgeMonthsController.removeListener(_checkFormValidity);
    _boneAgeDecimalYearsController.removeListener(_checkFormValidity);
    _boneAgeYearsController.removeListener(_checkFormValidity);
    _boneAgeMonthsController.removeListener(_checkFormValidity);

    _currentHeightController.dispose();
    _weightKgController.dispose();
    _midparentalHeightController.dispose();
    _chronoAgeDecimalYearsController.dispose();
    _chronoAgeYearsController.dispose();
    _chronoAgeMonthsController.dispose();
    _boneAgeDecimalYearsController.dispose();
    _boneAgeYearsController.dispose();
    _boneAgeMonthsController.dispose();
    super.dispose();
  }

  void _checkFormValidity() {
    bool isChronoAgeValid = false;
    if (_chronoAgeInputMode == AgeInputMode.decimal) {
      isChronoAgeValid = _chronoAgeDecimalYearsController.text.isNotEmpty;
    } else {
      isChronoAgeValid = _chronoAgeYearsController.text.isNotEmpty &&
          _chronoAgeMonthsController.text.isNotEmpty;
    }

    bool isBoneAgeValid = false;
    if (_boneAgeInputMode == AgeInputMode.decimal) {
      isBoneAgeValid = _boneAgeDecimalYearsController.text.isNotEmpty;
    } else {
      isBoneAgeValid = _boneAgeYearsController.text.isNotEmpty &&
          _boneAgeMonthsController.text.isNotEmpty;
    }

    bool allFieldsFilled = _currentHeightController.text.isNotEmpty &&
        _weightKgController.text.isNotEmpty &&
        _midparentalHeightController.text.isNotEmpty &&
        isChronoAgeValid &&
        isBoneAgeValid;

    if (allFieldsFilled != _canCalculate) {
      setState(() {
        _canCalculate = allFieldsFilled;
      });
    }
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _currentHeightController.clear();
    _weightKgController.clear();
    _midparentalHeightController.clear();

    _chronoAgeDecimalYearsController.clear();
    _chronoAgeYearsController.clear();
    _chronoAgeMonthsController.clear();

    _boneAgeDecimalYearsController.clear();
    _boneAgeYearsController.clear();
    _boneAgeMonthsController.clear();

    setState(() {
      _selectedSex = Sex.male;
      _chronoAgeInputMode = AgeInputMode.decimal;
      _boneAgeInputMode = AgeInputMode.decimal;
      _canCalculate = false;
      _predictedHeightResult = null;
    });
    // Force re-validation to clear errors from now-hidden fields if necessary
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _formKey.currentState?.validate();
    });
  }

  // Helper to convert years and months string to decimal years
  double _convertYearsMonthsToDecimal(String yearsStr, String monthsStr) {
    final int years = int.tryParse(yearsStr) ?? 0;
    final int months = int.tryParse(monthsStr) ?? 0;
    return years + (months / 12.0);
  }

  void _calculateHeight() {
    if (!_formKey.currentState!.validate()) {
      setState(() { _canCalculate = false; });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please correct the errors in the form.')),
      );
      return;
    }

    final double currentHeight = double.parse(_currentHeightController.text);
    final double weight = double.parse(_weightKgController.text);
    final double midparentalHeight = double.parse(_midparentalHeightController.text);

    double ageDecimal;
    if (_chronoAgeInputMode == AgeInputMode.decimal) {
      ageDecimal = double.parse(_chronoAgeDecimalYearsController.text);
    } else {
      ageDecimal = _convertYearsMonthsToDecimal(
          _chronoAgeYearsController.text, _chronoAgeMonthsController.text);
    }

    double boneAgeDecimal;
    if (_boneAgeInputMode == AgeInputMode.decimal) {
      boneAgeDecimal = double.parse(_boneAgeDecimalYearsController.text);
    } else {
      boneAgeDecimal = _convertYearsMonthsToDecimal(
          _boneAgeYearsController.text, _boneAgeMonthsController.text);
    }

    try {
      final double estimatedHeight =
      _heightPredictionService.estimateFinalAdultHeight(
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
                Text('Age: ${ageD.toStringAsFixed(1)} years'), // Displayed as decimal
                Text('Weight: ${w.toStringAsFixed(1)} kg'),
                Text('Bone Age: ${boneAgeD.toStringAsFixed(1)} years'), // Displayed as decimal
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


  String? _validateDecimalField(String? value, String fieldName, {double min = 0.01}) {
    if (value == null || value.isEmpty) return 'Enter $fieldName';
    final double? val = double.tryParse(value);
    if (val == null || val < min) return 'Invalid $fieldName (must be >= $min)';
    return null;
  }

  String? _validateAgeYears(String? value) {
    if (value == null || value.isEmpty) return 'Enter years';
    final int? years = int.tryParse(value);
    if (years == null || years < 0 || years > 25) return '0-25'; // Example upper limit
    return null;
  }

  String? _validateAgeMonths(String? value) {
    if (value == null || value.isEmpty) return 'Enter mths';
    final int? months = int.tryParse(value);
    if (months == null || months < 0 || months >= 12) return '0-11';
    return null;
  }

  // Combined validator for Chronological Age (Decimal or Years/Months)
  String? _validateChronoAge(String? value) { // `value` is for the decimal field, others accessed via controller
    if (_chronoAgeInputMode == AgeInputMode.decimal) {
      if (value == null || value.isEmpty) return 'Enter age';
      final double? age = double.tryParse(value);
      if (age == null || age <= 0) return 'Invalid age';
      if (_selectedSex == Sex.female && age > 14) return 'Max 14y for females';
      if (_selectedSex == Sex.male && age > 16) return 'Max 16y for males';
    } else {
      // For Years/Months, individual fields (_chronoAgeYearsController, _chronoAgeMonthsController)
      // will have their specific validators (_validateAgeYears, _validateAgeMonths).
      // Here, we can do a combined check if needed, or rely on individual field validation.
      // We also need to check the overall decimal value against sex limits.
      final yearsStr = _chronoAgeYearsController.text;
      final monthsStr = _chronoAgeMonthsController.text;
      if (yearsStr.isNotEmpty && monthsStr.isNotEmpty) {
        final double ageDecimal = _convertYearsMonthsToDecimal(yearsStr, monthsStr);
        if (_selectedSex == Sex.female && ageDecimal > 14) return 'Max 14y for females';
        if (_selectedSex == Sex.male && ageDecimal > 16) return 'Max 16y for males';
      }
    }
    return null;
  }

  // Combined validator for Bone Age (Decimal or Years/Months)
  String? _validateBoneAge(String? value) { // `value` is for the decimal field
    if (_boneAgeInputMode == AgeInputMode.decimal) {
      if (value == null || value.isEmpty) return 'Enter bone age';
      final double? age = double.tryParse(value);
      if (age == null || age <= 0 || age > 25) return 'Invalid (0-25y)'; // Example range
    }
    // For Years/Months, individual fields will have their validators.
    // No specific sex-based limit for bone age mentioned in requirements.
    return null;
  }

  Widget _buildAgeInputSection({
    required String title,
    required AgeInputMode currentMode,
    required ValueChanged<AgeInputMode> onModeChange,
    required TextEditingController decimalController,
    required TextEditingController yearsController,
    required TextEditingController monthsController,
    required FormFieldValidator<String> decimalValidator,
    // Individual validators for year/month fields are directly on their TextFormFields
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 4),
        SegmentedButton<AgeInputMode>(
          segments: const <ButtonSegment<AgeInputMode>>[
            ButtonSegment<AgeInputMode>(value: AgeInputMode.decimal, label: Text('Decimal Years')),
            ButtonSegment<AgeInputMode>(value: AgeInputMode.yearsMonths, label: Text('Years & Months')),
          ],
          selected: <AgeInputMode>{currentMode},
          onSelectionChanged: (Set<AgeInputMode> newSelection) {
            onModeChange(newSelection.first);
            // When mode changes, clear the now-inactive fields and re-validate.
            // This also helps _checkFormValidity to reflect the current state.
            if (newSelection.first == AgeInputMode.decimal) {
              yearsController.clear();
              monthsController.clear();
            } else {
              decimalController.clear();
            }
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _formKey.currentState?.validate();
              _checkFormValidity(); // Crucial to update button state
            });
          },
        ),
        const SizedBox(height: 8),
        if (currentMode == AgeInputMode.decimal)
          TextFormField(
            controller: decimalController,
            decoration: InputDecoration(
              labelText: 'Age in Decimal Years',
              hintText: 'e.g., 12.5',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.timelapse), // Changed icon
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
            validator: decimalValidator,
          )
        else
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: yearsController,
                  decoration: const InputDecoration(labelText: 'Years', border: OutlineInputBorder()),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(2)],
                  validator: _validateAgeYears, // Specific validator
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  controller: monthsController,
                  decoration: const InputDecoration(labelText: 'Months', border: OutlineInputBorder()),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(2)],
                  validator: _validateAgeMonths, // Specific validator
                ),
              ),
            ],
          ),
        const SizedBox(height: 16),
      ],
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RWT Height Prediction'),
      ),
      body: SingleChildScrollView( // Ensures content is scrollable
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Sex Toggle
              Text('Sex:', style: Theme.of(context).textTheme.titleMedium),
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
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _formKey.currentState?.validate(); // Re-validate age fields
                      _checkFormValidity();
                    });
                  });
                },
              ),
              const SizedBox(height: 16),

              // Current Height
              TextFormField(
                controller: _currentHeightController,
                decoration: const InputDecoration(labelText: 'Current Height (cm)', hintText: 'e.g., 150.5', border: OutlineInputBorder(), prefixIcon: Icon(Icons.height),),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                validator: (value) => _validateDecimalField(value, 'height'),
              ),
              const SizedBox(height: 16),

              // Chronological Age Section
              _buildAgeInputSection(
                title: 'Chronological Age:',
                currentMode: _chronoAgeInputMode,
                onModeChange: (mode) => setState(() {
                  _chronoAgeInputMode = mode;
                  // When mode changes, clear relevant fields and re-validate
                  if (mode == AgeInputMode.decimal) {
                    _chronoAgeYearsController.clear();
                    _chronoAgeMonthsController.clear();
                  } else {
                    _chronoAgeDecimalYearsController.clear();
                  }
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _formKey.currentState?.validate();
                    _checkFormValidity();
                  });
                }),
                decimalController: _chronoAgeDecimalYearsController,
                yearsController: _chronoAgeYearsController,
                monthsController: _chronoAgeMonthsController,
                decimalValidator: _validateChronoAge,
              ),

              // Weight (kg)
              TextFormField(
                controller: _weightKgController,
                decoration: const InputDecoration(labelText: 'Weight (kg)', hintText: 'e.g., 45.0', border: OutlineInputBorder(), prefixIcon: Icon(Icons.scale)),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                validator: (value) => _validateDecimalField(value, 'weight'),
              ),
              const SizedBox(height: 16),

              // Bone Age Section
              _buildAgeInputSection(
                title: 'Bone Age:',
                currentMode: _boneAgeInputMode,
                onModeChange: (mode) => setState(() {
                  _boneAgeInputMode = mode;
                  // When mode changes, clear relevant fields and re-validate
                  if (mode == AgeInputMode.decimal) {
                    _boneAgeYearsController.clear();
                    _boneAgeMonthsController.clear();
                  } else {
                    _boneAgeDecimalYearsController.clear();
                  }
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _formKey.currentState?.validate();
                    _checkFormValidity();
                  });
                }),
                decimalController: _boneAgeDecimalYearsController,
                yearsController: _boneAgeYearsController,
                monthsController: _boneAgeMonthsController,
                decimalValidator: _validateBoneAge,
              ),

              // Mid-parental Height (cm)
              TextFormField(
                controller: _midparentalHeightController,
                decoration: const InputDecoration(labelText: 'Mid-parental Height (cm)', hintText: 'e.g., 170.0', border: OutlineInputBorder(), prefixIcon: Icon(Icons.family_restroom),),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                validator: (value) => _validateDecimalField(value, 'mid-parental height'),
              ),
              const SizedBox(height: 32), // Spacer before buttons

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
                        // side: BorderSide(color: Theme.of(context).colorScheme.primary), // Optional: style reset button
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
                        disabledBackgroundColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.12),
                        disabledForegroundColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.38),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Roche AF, Wainer H, Thissen D. The RWT method for the prediction of adult stature. Pediatrics. 1975 Dec;56(6):1027-33. PMID: 172855.',
                    textAlign: TextAlign.left,
                    style: TextStyle(fontSize: 12),
                  )),
              const SizedBox(height: 20), // Bottom padding
            ],
          ),
        ),
      ),
    );
  }
}