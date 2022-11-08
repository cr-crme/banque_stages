import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './models/students_with_address.dart';
import './models/waypoints.dart';
import './widgets/routing_map.dart';
import './widgets/waypoint_card.dart';

class VisitStudentScreen extends StatefulWidget {
  const VisitStudentScreen({super.key});

  static const String route = '/visiting-students-screen';

  @override
  State<VisitStudentScreen> createState() => _VisitStudentScreenState();
}

class _VisitStudentScreenState extends State<VisitStudentScreen> {
  List<double>? _distances;

  @override
  void initState() {
    super.initState();

    _fillAllStudentsForDebug();
  }

  void _fillAllStudentsForDebug() async {
    // TODO - This should be copied from the actual student data
    final students = Provider.of<StudentsWithAddress>(context, listen: false);
    if (students.isNotEmpty) return;

    final school = await Waypoint.fromAddress(
        'École', '1400 Tillemont, Montréal',
        priority: Priority.low);

    students.add(school, notify: false);
    students.add(
        await Waypoint.fromAddress('CRME', 'CRME, Montréal',
            priority: Priority.mid),
        notify: false);
    students.add(
        await Waypoint.fromAddress('Métro', 'Métro Jarry, Montréal',
            priority: Priority.high),
        notify: false);
    students.add(
        await Waypoint.fromAddress('Café', 'Café Oui mais non, Montréal',
            priority: Priority.high),
        notify: true);
  }

  void setRouteDistances(List<double>? legs) {
    _distances = legs;
    setState(() {});
  }

  void addStudent(int indexInProvider) {
    final students = Provider.of<StudentsWithAddress>(context, listen: false);
    final studentsToVisit =
        Provider.of<SelectedStudentForItinerary>(context, listen: false);

    studentsToVisit.add(students[indexInProvider].copyWith());
    setState(() {});
  }

  void removeStudent(int indexInStudent) {
    final studentsToVisit =
        Provider.of<SelectedStudentForItinerary>(context, listen: false);

    studentsToVisit.remove(indexInStudent);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Choix de l\'itinéraire')),
      body: SingleChildScrollView(
        physics: const ScrollPhysics(),
        child: Column(
          children: [
            _map(),
            const SizedBox(height: 10),
            _Distance(_distances),
            const SizedBox(height: 10),
            _studentsToVisitWidget(context),
          ],
        ),
      ),
    );
  }

  Widget _map() {
    return SizedBox(
        height: MediaQuery.of(context).size.height * 0.5,
        child: RoutingMap(
          onClickWaypointCallback: addStudent,
          onComputedDistancesCallback: setRouteDistances,
        ));
  }

  Widget _studentsToVisitWidget(BuildContext context) {
    final studentsToVisit =
        Provider.of<SelectedStudentForItinerary>(context, listen: false);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('Étudiants à visiter', style: TextStyle(fontSize: 20)),
        const SizedBox(height: 8),
        if (studentsToVisit.isNotEmpty)
          ReorderableListView.builder(
            onReorder: (oldIndex, newIndex) {
              studentsToVisit.move(oldIndex, newIndex);
            },
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemBuilder: (context, index) {
              final way = studentsToVisit[index];
              return WaypointCard(
                key: ValueKey(way.id),
                name: way.title,
                waypoint: way,
                onDelete: () => removeStudent(index),
              );
            },
            itemCount: studentsToVisit.length,
          ),
      ],
    );
  }
}

class _Distance extends StatefulWidget {
  const _Distance(
    this.distances, {
    super.key,
  });

  final List<double>? distances;
  @override
  State<_Distance> createState() => __DistanceState();
}

class __DistanceState extends State<_Distance> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    if (widget.distances == null) return Container();

    return GestureDetector(
      onTap: () {
        _isExpanded = !_isExpanded;
        setState(() {});
      },
      child: Card(
        elevation: 5,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.distances!.isNotEmpty)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                    child: Text(
                        'Distance totale : '
                        '${(widget.distances!.reduce((a, b) => a + b).toDouble() / 1000).toStringAsFixed(1)}km',
                        style: const TextStyle(fontSize: 17)),
                  ),
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.grey[700],
                  ),
                ],
              ),
            if (_isExpanded) ..._distancesToWidget(widget.distances!)
          ],
        ),
      ),
    );
  }

  List<Widget> _distancesToWidget(List<double?> distances) {
    final studentsToVisit =
        Provider.of<SelectedStudentForItinerary>(context, listen: false);

    List<Widget> out = [];
    if (distances.length + 1 != studentsToVisit.length) return out;

    for (int i = 0; i < distances.length; i++) {
      final distance = distances[i];
      final startingPoint = studentsToVisit[i];
      final endingPoint = studentsToVisit[i + 1];

      out.add(Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 2.0),
        child: Text(
            '${startingPoint.title} / ${endingPoint.title} : ${(distance! / 1000).toStringAsFixed(1)}km'),
      ));
    }

    return out;
  }
}
