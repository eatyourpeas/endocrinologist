import 'package:endocrinologist/pages/genitaltab.dart';
import 'package:endocrinologist/pages/bodysurfaceareatab.dart';
import 'package:flutter/material.dart';
import '../enums/enums.dart';
import 'package:endocrinologist/pages/final_height_prediction.dart';


class AuxologyPage extends StatefulWidget {
  const AuxologyPage({super.key});

  @override
  State<AuxologyPage> createState() => _AuxologyPageState();
}

class _AuxologyPageState extends State<AuxologyPage> {

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 4,
        child: Scaffold(
          body: Column(
            children:[
              TabBar(
                isScrollable: true,
                indicatorColor: Colors.black,
                tabs: [
                  Tab(text: "Body Surface Area",),
                  Tab(text: "Penile Length",),
                  Tab(text: "Clitoral Length",),
                  Tab(text: "Final Height Prediction",)
                ]
              ),
              Expanded(child: TabBarView(children: [
                BodySurfaceAreaTab(),
                GenitalTab(initialSex: Sex.male),
                GenitalTab(initialSex: Sex.female),
                BayleyPinneauPage(),
              ]
              )),
            ]
        ))
    );
  }
}

