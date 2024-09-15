import 'package:flutter/material.dart';

class SteroidPage extends StatefulWidget {
  const SteroidPage({super.key});
  @override
  _SteroidPageState createState() => _SteroidPageState();
}

class _SteroidPageState extends State<SteroidPage> {
  // Global key for form state
  final _formKey = GlobalKey<FormState>();

  bool _showBodySurfaceArea = false;

  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _bsaController = TextEditingController();

  void _submitForm(){

  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          // Close the keyboard if user taps anywhere outside the TextField
          FocusScope.of(context).unfocus();
        },
        child: SingleChildScrollView(
            child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Weight and Height TextFormField
                        Visibility(
                            visible: !_showBodySurfaceArea,
                              child: Column(
                                children:[
                                  TextFormField(
                                    controller: _weightController,
                                    decoration: const InputDecoration(
                                    labelText: 'Weight (kg)',
                                    border: OutlineInputBorder(),),
                                    keyboardType: TextInputType.number,
                                    validator: (value) {
                                      if (value == null || value.isEmpty && !_showBodySurfaceArea) {
                                        return "Please enter infant/child/young person's weight";
                                      }
                                      if (double.tryParse(value) == null) {
                                        return 'Please enter a valid number';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 8),
                                  // Weight TextFormField
                                  TextFormField(
                                    controller: _heightController,
                                    decoration: const InputDecoration(
                                      labelText: 'Height (cm)',
                                      border: OutlineInputBorder(),
                                    ),
                                    keyboardType: TextInputType.number,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return "Please enter infant/child/young person's height/length";
                                      }
                                      if (double.tryParse(value) == null) {
                                        return 'Please enter a valid number';
                                      }
                                      if (double.tryParse(value)! < 45 || double.tryParse(value)! > 205){
                                        return 'Please enter a valid height';
                                      }
                                      return null;
                                    },
                                  )
                                ],)
                          ),
                        // Body surface area TextFormField
                        Visibility(
                          visible: _showBodySurfaceArea,
                          child: TextFormField(
                                    controller: _bsaController,
                                    keyboardType: TextInputType.number,
                                    validator: (value){
                                      if (value == null || value.isEmpty && (_showBodySurfaceArea)) {
                                        return "Please enter the body surface area.";
                                      }
                                      if (double.tryParse(value) == null) {
                                        return 'Please enter a valid number';
                                      }
                                      return null;
                                    },
                                    decoration: const InputDecoration(
                                      labelText: 'body surface area (m2)',
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                          ),
                        // body surface area checkbox and label
                        Row(
                          children: [
                            const Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Body surface area is already known",
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(width: 8),
                                    Tooltip(
                                      message: 'If the body surface area is already known, enter it here',
                                      margin: EdgeInsets.symmetric(horizontal: 20.0), // Add margin to both sides
                                      child: Icon(Icons.info_outline, color: Colors.blue),
                                    ),
                                  ],
                            ),
                            Checkbox(
                              value: _showBodySurfaceArea,
                              onChanged: (value) {
                                setState(() {
                                  _showBodySurfaceArea = value ?? false;
                                });
                              },
                            ),
                          ]),
                        const SizedBox(height: 20),
                        // Submit Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: ()=> _submitForm,
                            child: const Text('Calculate Glucose Infusion Rate'),
                          ),
                        )
                      ],
                    )
                  ),
                )
            )
        );
  }
}
