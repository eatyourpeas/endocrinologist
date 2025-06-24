import 'package:endocrinologist/pages/genitaltab.dart';
import 'package:flutter/material.dart';
import '../enums/enums.dart';


class AuxologyPage extends StatefulWidget {
  const AuxologyPage({super.key});

  @override
  State<AuxologyPage> createState() => _AuxologyPageState();
}

class _AuxologyPageState extends State<AuxologyPage> {

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Scaffold(
          body: Column(
            children:[
              TabBar(
                tabs: [
                  Tab(text: "Penile Length",),
                  Tab(text: "Clitoral Length",),
                ]
              ),
              Expanded(child: TabBarView(children: [
                GenitalTab(initialSex: Sex.male),
                GenitalTab(initialSex: Sex.female),
              ]
              )),
            ]
        ))
    );
  }
}

