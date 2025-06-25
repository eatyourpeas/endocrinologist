
import 'package:google_fonts/google_fonts.dart';
import 'package:endocrinologist/pages/auxology.dart';
import 'package:flutter/material.dart';
import 'pages/glucosepage.dart';
import 'pages/steroidpage.dart';

void main() {
  runApp(const Endocrinologist());
}

class Endocrinologist extends StatelessWidget {
  const Endocrinologist({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'The Endocrinologist',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
        useMaterial3: true,
      ),
      home: const EndocrinologyTabBars(),
    );
  }
}

class EndocrinologyTabBars extends StatelessWidget {
  const EndocrinologyTabBars({super.key});

  @override
  Widget build(BuildContext context){
    return DefaultTabController(length: 3, child: Scaffold(
      appBar: AppBar(
        title: Text("The Paediatric Endocrinologist", style: GoogleFonts.ibmPlexSans(),),
        bottom: const TabBar(
          tabs: [
            Tab(icon: Icon(Icons.science), text: "Glucose"),
            Tab(icon: Icon(Icons.medication), text: "Steroids"),
            Tab(icon: Icon(Icons.straighten), text: "Auxology"),
          ],
        ),
      ),
      body: const TabBarView(
        children: [
          GlucosePage(),
          SteroidPage(),
          AuxologyPage(),
        ],
      ),
    ),
    );
  }
}


