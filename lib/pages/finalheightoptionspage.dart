import 'package:flutter/material.dart';
import 'package:endocrinologist/pages/bayley_pineau_page.dart';
import 'package:endocrinologist/pages/twiiii_page.dart';


class FinalHeightSelectionPage extends StatelessWidget {
  const FinalHeightSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Final Height Method'),
        // backgroundColor: Theme.of(context).colorScheme.surfaceVariant, // Optional: for visual distinction
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            leading: const Icon(Icons.calculate_outlined),
            title: const Text('Bayley-Pinneau Method'),
            subtitle: const Text('Predicts adult height based on bone age.'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BayleyPinneauPage()),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.calculate_outlined),
            title: const Text('TW3 Method (Tanner-Whitehouse III)'),
            subtitle: const Text('Uses RUS bone age for height prediction.'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TWIIIHeightPredictionPage()),
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('TW3 Method page not yet implemented.')),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.calculate_outlined),
            title: const Text('Another Method'),
            subtitle: const Text('Description of another final height prediction method.'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Replace with navigation to your other method page
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(builder: (context) => const AnotherFinalHeightPage()),
              // );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Another method page not yet implemented.')),
              );
            },
          ),
          // Add more ListTiles for other methods
        ],
      ),
    );
  }
}
