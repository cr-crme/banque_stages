import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './models/students_with_address.dart';
import './models/waypoints.dart';
import './widgets/routing_map.dart';
import './widgets/waypoint_card.dart';

class VisitStudentScreen extends StatefulWidget {
  const VisitStudentScreen({super.key});

  static const String route = "/visiting-students-screen";

  @override
  State<VisitStudentScreen> createState() => _VisitStudentScreenState();
}

class _VisitStudentScreenState extends State<VisitStudentScreen> {
  @override
  void initState() {
    super.initState();
    _createStudentsForDebug();
  }

  void _createStudentsForDebug() async {
    final students = Provider.of<StudentsWithAddress>(context, listen: false);
    if (students.isNotEmpty) return;

    final school = await Waypoint.fromAddress(
        "École (départ)", "1400 Tillemont, Montréal");

    // TODO - This should be copied from the actual student data
    students.add(school, notify: false);
    students.add(
        await Waypoint.fromAddress("CRME", "CRME, Montréal",
            isActivated: false),
        notify: false);
    students.add(await Waypoint.fromAddress("Métro", "Métro Jarry, Montréal"),
        notify: false);
    students.add(
        await Waypoint.fromAddress("Café", "Café Oui mais non, Montréal"),
        notify: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Choix de l\'itinéraire')),
      body: SingleChildScrollView(
        physics: const ScrollPhysics(),
        child: Consumer<StudentsWithAddress>(
            child: const RoutingMap(),
            builder: (context, students, static) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                      height: MediaQuery.of(context).size.height * 0.5,
                      child: static!),
                  const SizedBox(height: 10),
                  const Text("Étudiants à visiter",
                      style: TextStyle(fontSize: 20)),
                  const SizedBox(height: 8),
                  if (students.isNotEmpty)
                    WaypointCard(
                      name: students[0].title,
                      waypoint: students[0],
                      canMove: false,
                    ),
                  if (students.isNotEmpty)
                    ReorderableListView.builder(
                      onReorder: (oldIndex, newIndex) {
                        students.move(oldIndex + 1, newIndex + 1);
                        setState(() {});
                      },
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        int studentIndex = index + 1;
                        final way = students[studentIndex];
                        return WaypointCard(
                            key: ValueKey(way.toString()),
                            name: way.title,
                            waypoint: way,
                            onTap: () {
                              students[studentIndex] =
                                  way.copyWith(isActivated: !way.isActivated);
                            });
                      },
                      itemCount: students.length - 1,
                    ),
                ],
              );
            }),
      ),
    );
  }
}
