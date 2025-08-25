import 'package:endocrinologist/pages/height_prediction/rwt_final_height_prediction_page.dart';
import 'package:flutter/material.dart';
import 'package:endocrinologist/pages/height_prediction/bayley_pineau_page.dart';
import 'package:endocrinologist/pages/height_prediction/twiiii_page.dart';

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
                MaterialPageRoute(
                    builder: (context) => const BayleyPinneauPage()),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.calculate_outlined),
            title: const Text('TWIII Method (Tanner-Whitehouse)'),
            subtitle: const Text('Uses RUS bone age, height and sex.'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const TWIIIHeightPredictionPage()),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.calculate_outlined),
            title: const Text('The Roche-Wainer-Thissen (RWT) method'),
            subtitle: const Text(
                'Uses length, weight, midparent height, and bone age.'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const RWTPredictionPage()),
              );
            },
          ),
          // Add more ListTiles for other methods
        ],
      ),
    );
  }
}
