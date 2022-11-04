import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/common/models/waypoints.dart';

class ChooseStudentsScreen extends StatefulWidget {
  const ChooseStudentsScreen({super.key});

  static const String route = "/visiting-students/choose-students-screen";

  @override
  State<ChooseStudentsScreen> createState() => _ChooseStudentsScreenState();
}

class _ChooseStudentsScreenState extends State<ChooseStudentsScreen> {
  @override
  void initState() {
    super.initState();
    addWaypoints();
  }

  void addWaypoints() async {
    final waypoints = Provider.of<Waypoints>(context, listen: false);
    waypoints.add(await Waypoint.fromAddress("1400 Tillemont, Montréal"));
    waypoints.add(await Waypoint.fromAddress("CRME, Montréal"));
    waypoints.add(await Waypoint.fromAddress("CRM, Montréal"));
  }

  @override
  Widget build(BuildContext context) {
    final waypoints = Provider.of<Waypoints>(context, listen: true);

    return Scaffold(
      appBar: AppBar(title: const Text('Choix de l\'itinéraire')),
      body: ListView.builder(
        itemBuilder: (context, index) => Card(
          child: Text(waypoints[index].toString()),
        ),
        itemCount: waypoints.length,
      ),
    );
  }
}
