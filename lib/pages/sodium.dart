import 'package:endocrinologist/referencedata/saline_strengths.dart';
import 'package:flutter/material.dart';
import 'package:endocrinologist/classes/saline.dart';
import 'package:endocrinologist/calculations/salinecalculations.dart';

class _SodiumPageState extends State<SodiumPage>{
  // Global key for form state
  final _formKey = GlobalKey<FormState>();
  bool _showInfoBox = true;

  Saline? _selectedSaline;
  final List<Saline> _salines = sortedSalineStrengths(saline_strengths);

  final _plasmaSodiumController = TextEditingController();
  final _totalBodyWaterController = TextEditingController();

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      // submission is valid: run the maths...
      double infusateSodiumConcentration;
      double plasmaSodium;
      double totalBodyWater;

      double deltaSodium = 0;

      final selectedSaline = _selectedSaline?.mmolperlitre;
      if (selectedSaline == null) {
        throw Exception("The selected saline cannot be null.");
      }
      infusateSodiumConcentration = selectedSaline.toDouble();

      final _plasmaSodium = _plasmaSodiumController.text;
      final parsedPlasmaSodium = double.tryParse(_plasmaSodium);

      if (parsedPlasmaSodium == null) {
        throw Exception("The plasma sodium value cannot be null.");
      }
      plasmaSodium = parsedPlasmaSodium;

      final _totalBodyWater = _totalBodyWaterController.text;
      final parsedTotalBodyWater = double.tryParse(_totalBodyWater);
      if (parsedTotalBodyWater == null) {
        throw Exception("The total body water value cannot be null.");
      }
      totalBodyWater = parsedTotalBodyWater;

      deltaSodium = calculateDeltaSodium(
          infusateSodiumConcentration: infusateSodiumConcentration,
          plasmaSodium: plasmaSodium,
          totalBodyWater: totalBodyWater);


      // launch dialog for results
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Estimated Change in Sodium (mmol/L)"),
              content: Text("One litre of infusate should increase the plasma sodium by ${deltaSodium
                  .toStringAsFixed(2)} mmol/L"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("OK"),
                )
              ],
            );
          });
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
          children: [
            Visibility(
              visible: _showInfoBox,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0), // Adjust padding
                  decoration: BoxDecoration(
                    color: Colors.lightBlueAccent[100],
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(
                      color: Colors.lightBlueAccent,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start, // Align items to the top
                    children: <Widget>[
                      // Info Icon (at the beginning)
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0, top: 2.0), // Adjust padding for alignment
                        child: Icon(
                          Icons.info_outline,
                          color: Colors.blue[700], // Choose a suitable color for the icon
                          size: 20,
                        ),
                      ),
                      // Your Text (takes up available space)
                      const Expanded(
                        child: Text(
                          'Calculate the expected rise in plasma sodium from a single litre of infusate.',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      // Close Icon (at the end)
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0), // Add some space before the close icon
                        child: InkWell( // Makes the icon clickable
                          onTap: () {
                            setState(() {
                              _showInfoBox = false; // Update state to hide the box
                            });
                          },
                          borderRadius: BorderRadius.circular(12), // Optional: for ripple effect shape
                          child: Icon(
                            Icons.close,
                            color: Colors.grey[700], // Choose a suitable color
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              child: DropdownButtonFormField<Saline>(
                menuMaxHeight: 200,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "fluid",
                ),
                validator: (value){
                  if (value == null) {
                    return "Please select a fluid type";
                  }
                  return null;
                },
                value: _selectedSaline,
                items: _salines.map((Saline saline) {
                  return DropdownMenuItem<Saline>(
                      value: saline,
                      child: SizedBox(
                        width: 300,
                        child:Text("${saline.name} (${saline.mmolperlitre} mmol/L)"),
                      )
                  );
                }).toList(),
                onChanged: (Saline? newValue) {
                  setState(() {
                    _selectedSaline = newValue;
                  });
                },
                hint: const Text('Select a saline strength'),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _plasmaSodiumController,
              keyboardType: TextInputType.number,
              validator: (value){
                if (value == null || value.isEmpty) {
                  return "Please enter the plasma sodium value.";
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
              decoration: const InputDecoration(
                labelText: 'plasma sodium (mmol/L)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _totalBodyWaterController,
              keyboardType: TextInputType.number,
              validator: (value){
                if (value == null || value.isEmpty) {
                  return "Please enter the total body water (litres).";
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
              decoration: const InputDecoration(
                labelText: 'total body water (litres)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _submitForm,
              child: const Text('Calculate'),
            ),
          Padding( // You can keep the outer padding for spacing from other elements
            padding: const EdgeInsets.symmetric(vertical: 8.0), // Adjust vertical padding as needed
            child: Container(
              padding: const EdgeInsets.all(12.0), // Padding inside the colored box
              decoration: BoxDecoration(
                  color: Colors.amber[100], // A light amber/yellow for warning
                  borderRadius: BorderRadius.circular(8.0), // Optional: rounded corners
                  border: Border.all( // Optional: a thin border
                    color: Colors.amber[400]!,
                    width: 1,
                  )
              ),
              child: const Text(
                'Plasma sodium should rise by no more than 0.5 to 1.0 mmol/L per hour and by less than 10 to 12 mmol/L over the first 24 hours',
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black87, // Ensure text is readable on the background
                ),
              ),
            ),
          ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Reference: Baran D, Hutchinson TA. The outcome of hyponatremia in a general hospital population. Clin Nephrol. 1984;22:72–76.',
                textAlign: TextAlign.left,
                style: TextStyle(fontSize: 12),
              )),
          ]
        )
    )
    )
    ));
  }
}

class SodiumPage extends StatefulWidget {
  const SodiumPage({super.key});
  @override
  _SodiumPageState createState() => _SodiumPageState();
}