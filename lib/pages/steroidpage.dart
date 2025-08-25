import 'package:endocrinologist/calculations/glucocorticoidmaths.dart';
import 'package:endocrinologist/classes/glucocorticoid.dart';
import 'package:endocrinologist/referencedata/glucocorticoids.dart';
import 'package:flutter/material.dart';

class SteroidPage extends StatefulWidget {
  const SteroidPage({super.key});

  @override
  SteroidPageState createState() => SteroidPageState();
}

class SteroidPageState extends State<SteroidPage> {
  // Global key for form state
  final _formKey = GlobalKey<FormState>();
  bool _showInfoBox = true;
  bool _existingSteroids = false;
  Glucocorticoid? _selectedGlucocorticoid;
  final List<Glucocorticoid> _dropdownItems =
      sortedGlucocorticoids(glucocorticoids);
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _bsaController = TextEditingController();
  final TextEditingController _steroidDoseController = TextEditingController();

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      double? weight = double.tryParse(_weightController.text);
      double? customBSA = double.tryParse(_bsaController.text);
      double? steroidDose = double.tryParse(_steroidDoseController.text);
      double bsa = 0.0;

      if (weight == null) {
        // Handle the case where weight is invalid
        throw Exception('Invalid weight input');
      }

      if (customBSA == null) {
        throw Exception("the BSA cannot be null.");
      }
      bsa = customBSA;

      double? existingSteroidEquivalent;
      if (steroidDose == null || _selectedGlucocorticoid == null) {
        existingSteroidEquivalent = 0.0;
      } else {
        existingSteroidEquivalent =
            hydrocortisoneEquivalentDose(steroidDose, _selectedGlucocorticoid!);
      }
      double maintenanceDoseMin = maintenanceHydrocortisoneDoseMin(bsa);
      double maintenanceDoseMax = maintenanceHydrocortisoneDoseMax(bsa);
      double stressDose = oralStressHydrocortisoneDoseMax(bsa);
      String steroidText;

      if (_existingSteroids) {
        if (existingSteroidEquivalent > maintenanceDoseMin) {
          steroidText =
              "$steroidDose mg of ${_selectedGlucocorticoid?.name} has a hydrocortisone equivalent of $existingSteroidEquivalent mg. This is more than this patient's hydrocortisone maintenance dose of ${maintenanceDoseMin.toStringAsFixed(0)} mg";
        } else {
          maintenanceDoseMin = maintenanceDoseMin - existingSteroidEquivalent;
          maintenanceDoseMax = maintenanceDoseMax - existingSteroidEquivalent;
          stressDose = stressDose - existingSteroidEquivalent;
          steroidText =
              "An adjustment to maintenance has been made to account for existing steroid doses ($steroidDose mg of ${_selectedGlucocorticoid?.name} - $existingSteroidEquivalent mg hydrocortisone equivalent)";
        }
      } else {
        steroidText = "This assumes no other steroids are prescribed.";
      }
      List<double> suggestedTDSMin = dividedDoses(maintenanceDoseMin, 3);
      List<double> suggestedTDSMax = dividedDoses(maintenanceDoseMax, 3);
      List<double> suggestedQDSMin = dividedDoses(maintenanceDoseMin, 4);
      List<double> suggestedQDSMax = dividedDoses(maintenanceDoseMax, 4);
      List<double> suggestedQDSStress = dividedDoses(stressDose, 4);
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Hydrocortisone Doses"),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          bottom: 8.0), // Add padding below the grid
                      child: Column(
                        children: [
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                "Maintenance",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const Divider(
                              color: Colors.black,
                              height: 1), // Thin black line
                          const SizedBox(
                            height: 8,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                "8mg/m²/d (${maintenanceDoseMin.toStringAsFixed(0)} mg/day)",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              const Tooltip(
                                message:
                                    'The doses have been rounded to the nearest 1.25mg. It is possible the maximum and minimum maintenance doses will therefore be the same.',
                                margin: EdgeInsets.symmetric(
                                    horizontal:
                                        20.0), // Add margin to both sides
                                child: Icon(
                                  Icons.info_outline,
                                  color: Colors.blue,
                                  size: 18,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Wrap(
                                  alignment: WrapAlignment.start,
                                  children: [
                                    Text(
                                      "3 doses: ${suggestedTDSMin.join('mg, ')}mg (${suggestedTDSMin.reduce((value, element) => value + element).toStringAsFixed(0)}mg)",
                                      style: const TextStyle(
                                          fontStyle: FontStyle.italic),
                                    ),
                                    Text(
                                      "4 doses: ${suggestedQDSMin.join('mg, ')}mg (${suggestedQDSMin.reduce((value, element) => value + element).toStringAsFixed(0)}mg)",
                                      style: const TextStyle(
                                          fontStyle: FontStyle.italic),
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                "10mg/m²/d (${maintenanceDoseMax.toStringAsFixed(0)} mg/day)",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              const Tooltip(
                                message:
                                    'The doses have been rounded to the nearest 1.25mg. It is possible the maximum and minimum maintenance doses will therefore be the same.',
                                margin: EdgeInsets.symmetric(
                                    horizontal:
                                        20.0), // Add margin to both sides
                                child: Icon(
                                  Icons.info_outline,
                                  color: Colors.blue,
                                  size: 18,
                                ),
                              ),
                            ],
                          ),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Wrap(
                                    alignment: WrapAlignment.start,
                                    children: [
                                      Text(
                                        "3 doses: ${suggestedTDSMax.join('mg, ')}mg (${suggestedTDSMax.reduce((value, element) => value + element).toStringAsFixed(0)}mg)",
                                        style: const TextStyle(
                                            fontStyle: FontStyle.italic),
                                      ),
                                      Text(
                                        "4 doses: ${suggestedQDSMax.join('mg, ')}mg (${suggestedQDSMax.reduce((value, element) => value + element).toStringAsFixed(0)}mg)",
                                        style: const TextStyle(
                                            fontStyle: FontStyle.italic),
                                      )
                                    ],
                                  ),
                                )
                              ]),
                          const SizedBox(
                            height: 20,
                          ),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                "Emergency",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const Divider(
                              color: Colors.black,
                              height: 1), // Thin black line
                          const SizedBox(
                            height: 8,
                          ),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text("Hospital",
                                  style: TextStyle(
                                      fontStyle: FontStyle.italic,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                "Severe illness",
                                style: TextStyle(fontStyle: FontStyle.italic),
                              ),
                            ],
                          ),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [Text("EITHER")],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Flexible(
                                  child: Text(
                                      "2 mg/kg (${(weight * 2).toStringAsFixed(0)} mg) 6 hourly or",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold))),
                              const SizedBox(width: 4),
                              const Tooltip(
                                message:
                                    'Note max dose 100mg. Consider using neonatal doses if small or failing to thrive',
                                margin: EdgeInsets.symmetric(
                                    horizontal:
                                        20.0), // Add margin to both sides
                                child: Icon(
                                  Icons.info_outline,
                                  color: Colors.blue,
                                  size: 18,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Flexible(
                                  child: Text(
                                      "4 mg/kg (${(weight * 4).toStringAsFixed(0)} mg) 6 hourly in neonates",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold))),
                              const SizedBox(width: 4),
                              const Tooltip(
                                message: 'Neonates defined as < 28 days.',
                                margin: EdgeInsets.symmetric(
                                    horizontal:
                                        20.0), // Add margin to both sides
                                child: Icon(
                                  Icons.info_outline,
                                  color: Colors.blue,
                                  size: 18,
                                ),
                              ),
                            ],
                          ),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [Text("OR")],
                          ),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Flexible(
                                  child: Text(
                                      "Use age-based doses given IM or IV:")),
                            ],
                          ),
                          const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "<1 y: 25 mg",
                                  maxLines: 1,
                                  textAlign: TextAlign.left,
                                ),
                                Text(
                                  "1-5 y: 50 mg",
                                  maxLines: 1,
                                  textAlign: TextAlign.left,
                                ),
                                Text(
                                  "6y and over: 100mg",
                                  maxLines: 1,
                                  textAlign: TextAlign.left,
                                )
                              ]),
                          const SizedBox(
                            height: 8,
                          ),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text("Stable and improving",
                                  style:
                                      TextStyle(fontStyle: FontStyle.italic)),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Flexible(
                                  child: Text(
                                      "1mg/kg ($weight mg) IV 6 hourly or",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold))),
                              const SizedBox(width: 4),
                              const Tooltip(
                                message:
                                    'Note max dose 50mg. Can consider giving 4 hourly or as an infusion (see “Major surgery)',
                                margin: EdgeInsets.symmetric(
                                    horizontal:
                                        20.0), // Add margin to both sides
                                child: Icon(
                                  Icons.info_outline,
                                  color: Colors.blue,
                                  size: 18,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Flexible(
                                  child: Text(
                                      "2mg/kg (${weight * 2} mg) IV 6 hourly in neonates",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold))),
                              const SizedBox(width: 4),
                              const Tooltip(
                                message:
                                    'Can consider giving 4 hourly or as an infusion ',
                                margin: EdgeInsets.symmetric(
                                    horizontal:
                                        20.0), // Add margin to both sides
                                child: Icon(
                                  Icons.info_outline,
                                  color: Colors.blue,
                                  size: 18,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text("Stable and tolerating drinks / diet",
                                  style:
                                      TextStyle(fontStyle: FontStyle.italic)),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                "Stress (30mg/m²/d (${stressDose.toStringAsFixed(0)} mg/day)",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              const Tooltip(
                                message:
                                    'Note sick day dosing is in four equally divided doses. These suggested doses have been rounded to the nearest 2.5mg.',
                                margin: EdgeInsets.symmetric(
                                    horizontal:
                                        20.0), // Add margin to both sides
                                child: Icon(
                                  Icons.info_outline,
                                  color: Colors.blue,
                                  size: 18,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text("${suggestedQDSStress.join('mg , ')}mg"),
                            ],
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text("Community",
                                  style: TextStyle(
                                      fontStyle: FontStyle.italic,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text("intramuscular or initial iv dose:",
                                  style: TextStyle(
                                      fontStyle: FontStyle.normal,
                                      fontWeight: FontWeight.normal)),
                            ],
                          ),
                          const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "<1 y: 25 mg",
                                  maxLines: 1,
                                  textAlign: TextAlign.left,
                                ),
                                Text(
                                  "1-5 y: 50 mg",
                                  maxLines: 1,
                                  textAlign: TextAlign.left,
                                ),
                                Text(
                                  "6y and over: 100mg",
                                  maxLines: 1,
                                  textAlign: TextAlign.left,
                                )
                              ]),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Flexible(child: Text("■ ")),
                                  Flexible(
                                      child: Text(
                                          "Acutely unwell and unable to get IV access",
                                          textAlign: TextAlign.left)),
                                ],
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Flexible(child: Text("■ ")),
                                  Flexible(
                                    child: Text(
                                        "Acutely unwell with diarrhoea and vomiting and unable to tolerate oral treatment",
                                        textAlign: TextAlign.left),
                                  )
                                ],
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Flexible(child: Text("■ ")),
                                  Flexible(
                                    child: Text(
                                        "Reduced responsiveness or loss of consciousness.",
                                        textAlign: TextAlign.left),
                                  )
                                ],
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Flexible(child: Text("■ ")),
                                  Flexible(
                                    child: Text(
                                        "Hypoglycaemic or new onset seizure in known or suspected adrenal insufficiency.",
                                        textAlign: TextAlign.left),
                                  )
                                ],
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("■ "),
                                  Text("Fracture / significant burn",
                                      textAlign: TextAlign.left),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          const Divider(
                              color: Colors.grey, height: 1), // Thin black line
                          Text(
                            steroidText,
                            style: const TextStyle(fontWeight: FontWeight.w300),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          const Wrap(
                            children: [
                              Text(
                                "For more detailed guidance, view the British Society of Paediatric Endocrinology and Diabetes website (https://www.bsped.org.uk/adrenal-insufficiency)",
                                style:
                                    TextStyle(fontSize: 10, color: Colors.grey),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("OK"))
              ],
            );
          });
    }
  }

  bool isBsaValid() {
    if (_bsaController.text.isEmpty) return false;
    return true;
  }

  bool isWeightValid() {
    if (_weightController.text.isEmpty) return false;
    return true;
  }

  bool areSteroidsValid() {
    if (_existingSteroids) {
      if (_selectedGlucocorticoid == null) return false;
      if (_steroidDoseController.text.isEmpty) return false;
      return true;
    }
    return true;
  }

  bool _formComplete() {
    return areSteroidsValid() == (isBsaValid() == isWeightValid());
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
                  Visibility(
                    visible: _showInfoBox,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12.0, vertical: 8.0),
                        // Adjust padding
                        decoration: BoxDecoration(
                          color: Colors.lightBlueAccent[100],
                          borderRadius: BorderRadius.circular(8.0),
                          border: Border.all(
                            color: Colors.lightBlueAccent,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment
                              .start, // Align items to the top
                          children: <Widget>[
                            // Info Icon (at the beginning)
                            Padding(
                              padding: const EdgeInsets.only(
                                  right: 8.0,
                                  top: 2.0), // Adjust padding for alignment
                              child: Icon(
                                Icons.info_outline,
                                color: Colors.blue[700],
                                // Choose a suitable color for the icon
                                size: 20,
                              ),
                            ),
                            // Your Text (takes up available space)
                            const Expanded(
                              child: Text(
                                'Calculate hydrocortisone maintenance and emergency doses from body surface area.',
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            // Close Icon (at the end)
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              // Add some space before the close icon
                              child: InkWell(
                                // Makes the icon clickable
                                onTap: () {
                                  setState(() {
                                    _showInfoBox =
                                        false; // Update state to hide the box
                                  });
                                },
                                borderRadius: BorderRadius.circular(12),
                                // Optional: for ripple effect shape
                                child: Icon(
                                  Icons.close,
                                  color: Colors
                                      .grey[700], // Choose a suitable color
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Weight TextFormField
                  TextFormField(
                    controller: _weightController,
                    decoration: const InputDecoration(
                      labelText: 'Weight (kg)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
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
                    controller: _bsaController,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
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
                  // body surface area checkbox and label
                  const SizedBox(
                    height: 8,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                          child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            'Existing steroids?',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(width: 8),
                          Tooltip(
                            message:
                                'If the child or young person is on steroids already, include these here. The relative potencies are listed',
                            margin: EdgeInsets.symmetric(horizontal: 20.0),
                            // Add margin to both sides
                            child: Icon(Icons.info_outline, color: Colors.blue),
                          ),
                        ],
                      )),
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
                      child: Column(children: [
                        SizedBox(
                          child: DropdownButtonFormField<Glucocorticoid>(
                            menuMaxHeight: 200,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: "Steroids (Potency)",
                            ),
                            validator: (value) {
                              if (value == null && !_existingSteroids) {
                                return "Please select a steroid";
                              }
                              return null;
                            },
                            initialValue: _selectedGlucocorticoid,
                            items: _dropdownItems.map((Glucocorticoid item) {
                              return DropdownMenuItem<Glucocorticoid>(
                                  value: item,
                                  child: SizedBox(
                                    width: 300,
                                    child:
                                        Text("${item.name} (${item.potency})"),
                                  ));
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
                            labelText: 'Total Daily Dose (mg)',
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
                      ])),
                  // Submit Button
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _formComplete() ? _submitForm : null,
                      child: const Text('Calculate Steroid Doses'),
                    ),
                  )
                ],
              )),
        )));
  }
}
