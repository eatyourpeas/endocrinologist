import 'dart:developer';

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
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
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
        title: const Text("The Paediatric Endocrinologist"),
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
          Center(child: Text("Auxology")),
        ],
      ),
    ),
    );
  }
}


