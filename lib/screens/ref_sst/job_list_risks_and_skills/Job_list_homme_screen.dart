import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'widgets/tile_job_risk.dart';

class job_list_screen extends StatefulWidget {
  const job_list_screen({Key? key}) : super(key: key);

  static const route = "/job_list_risks_skills";

  @override
  State<job_list_screen> createState() => _Job_list_screenState();
}

class _Job_list_screenState extends State<job_list_screen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Nom métier'),
        ),
        body: ListView.builder(
          itemCount: 5,
          padding: const EdgeInsets.all(16.0),
          itemBuilder: (context, i) {
            return tile_job_risk(); // call the expansion tile constuctor list
          },
        ));
  }
}
