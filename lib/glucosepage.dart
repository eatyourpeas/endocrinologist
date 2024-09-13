import 'package:flutter/material.dart';

class GlucosePage extends StatefulWidget {
  const GlucosePage({super.key});
  @override
  _GlucosePageState createState() => _GlucosePageState();
}

class _GlucosePageState extends State<GlucosePage> {
  // State for the selected dropdown item
  String? _selectedItem;
  // List of dropdown items
  final List<String> _dropdownItems = ['Option 1', 'Option 2', 'Option 3'];

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
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const TextField(
              decoration: InputDecoration(
                labelText: 'Weight',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
            'Parenteral',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold), textAlign: TextAlign.left,
            ),
            const SizedBox(height: 8),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Glucose (g/100ml)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Rate (ml/hr)',
                border: OutlineInputBorder(),
              ),
            ),
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
            const Text(
              'Select an Option',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            // Select Box (Dropdown)
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(border: OutlineInputBorder(),
              ),
              value: _selectedItem,
              items: _dropdownItems.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedItem = newValue;
                });
              },
              hint: Text('Select an option'),
            ),
            const SizedBox(height: 20),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Frequency of feeds (hrs)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
          ]
      ),
    ),
    )
    );
  }
}