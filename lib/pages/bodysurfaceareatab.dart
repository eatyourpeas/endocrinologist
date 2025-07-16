
import 'package:flutter/material.dart';
import '../enums/enums.dart';
import 'package:endocrinologist/calculations/bodysurfacearea.dart';

class BodySurfaceAreaTab extends StatefulWidget{
  const BodySurfaceAreaTab({super.key});

  @override
  State <BodySurfaceAreaTab> createState() => _BodySurfaceAreaTabState();
}

class _BodySurfaceAreaTabState extends State<BodySurfaceAreaTab> {
  final _formKey = GlobalKey<FormState>();
  bool _showInfoBox = true;

  // Store the selected method, not just an int. Initialize to a default.
  BsaCalculationMethod _selectedMethod = BsaCalculationMethod.boyd;
  // _isSelected will correspond to the order of methods in BsaCalculationMethod.values
  late List<bool> _isSelected;

  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();

  // Helper to get the display name for the method
  String _getBsaMethodName(BsaCalculationMethod method) {
    switch (method) {
      case BsaCalculationMethod.boyd:
        return "Boyd";
      case BsaCalculationMethod.mosteller:
        return "Mosteller";
      case BsaCalculationMethod.dubois:
        return "Du Bois";
      case BsaCalculationMethod.gehangeorge:
        return "Gehan & George";
      default:
        return "Unknown";
    }
  }

  // Helper to show error dialogs
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


  void _submitForm() {
    // First, ensure the form's current state is valid according to validators
    if (!(_formKey.currentState?.validate() ?? false)) {
      // If not valid, the validators in TextFormFields will show error messages
      return;
    }

    // Since validators passed, we can attempt to parse.
    // double.tryParse is still good for safety, though validators should ensure parsability.
    double? height = double.tryParse(_heightController.text);
    double? weight = double.tryParse(_weightController.text);
    double bsa = 0.0;

    // These checks are now more of a fallback, as validators should prevent null/empty
    if (height == null) {
      _showErrorDialog("Input Error", "Invalid height entered. Please enter a valid number.");
      return;
    }
    if (weight == null) {
      _showErrorDialog("Input Error", "Invalid weight entered. Please enter a valid number.");
      return;
    }

    // Calculate BSA using the _selectedMethod
    bsa = calculateBSA(height, weight, _selectedMethod);

    // Get the name of the selected method for display
    String methodName = _getBsaMethodName(_selectedMethod);

    showDialog(
        context: context,
        builder: (BuildContext dialogContext) { // Use a different context name for the dialog
          return AlertDialog(
            title: const Text('Body Surface Area Calculation'),
            content: SingleChildScrollView(
              child: Column(
                  mainAxisSize: MainAxisSize.min, // Important for Column in Dialog
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Method: $methodName",
                      style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "${bsa.toStringAsFixed(3)} m²", // Display calculated BSA
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ]),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text("OK"),
              )
            ],
          );
        });
  }

  @override
  void initState() {
    super.initState();
    // Initialize _isSelected based on BsaCalculationMethod.values
    // and the initial _selectedMethod
    _isSelected = List.generate(
      BsaCalculationMethod.values.length,
          (index) => BsaCalculationMethod.values[index] == _selectedMethod,
    );

    // Add listeners to enable/disable button based on text field content
    // This is a common way to manage button state without relying on _formComplete
    _weightController.addListener(_updateButtonState);
    _heightController.addListener(_updateButtonState);
  }

  // To update button state reactively (optional but good UX)
  bool _canSubmit = false;
  void _updateButtonState() {
    setState(() {
      _canSubmit = _weightController.text.isNotEmpty &&
          _heightController.text.isNotEmpty;
    });
  }

  @override
  void dispose() {
    _weightController.removeListener(_updateButtonState);
    _heightController.removeListener(_updateButtonState);
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }


  // bool _formComplete() {
  // // This version of _formComplete is simpler if you want to enable based on just text presence
  // // Validators will handle if the text is a valid number upon submission.
  //   return _weightController.text.isNotEmpty && _heightController.text.isNotEmpty;
  // }

  @override
  Widget build(BuildContext context) {
    // Define the methods for ToggleButtons
    final List<BsaCalculationMethod> bsaMethods = BsaCalculationMethod.values;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0), // Apply padding to SingleChildScrollView
      child: Form( // Wrap with Form widget
        key: _formKey,
        child: Column(children: [
          Visibility(
            visible: _showInfoBox,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12.0, vertical: 8.0),
                decoration: BoxDecoration(
                  color: Colors.lightBlueAccent[100],
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(
                    color: Colors.lightBlueAccent,
                    width: 1,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0, top: 2.0),
                      child: Icon(
                        Icons.info_outline,
                        color: Colors.blue[700],
                        size: 20,
                      ),
                    ),
                    const Expanded(
                      child: Text(
                        'Calculate the body surface area from height (cm) and weight (kg).',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _showInfoBox = false;
                          });
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Icon(
                          Icons.close,
                          color: Colors.grey[700],
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // No need for an extra Column here if Form is the direct child of SingleChildScrollView's Padding
          TextFormField(
            controller: _weightController,
            decoration: const InputDecoration(
              labelText: 'Weight (kg)',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Please enter weight";
              }
              if (double.tryParse(value) == null) {
                return 'Please enter a valid number';
              }
              if (double.parse(value) <= 0) {
                return 'Weight must be positive';
              }
              return null;
            },
          ),
          const SizedBox(height: 16), // Increased spacing
          TextFormField(
            controller: _heightController,
            decoration: const InputDecoration(
              labelText: 'Height (cm)',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Please enter height";
              }
              if (double.tryParse(value) == null) {
                return 'Please enter a valid number';
              }
              final heightValue = double.parse(value);
              if (heightValue < 20 || heightValue > 250) { // Adjusted realistic range
                return 'Height must be between 20-250 cm';
              }
              return null;
            },
          ),
          const SizedBox(height: 16), // Increased spacing
          Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              ToggleButtons(
                isSelected: _isSelected,
                onPressed: (int index) {
                  setState(() {
                    for (int buttonIndex = 0; buttonIndex < _isSelected.length; buttonIndex++) {
                      _isSelected[buttonIndex] = buttonIndex == index;
                    }
                    _selectedMethod = bsaMethods[index];
                  });
                },
                selectedBorderColor: Colors.blue,
                selectedColor: Colors.blue,
                constraints: BoxConstraints(
                  minHeight: 40.0,
                  minWidth: (MediaQuery.of(context).size.width - 64) / bsaMethods.length,
                ),
                children: bsaMethods.map((method) {
                  return Expanded(
                      child:Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      _getBsaMethodName(method),
                      style: const TextStyle(fontSize: 11),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ));
                }).toList()
              )
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _canSubmit ? _submitForm : null, // Use _canSubmit
              child: const Text('Calculate Body Surface Area'),
            ),
          )
        ]),
      ),
    );
  }
}





