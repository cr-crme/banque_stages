import 'package:flutter/material.dart';

import 'widgets/tile_job_risk.dart';

class JobListScreen extends StatefulWidget {
  const JobListScreen({super.key, required this.id});

  final String id;

  @override
  State<JobListScreen> createState() => _JobListScreenState();
}

class _JobListScreenState extends State<JobListScreen> {
  bool switch_value = true;

  get onChanged => null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Nom métier'),
        ),
        body: ListView(children: [
          Text("Afficher l\'analyse du métier"),
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Par risque"),
                Switch(
                    value: switch_value,
                    onChanged: (bool value) {
                      // This is called when the user toggles the switch.
                      setState(() {
                        switch_value = value;
                      });
                    }),
                Text("Par compétence")
              ],
            ),
          ),
          ListView.builder(
            physics: ScrollPhysics(),
            shrinkWrap: true,
            itemCount: 5,
            padding: const EdgeInsets.all(16.0),
            itemBuilder: (context, i) {
              return tile_job_risk();
              // call the expansion tile constuctor list
            },
          )
        ]));
  }
}
