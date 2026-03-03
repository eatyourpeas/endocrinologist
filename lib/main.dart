// framework imports
// local imports
import 'package:endocrinologist/pages/auxology.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// third party imports
import 'package:google_fonts/google_fonts.dart';
import 'package:logging/logging.dart';

import 'pages/glucosepage.dart';

void main() {
  _setupLogging();
  runApp(const Endocrinologist());
}

void _setupLogging() {
  Logger.root.level = kDebugMode ? Level.ALL : Level.WARNING;
  Logger.root.onRecord.listen((record) {
    print(
        '${record.level.name}: ${record.time}: ${record.loggerName}: ${record.message}');
    if (record.error != null) {
      print('  ERROR: ${record.error}');
    }
    if (record.stackTrace != null && record.level.value >= Level.SEVERE.value) {
      print('  STACKTRACE: ${record.stackTrace}');
    }
  });

  final mainLogger = Logger('AppMain');
  mainLogger.info('Logging initialized. Debug mode: $kDebugMode');
}

class Endocrinologist extends StatelessWidget {
  const Endocrinologist({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    const bool showDisclaimer = true;
    return MaterialApp(
      title: 'The Endocrinologist',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
        useMaterial3: true,
      ),
      builder: (context, child) {
        Widget appContent = child ?? const SizedBox.shrink();

        if (showDisclaimer) {
          return Column(
            // Use a Column to stack the banner above the app content
            children: [
              Material(
                // Wrap with Material for theming and elevation if needed
                elevation: 2.0, // Optional: adds a slight shadow
                color: Colors.lightBlueAccent, // Banner background color
                child: Container(
                  width: double.infinity, // Take full width
                  padding: const EdgeInsets.symmetric(
                      vertical: 6.0, horizontal: 16.0),
                  alignment: Alignment.center,
                  child: const Text(
                    "TESTING - NOT FOR CLINICAL USE",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12, // Adjust font size as needed
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              Expanded(
                // Ensure the rest of the app content takes the remaining space
                child: appContent,
              ),
            ],
          );
        }
      },
      home: const EndocrinologyTabBars(),
    );
  }
}

class EndocrinologyTabBars extends StatelessWidget {
  const EndocrinologyTabBars({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "The Paediatric Endocrinologist",
            style: GoogleFonts.ibmPlexSans(),
          ),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.science), text: "Glucose"),
              // Tab(icon: Icon(Icons.medication), text: "Steroids"),
              Tab(icon: Icon(Icons.straighten), text: "Auxology"),
              // Tab(icon: Icon(Icons.grain), text: "Sodium"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            GlucosePage(),
            // SteroidPage(),
            AuxologyPage(),
            // SodiumPage(),
          ],
        ),
      ),
    );
  }
}
