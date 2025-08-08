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
  final TextEditingController _currentHeightController = TextEditingController();

  Sex _selectedSex = Sex.male;
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
      // _formKey.currentState!.save(); // Not needed with controllers if you directly use .text

      final double? actualAge = double.tryParse(_actualAgeController.text);
      final String skeletalAgeStr = _skeletalAgeController.text;
      final double? currentHeightCm = double.tryParse(_currentHeightController.text);

      if (actualAge == null || currentHeightCm == null || skeletalAgeStr.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill all fields correctly.')),
        );
        return;
      }

      final String sexStr = _selectedSex == Sex.male ? 'boy' : 'girl';
      final double currentHeightInches = currentHeightCm / 2.54;

      PredictedFinalHeightData? exampleResult = heightPredictionService.predictFinalHeight(
          childCurrentHeightInches: currentHeightInches,
          childSkeletalAgeStr: skeletalAgeStr,
          childActualAgeDecimalYears: actualAge,
          sex: sexStr);
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

    final String resultString = result.finalHeight();
    String category = '';
    if (result.skeletalAgeDifferenceCategory == 'advanced_gt_1yr') {
      category = 'Advanced Skeletal Maturation';
    } else if (result.skeletalAgeDifferenceCategory == 'delayed_gt_1yr') {
      category = 'Delayed Skeletal Maturation';
    } else {
      category = 'Normal Skeletal Maturation';
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Predicted Final Height (Bayley-Pinneau)'),
          content: SingleChildScrollView( // Added for potentially long content
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current Height: ${(result.childCurrentHeightInches * 2.54).toStringAsFixed(1)} cm (${result.childCurrentHeightInches.toStringAsFixed(1)} in)',
                  style: const TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent), // Consider using Theme colors
                ),
                const SizedBox(height: 8),
                Text(
                    'Actual Age: ${result.childActualAgeDecimalYears.toStringAsFixed(2)} yrs'),
                Text(
                    'Bone Age: ${result.childSkeletalAgeString.split('-')[0]} years, ${result.childSkeletalAgeString.split('-')[1]} months'),
                Text('Skeletal Maturation: $category'),
                Text('Sex: ${result.sex == 'boy' ? 'Male' : 'Female'}'),
                const SizedBox(height: 8),
                Text(
                  'Predicted Final Height: $resultString',
                  style: const TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent), // Consider using Theme colors
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

  bool _isValidSkeletalAgeFormat(String input) {
    if (input.isEmpty) return true; // Allow empty initially, validator handles 'please enter'
    final RegExp skeletalAgeRegex = RegExp(r'^\d{1,2}-\d{1,2}$');
    if (!skeletalAgeRegex.hasMatch(input)) return false;
    final parts = input.split('-');
    if (parts.length != 2) return false;
    final years = int.tryParse(parts[0]);
    final months = int.tryParse(parts[1]);
    if (years == null || months == null) return false;
    if (months < 0 || months >= 12) return false;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar( // ***** ADD THIS AppBar *****
        title: const Text('Bayley-Pinneau Method'),
        // backgroundColor: Theme.of(context).colorScheme.surfaceVariant, // Optional styling
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // ... your existing TextFormField widgets ...
              TextFormField(
                controller: _currentHeightController,
                decoration: const InputDecoration(
                  labelText: 'Current Height (cm)',
                  hintText: 'e.g., 84.5',
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
                  final height = double.tryParse(value);
                  if (height == null || height <= 0) {
                    return 'Please enter a valid positive height';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
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
                  final age = double.tryParse(value);
                  if (age == null || age <= 0) {
                    return 'Please enter a valid positive age';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _skeletalAgeController,
                decoration: const InputDecoration(
                  labelText: 'Skeletal/Bone Age (years-months)',
                  hintText: 'e.g., 8-6 for 8 years 6 months',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.accessibility_new_outlined), // Changed icon slightly
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter skeletal age';
                  }
                  if (!_isValidSkeletalAgeFormat(value)) {
                    return 'Format: years-months (e.g., 8-6, months 0-11)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16), // Added spacing
              Text('Sex:', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8), // Added spacing
              SegmentedButton<Sex>( // Using SegmentedButton for a more modern feel
                segments: const <ButtonSegment<Sex>>[
                  ButtonSegment<Sex>(value: Sex.male, label: Text('Male'), icon: Icon(Icons.male)),
                  ButtonSegment<Sex>(value: Sex.female, label: Text('Female'), icon: Icon(Icons.female)),
                ],
                selected: <Sex>{_selectedSex},
                onSelectionChanged: (Set<Sex> newSelection) {
                  setState(() {
                    _selectedSex = newSelection.first;
                  });
                },
                style: SegmentedButton.styleFrom(
                  // minimumSize: Size((MediaQuery.of(context).size.width - 48) / 2, 40), // Ensure buttons take reasonable width
                ),
              ),
              const SizedBox(height: 32),
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
              const SizedBox(height: 20), // Added some padding at the bottom
            ],
          ),
        ),
      ),
    );
  }
}
