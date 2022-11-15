import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'widgets/tile_job_risk.dart';

class JobListScreen extends StatefulWidget {
  final String result;
  const JobListScreen({super.key, required this.result});

  static const route = "/job_list_risks_skills";
  @override
  State<JobListScreen> createState() => _Job_list_screenState();
}

class _Job_list_screenState extends State<JobListScreen> {
  bool switch_value = true;

  get onChanged => null;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.result
          ),
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
