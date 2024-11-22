import 'package:endocrinologist/pages/splcllcmltab.dart';
import 'package:flutter/material.dart';


class AuxologyPage extends StatefulWidget {
  const AuxologyPage({super.key});

  @override
  State<AuxologyPage> createState() => _AuxologyPageState();
}

class _AuxologyPageState extends State<AuxologyPage> {

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 1,
        child: Scaffold(
          body: Column(
            children:[
              TabBar(
                tabs: [
                  Tab(text: "Penile/Clitoral Length",),
                ]
              ),
              Expanded(child: TabBarView(children: [FetalSPLTab()]))
            ]
        ))
    );
  }
}

