import 'package:flutter/material.dart';

class AuxologyPage extends StatefulWidget {
  const AuxologyPage({Key? key}) : super(key: key);

  @override
  State<AuxologyPage> createState() => _AuxologyPageState();
}

class _AuxologyPageState extends State<AuxologyPage> {
  final _splController = TextEditingController();
  String _result = '';

  void _calculateResult() {
    // Replace with your actual calculation logic
    double spl = double.tryParse(_splController.text) ?? 0;
    double result = spl * 1.5; // Example calculation

    setState(() {
      _result = 'Result: $result cm';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Auxology Calculator'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _splController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'SPL (cm)',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _calculateResult,
              child: const Text('Calculate'),
            ),
            const SizedBox(height: 20),
            Text(_result),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _splController.dispose();
    super.dispose();
  }
}