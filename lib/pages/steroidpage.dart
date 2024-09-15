import 'package:flutter/material.dart';
import 'package:endocrinologist/classes/glucocorticoid.dart';
import 'package:endocrinologist/referencedata/glucocorticoids.dart';
import 'package:endocrinologist/calculations/glucocorticoidmaths.dart';
import 'package:endocrinologist/calculations/bodysurfacearea.dart';

class SteroidPage extends StatefulWidget {
  const SteroidPage({super.key});
  @override
  _SteroidPageState createState() => _SteroidPageState();
}

class _SteroidPageState extends State<SteroidPage> {
  // Global key for form state
  final _formKey = GlobalKey<FormState>();

  bool _showBodySurfaceArea = false;
  int? _selectedBSA = 1;
  final List<bool> _isSelected = [true, false, false, false];
  bool _existingSteroids = false;
  Glucocorticoid? _selectedGlucocorticoid;
  final List<Glucocorticoid> _dropdownItems = sortedGlucocorticoids(glucocorticoids);

  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _bsaController = TextEditingController();
  final TextEditingController _steroidDoseController = TextEditingController();

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      double? height = double.tryParse(_heightController.text);
      double? weight = double.tryParse(_weightController.text);
      double? customBSA = double.tryParse(_bsaController.text);
      double bsa = 0.0;

      if (_showBodySurfaceArea) {
        if (customBSA == null ){
          throw Exception("the BSA cannot be null.");
        }
        bsa = customBSA;
        // If showing BSA, ensure we proceed with calculations even if height and weight are null
        // Here you might want to handle the case where BSA is being shown without input values
      } else {
        // If not showing BSA, ensure height and weight are valid
        if (height == null || weight == null) {
          // Handle the case where height or weight is invalid
          throw Exception('Invalid height or weight input');
        }

        switch (_selectedBSA) {
          case 1:
            bsa = calculateBSA(height, weight, BsaCalculationMethod.boyd);
            break;
          case 2:
            bsa = calculateBSA(height, weight, BsaCalculationMethod.mostellar);
            break;
          case 3:
            bsa = calculateBSA(height, weight, BsaCalculationMethod.dubois);
            break;
          case 4:
            bsa = calculateBSA(height, weight, BsaCalculationMethod.gehangeorge);
            break;
          default:
          // Handle unexpected BSA method selections
            print('Invalid BSA calculation method selected');
            bsa = 0.0;
            return;
        }

        // Continue with the rest of your form submission logic
      }

      double maintenanceDoseMin = maintenanceHydrocortisoneDoseMin(bsa);
      double maintenanceDoseMax = maintenanceHydrocortisoneDoseMax(bsa);
      double stressDose = oralStressHydrocortisoneDoseMax(bsa);
      showDialog(
        context: context,
          builder: (BuildContext context){
            return AlertDialog(
              title: const Text("Hydrocortisone Doses"),
              content: Column(
                children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0), // Add padding below the grid
                      child: Column(
                        children: [
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                                Text(
                                  "Maintenance",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  "Emergency",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                            ],
                          ),
                          const Divider(color: Colors.black, height: 1), // Thin black line
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text("${maintenanceDoseMin.toStringAsFixed(0)}-${maintenanceDoseMax.toStringAsFixed(0)} mg/day"),
                              Text("${stressDose.toStringAsFixed(0)} mg/day"),
                            ],
                          ),
                        ],
                      ),
                    ),
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


  bool _formComplete(){
    bool steroidsValid = (_existingSteroids && _selectedGlucocorticoid != null && _steroidDoseController.text.isNotEmpty );
    bool bsaValid = ((_showBodySurfaceArea && _bsaController.text.isNotEmpty) || (!_showBodySurfaceArea && _weightController.text.isNotEmpty && _heightController.text.isNotEmpty));
    return steroidsValid == bsaValid;
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
                                mainAxisSize: MainAxisSize.max,
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
                                  ),
                                  const SizedBox(height: 8,),
                                  Row(
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      ToggleButtons(
                                        isSelected: _isSelected,
                                        onPressed: (int index) {
                                          setState(() {
                                            for (int buttonIndex = 0; buttonIndex < _isSelected.length; buttonIndex++) {
                                              if (buttonIndex == index) {
                                                _isSelected[buttonIndex] = !_isSelected[buttonIndex];
                                              } else {
                                                _isSelected[buttonIndex] = false;
                                              }
                                            }
                                            // _selectedBSA = index + 1; // Update selected option
                                          });
                                        },
                                        selectedBorderColor: Colors.blue,
                                        selectedColor: Colors.blue,
                                        children: [
                                          SizedBox(width: (MediaQuery.of(context).size.width - 37)/4, child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[ SizedBox(width: 4.0), Text("Boyd", style: TextStyle(fontSize: 10),)],)),
                                          SizedBox(width: (MediaQuery.of(context).size.width - 37)/4, child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[ SizedBox(width: 4.0), Text("Mosteller",style: TextStyle(fontSize: 10),)],)),
                                          SizedBox(width: (MediaQuery.of(context).size.width - 37)/4, child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[ SizedBox(width: 4.0), Text("Du Bois",style: TextStyle(fontSize: 10),)],)),
                                          SizedBox(width: (MediaQuery.of(context).size.width - 37)/4, child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[ SizedBox(width: 4.0), Text("Gehan & George",style: TextStyle(fontSize: 10),)],)),
                                        ],
                                      )
                                    ],
                                  ),
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
                                        return "Please enter the body surface area in m².";
                                      }
                                      if (double.tryParse(value) == null) {
                                        return 'Please enter a valid number';
                                      }
                                      return null;
                                    },
                                    decoration: const InputDecoration(
                                      labelText: 'body surface area (m²)',
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Expanded(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Existing steroids?',
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(width: 8),
                                    Tooltip(
                                      message: 'If the child or young person is on steroids already, include these here. The relative potencies are listed',
                                      margin: EdgeInsets.symmetric(horizontal: 20.0), // Add margin to both sides
                                      child: Icon(Icons.info_outline, color: Colors.blue),
                                    ),
                                  ],
                                )
                            ),
                            Switch(
                              value: _existingSteroids,
                              onChanged: (bool value) {
                                setState(() {
                                  _existingSteroids = value;
                                });
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Visibility(
                          visible: _existingSteroids,
                          child: Column(
                              children: [
                                SizedBox(
                                  child: DropdownButtonFormField<Glucocorticoid>(
                                    menuMaxHeight: 200,
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText: "Steroids",
                                    ),
                                    validator: (value){
                                      if (value == null && !_existingSteroids) {
                                        return "Please select a steroid";
                                      }
                                      return null;
                                    },
                                    value: _selectedGlucocorticoid,
                                    items: _dropdownItems.map((Glucocorticoid item) {
                                      return DropdownMenuItem<Glucocorticoid>(
                                          value: item,
                                          child: SizedBox(
                                            width: 300,
                                            child:Text("${item.name} (${item.potency})"),
                                          )
                                      );
                                    }).toList(),
                                    onChanged: (Glucocorticoid? newValue) {
                                      setState(() {
                                        _selectedGlucocorticoid = newValue;
                                      });
                                    },
                                    hint: const Text('Select a steroid'),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _steroidDoseController,
                                  decoration: const InputDecoration(
                                    labelText: 'dosage (mg)',
                                    border: OutlineInputBorder(),
                                  ),
                                  keyboardType: TextInputType.number,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "Please enter glucocorticoid dose in mg.";
                                    }
                                    if (double.tryParse(value) == null) {
                                      return 'Please enter a valid number';
                                    }
                                    return null;
                                  },
                                ),
                              ]
                          )
                        ),
                        // Submit Button
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _formComplete() ? null : _submitForm,
                            child: const Text('Calculate Steroid Doses'),
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
