import 'package:endocrinologist/referencedata/saline_strengths.dart';
import 'package:flutter/material.dart';
import 'package:endocrinologist/classes/saline.dart';

class _SodiumPageState extends State<SodiumPage>{
  // Global key for form state
  final _formKey = GlobalKey<FormState>();

  Saline? _selectedSaline;
  final List<Saline> _salines = sortedSalineStrengths(saline_strengths);

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
            const Text(
              'Sodium Page',
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 16),
            SizedBox(
              child: DropdownButtonFormField<Saline>(
                menuMaxHeight: 200,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Fluid",
                ),
                validator: (value){
                  // if (value == null && !_showCustomMilkCarbsField) {
                  //   return "Please select a milk";
                  // }
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