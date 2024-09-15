import 'package:flutter/material.dart';
import '../referencedata/milks.dart';
import '../calculations/glucosemaths.dart';
import '../classes/milk.dart';

class GlucosePage extends StatefulWidget {
    const GlucosePage({super.key});
    @override
    _GlucosePageState createState() => _GlucosePageState();
  }

  class _GlucosePageState extends State<GlucosePage> {
    // Global key for form state
    final _formKey = GlobalKey<FormState>();

    // State for the selected dropdown item
    Milk? _selectedMilk;
    // List of dropdown items
    final List<Milk> _dropdownItems = sortedMilks(milks);

    // Controllers for the text fields
    final TextEditingController _weightController = TextEditingController();
    final TextEditingController _glucosePercentageController = TextEditingController();
    final TextEditingController _infusionRateController = TextEditingController();
    final TextEditingController _milkStrengthController = TextEditingController();
    final TextEditingController _milkVolumeController = TextEditingController();

    // toggle states
    bool _showParenteralFields = false;
    bool _showEnteralFields = false;
    bool _showCustomMilkCarbsField = false;

    bool validateMilkSelection(Milk? milk) {
      if (milk == null && !_showCustomMilkCarbsField) {
        return false; // Or handle null value differently
      }
      // Add your specific validation rules here
      return true;
    }

    void _submitForm() {
      if (_formKey.currentState?.validate() ?? false) {
        // submission is valid: run the maths...
        double? glucosePercentage;
        double? glucoseInfusionRate;
        double? milkDailyRate;
        double? milkCarbohydratePercentage;
        double milkInfusionRate = 0.0;

        double parenteralGIR = 0;
        double enteralGIR = 0;

        double? weight  = double.tryParse(_weightController.text);
        if (weight == null){
          throw Exception("The weight cannot be null.");
        }
        if (_showParenteralFields){
          glucosePercentage = double.tryParse(_glucosePercentageController.text);
          glucoseInfusionRate = double.tryParse(_infusionRateController.text);
          if (glucoseInfusionRate != null && glucosePercentage != null){
            parenteralGIR = calculateGlucoseInfusionRate(glucosePercentage, glucoseInfusionRate, weight);
          }
        }
        if (_showEnteralFields){
          milkDailyRate = double.tryParse(_milkVolumeController.text);
          if (milkDailyRate == null){
            throw Exception("The daily milk volume/kg cannot be null.");
          }
          milkInfusionRate = hourlyMilkRateForDailyVolume(milkDailyRate, weight);

          if (_showCustomMilkCarbsField){
            milkCarbohydratePercentage = double.tryParse(_milkStrengthController.text);
            if (milkCarbohydratePercentage == null){
              throw Exception("The carb concentration of the milk cannot be null.");
            }
            enteralGIR = calculateGlucoseInfusionRate(milkCarbohydratePercentage, milkInfusionRate, weight);
          } else {
            milkCarbohydratePercentage = _selectedMilk?.carbsPer100ml;
            if (milkCarbohydratePercentage == null){
              throw Exception("The daily milk volume per kg cannot be null.");
            }
            enteralGIR = calculateGlucoseInfusionRate(milkCarbohydratePercentage, milkInfusionRate, weight);
          }
        }

        // launch dialog for results
        showDialog(
            context: context,
            builder: (BuildContext context){
              return AlertDialog(
                title: const Text("Glucose Infusion Rates"),
                content: Column(
                  children: [
                    if (enteralGIR > 0 || parenteralGIR > 0)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0), // Add padding below the grid
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                if (enteralGIR > 0)
                                  const Text(
                                    "Enteral",
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                if (parenteralGIR > 0)
                                  const Text(
                                    "Parenteral",
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                              ],
                            ),
                            const Divider(color: Colors.black, height: 1), // Thin black line
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                if (enteralGIR > 0)
                                  Text("${enteralGIR.toStringAsFixed(1)} mg/kg/min"),
                                if (parenteralGIR > 0)
                                  Text("${parenteralGIR.toStringAsFixed(1)} mg/kg/min"),
                              ],
                            ),
                          ],
                        ),
                      ),
                    Text(
                      "Total ${(enteralGIR + parenteralGIR).toStringAsFixed(1)} mg/kg/min",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    if (milkInfusionRate > 0) ...[
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0), // Adjust padding value as needed
                        child: Text(
                          "Volumes for ${milkDailyRate?.toStringAsFixed(0)} ml/kg/d",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const Divider(color: Colors.black),
                      Column(
                        children: [
                          for (int i = 1; i <= 4; i++)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("$i-hourly feeds:"),
                                Text("${(milkInfusionRate * i).toStringAsFixed(0)} ml/feed"),
                              ],
                            ),
                        ],
                      )
                    ],
                  ],
                ),
                actions: [
                  TextButton(
                      onPressed: ()=>Navigator.pop(context),
                      child: const Text("OK"))
                ],
              );
            }
        );
      }
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
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Weight TextFormField
                TextFormField(
                  controller: _weightController,
                  decoration: const InputDecoration(
                    labelText: 'Weight (kg)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value){
                    if (value == null || value.isEmpty) {
                      return "Please enter infant/child/young person's weight";
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),

              // Toggles for Parenteral and Enteral fields
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            'Parenteral fluids',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(width: 8),
                          Tooltip(
                            message: 'If the child or young person is on intravenous dextrose or TPN, include this here.',
                            margin: EdgeInsets.symmetric(horizontal: 20.0), // Add margin to both sides
                            child: Icon(Icons.info_outline, color: Colors.blue),
                          ),
                        ],
                      )
                  ),
                  Switch(
                    value: _showParenteralFields,
                    onChanged: (bool value) {
                      setState(() {
                        _showParenteralFields = value;
                      });
                    },
                  ),
                ],
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              'Enteral feeds',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(width: 8),
                            Tooltip(
                              message: 'If the child or young person is on feeds, include this here. Common and specialist milks are ',
                              margin: EdgeInsets.symmetric(horizontal: 20.0), // Add margin to both sides
                              child: Icon(Icons.info_outline, color: Colors.blue),
                            ),
                          ]),
                  ),
                  Switch(
                    value: _showEnteralFields,
                    onChanged: (bool value) {
                      setState(() {
                        _showEnteralFields = value;
                      });
                    },
                  ),
                ]),


              // show parenteral fields
              Visibility(
                  visible: _showParenteralFields,
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      const Text(
                        'Parenteral',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold), textAlign: TextAlign.left,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _glucosePercentageController,
                        keyboardType: TextInputType.number,
                        validator: (value){
                          if (value == null || value.isEmpty && _showParenteralFields) {
                            return "Please enter the dextrose percentage or g/100ml.";
                          }
                          if (double.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                        decoration: const InputDecoration(
                          labelText: 'Glucose (g/100ml)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _infusionRateController,
                        keyboardType: TextInputType.number,
                        validator: (value){
                          if (value == null || value.isEmpty && _showParenteralFields) {
                            return "Please enter the dextrose infusion rate in ml/hr.";
                          }
                          if (double.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                        decoration: const InputDecoration(
                          labelText: 'Rate (ml/hr)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  )
              ),

              // Show Enteral feeds
              Visibility(
                  visible: _showEnteralFields,
                  child: SizedBox(
                    height: 500,
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        const Text(
                          'Enteral',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold), textAlign: TextAlign.left,
                        ),
                        const SizedBox(height: 8),
                        Visibility(
                          visible: !_showCustomMilkCarbsField,
                          child: Column(
                            children:[
                              const Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Select a milk',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              SizedBox(
                                child: DropdownButtonFormField<Milk>(
                                    menuMaxHeight: 200,
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText: "Milk",
                                    ),
                                    validator: (value){
                                      if (value == null && !_showCustomMilkCarbsField) {
                                        return "Please select a milk";
                                      }
                                      return null;
                                    },
                                    value: _selectedMilk,
                                    items: _dropdownItems.map((Milk item) {
                                      return DropdownMenuItem<Milk>(
                                          value: item,
                                          child: SizedBox(
                                            width: 300,
                                            child:Text("${item.name} (${item.carbsPer100ml}g)"),
                                          )
                                      );
                                    }).toList(),
                                    onChanged: (Milk? newValue) {
                                      setState(() {
                                        _selectedMilk = newValue;
                                      });
                                    },
                                    hint: const Text('Select a milk'),
                                ),
                              ),
                            ],
                        ),),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (_showCustomMilkCarbsField)
                            Expanded(
                              child: TextFormField(
                                controller: _milkStrengthController,
                                keyboardType: TextInputType.number,
                                validator: (value){
                                  if (value == null || value.isEmpty && (_showEnteralFields && _showCustomMilkCarbsField)) {
                                    return "Please enter the milk carbohydrates.";
                                  }
                                  if (double.tryParse(value) == null) {
                                    return 'Please enter a valid number';
                                  }
                                  return null;
                                },
                                decoration: const InputDecoration(
                                  labelText: 'carbohydrate (g/100ml)',
                                  border: OutlineInputBorder(),
                                ),
                              ),),
                            Expanded(child:(Row(children: [Checkbox(
                              value: _showCustomMilkCarbsField,
                              onChanged: (value) {
                                setState(() {
                                  _showCustomMilkCarbsField = value ?? false;
                                });
                              },
                            ),
                              const Expanded(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Milk not in list",
                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(width: 8),
                                      Tooltip(
                                        message: 'If the milk does cannot be found in the list, enter the carb amount per 100ml. It may be labelled as a percentage.',
                                        margin: EdgeInsets.symmetric(horizontal: 20.0), // Add margin to both sides
                                        child: Icon(Icons.info_outline, color: Colors.blue),
                                      ),
                                    ],
                                  )
                              ),
                            ])))
                          ],
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _milkVolumeController,
                          keyboardType: TextInputType.number,
                          validator: (value){
                            if (value == null || value.isEmpty && _showEnteralFields) {
                              return "Please enter the total daily volume.";
                            }
                            if (double.tryParse(value) == null) {
                              return 'Please enter a valid number';
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                            labelText: 'Feed volume (ml/kg/d)',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Select Box (Dropdown)

                      ],
                    ),
                  )

              ),

              const SizedBox(height: 20),
              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (!_showEnteralFields && !_showParenteralFields) ? null : _submitForm,
                  child: const Text('Calculate Glucose Infusion Rate'),
                ),
              )
            ]),
        ),
      ),
      )
      );
    }}
