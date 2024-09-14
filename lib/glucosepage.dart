import 'package:flutter/material.dart';
import 'referencedata/milks.dart';
import 'milk.dart';

class GlucosePage extends StatefulWidget {
  const GlucosePage({super.key});
  @override
  _GlucosePageState createState() => _GlucosePageState();
}

class _GlucosePageState extends State<GlucosePage> {
  // Global key for form state
  final _formKey = GlobalKey<FormState>();

  // State for the selected dropdown item
  Milk? _selectedItem;
  // List of dropdown items
  final List<Milk> _dropdownItems = sortedMilks(milks);

  // Controllers for the text fields
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _glucoseController = TextEditingController();
  final TextEditingController _infusionRateController = TextEditingController();
  final TextEditingController _milkStrengthController = TextEditingController();
  final TextEditingController _volumeController = TextEditingController();

  // toggle states
  bool _showParenteralFields = false;
  bool _showEnteralFields = false;

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

            // Toggle for Parenteral fields
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
                child: const Column(
                  children: [
                    SizedBox(height: 20),
                    Text(
                      'Parenteral',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold), textAlign: TextAlign.left,
                    ),
                    SizedBox(height: 8),
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Glucose (g/100ml)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 20),
                    TextField(
                      decoration: InputDecoration(
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
                      const TextField(
                        decoration: InputDecoration(
                          labelText: 'Milk (g/100ml)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 20),
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
                      const TextField(
                        decoration: InputDecoration(
                          labelText: 'Frequency of feeds (hrs)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const TextField(
                        decoration: InputDecoration(
                          labelText: 'Feed volume (ml/kg/d)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Select Box (Dropdown)
                      SizedBox(
                        height: 50,
                        child: DropdownButtonFormField<Milk>(
                          menuMaxHeight: 200,
                          decoration: const InputDecoration(border: OutlineInputBorder()),
                          value: _selectedItem,
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
                              _selectedItem = newValue;
                            });
                          },
                          hint: const Text('Select a milk'),
                        ),
                      ),
                    ],
                  ),
                )

            ),

            const SizedBox(height: 20),
            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Action for button press
                  if (_formKey.currentState?.validate() ?? false) {
                    print('Form submitted');
                  }
                },
                child: const Text('Calculate Glucose Infusion Rate'),
              ),
            )
          ]),
      ),
    ),
    )
    );
}}
