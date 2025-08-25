import 'package:flutter/material.dart';
import 'package:endocrinologist/enums/enums.dart'; // Assuming your Sex enum is here
import 'package:endocrinologist/pages/genitaltab.dart';

class GenitalSizePage extends StatefulWidget {
  const GenitalSizePage({super.key});

  @override
  State<GenitalSizePage> createState() => _GenitalSizePageState();
}

class _GenitalSizePageState extends State<GenitalSizePage> {
  Sex _selectedSex = Sex.male; // Default to male

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SegmentedButton<Sex>(
            segments: const <ButtonSegment<Sex>>[
              ButtonSegment<Sex>(
                  value: Sex.male, label: Text('Male'), icon: Icon(Icons.male)),
              ButtonSegment<Sex>(
                  value: Sex.female,
                  label: Text('Female'),
                  icon: Icon(Icons.female)),
            ],
            selected: <Sex>{_selectedSex},
            onSelectionChanged: (Set<Sex> newSelection) {
              setState(() {
                _selectedSex = newSelection.first;
              });
            },
            style: SegmentedButton.styleFrom(
              visualDensity: VisualDensity(horizontal: -2, vertical: -2),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
              key: ValueKey(_selectedSex),
              child: GenitalTab(initialSex: _selectedSex)),
        ],
      ),
    );
  }
}

// Placeholder for your calculator widgets (replace with your actual implementations)
class PenileLengthCalculator extends StatelessWidget {
  const PenileLengthCalculator({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Penile Length Calculator UI'));
    // This would be the content previously in GenitalTab(initialSex: Sex.male)
    // but without the TabBar context.
  }
}

class ClitoralLengthCalculator extends StatelessWidget {
  const ClitoralLengthCalculator({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Clitoral Length Calculator UI'));
    // This would be the content previously in GenitalTab(initialSex: Sex.female)
  }
}
