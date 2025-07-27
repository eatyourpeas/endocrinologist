import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For TextInputFormatters
import 'package:endocrinologist/referencedata/bayley_pinneau.dart';
import 'package:endocrinologist/enums/enums.dart';

class BayleyPinneauPage extends StatefulWidget {
  const BayleyPinneauPage({super.key});

  @override
  State<BayleyPinneauPage> createState() => _BayleyPinneauPageState();
}



class _BayleyPinneauPageState extends State<BayleyPinneauPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _actualAgeController = TextEditingController();
  final TextEditingController _skeletalAgeController = TextEditingController();
  final TextEditingController _currentHeightController = TextEditingController(); // Added for height

  Sex _selectedSex = Sex.male;

  // Instantiate your service
  // For a real app, consider using a state management solution (Provider, Riverpod)
  // to provide this service instead of instantiating it directly in the widget.
  final HeightPredictionService heightPredictionService = HeightPredictionService();


  @override
  void dispose() {
    _actualAgeController.dispose();
    _skeletalAgeController.dispose();
    _currentHeightController.dispose();
    super.dispose();
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _actualAgeController.clear();
    _skeletalAgeController.clear();
    _currentHeightController.clear();
    setState(() {
      _selectedSex = Sex.male;
    });
  }

  void _calculateHeight() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save(); // Not strictly necessary with controllers, but good practice

      final double? actualAge = double.tryParse(_actualAgeController.text);
      final String skeletalAgeStr = _skeletalAgeController.text; // e.g., "10-6"
      final double? currentHeight = double.tryParse(_currentHeightController.text);
      final String sexStr = _selectedSex == Sex.male ? 'boy' : 'girl';

      if (actualAge == null || currentHeight == null || skeletalAgeStr.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill all fields correctly.')),
        );
        return;
      }

      PredictedFinalHeightData? exampleResult = heightPredictionService.predictFinalHeight(childCurrentHeightInches: currentHeight, childSkeletalAgeStr: skeletalAgeStr, childActualAgeDecimalYears: actualAge, sex: sexStr);
      _showResultModal(exampleResult);
    }
  }

  void _showResultModal(PredictedFinalHeightData? result) {
    if (result == null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Calculation Error'),
            content: const Text(
                'Could not predict height. Please check inputs or data availability.'),
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
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Predicted Final Height'),
          content: SingleChildScrollView( // In case the result string is long
            child: Text(result.toString()), // Using the toString() from your data class
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

  // Helper for skeletal age format e.g. "10-6"
  bool _isValidSkeletalAgeFormat(String input) {
    if (input.isEmpty) return false;
    final RegExp skeletalAgeRegex = RegExp(r'^\d{1,2}-\d{1,2}$');
    if (!skeletalAgeRegex.hasMatch(input)) return false;
    final parts = input.split('-');
    if (parts.length != 2) return false;
    final years = int.tryParse(parts[0]);
    final months = int.tryParse(parts[1]);
    if (years == null || months == null) return false;
    if (months < 0 || months >= 12) return false; // Months should be 0-11
    return true;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                'Enter Child Details',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Current Height
              TextFormField(
                controller: _currentHeightController,
                decoration: const InputDecoration(
                  labelText: 'Current Height (inches)',
                  hintText: 'e.g., 50.5',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.height),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter current height';
                  }
                  if (double.tryParse(value) == null || double.parse(value) <= 0) {
                    return 'Please enter a valid positive height';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Actual Decimal Age
              TextFormField(
                controller: _actualAgeController,
                decoration: const InputDecoration(
                  labelText: 'Actual Chronological Age (decimal years)',
                  hintText: 'e.g., 8.5 for 8 years 6 months',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.cake_outlined),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter actual age';
                  }
                  if (double.tryParse(value) == null || double.parse(value) <= 0) {
                    return 'Please enter a valid positive age';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Skeletal (Bone) Age
              TextFormField(
                controller: _skeletalAgeController,
                decoration: const InputDecoration(
                  labelText: 'Skeletal/Bone Age (years-months)',
                  hintText: 'e.g., 8-6 for 8 years 6 months',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.accessibility_new),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter skeletal age';
                  }
                  if (!_isValidSkeletalAgeFormat(value)) {
                    return 'Format must be years-months (e.g., 8-6, months 0-11)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Sex Toggle
              Text('Sex:', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              ToggleButtons(
                isSelected: [_selectedSex == Sex.male, _selectedSex == Sex.female],
                onPressed: (int index) {
                  setState(() {
                    _selectedSex = index == 0 ? Sex.male : Sex.female;
                  });
                },
                borderRadius: BorderRadius.circular(8.0),
                selectedBorderColor: Theme.of(context).colorScheme.primary,
                selectedColor: Colors.white,
                fillColor: Theme.of(context).colorScheme.primary,
                color: Theme.of(context).colorScheme.primary,
                constraints: BoxConstraints(
                  minHeight: 40.0,
                  minWidth: (MediaQuery.of(context).size.width - 48) / 2, // Adjust width
                ),
                children: const <Widget>[
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [Icon(Icons.male, size: 18), SizedBox(width: 8), Text('Male')],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [Icon(Icons.female, size: 18), SizedBox(width: 8), Text('Female')],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                      onPressed: _calculateHeight,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        textStyle: const TextStyle(fontSize: 16),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
