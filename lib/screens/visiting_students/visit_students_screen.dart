import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'models/itinerary.dart';
import 'models/all_itineraries.dart';
import './models/waypoints.dart';
import './widgets/routing_map.dart';
import './widgets/waypoint_card.dart';
// import '../../../common/providers/students_provider.dart';
import '../../../common/models/visiting_priority.dart';

class VisitStudentScreen extends StatefulWidget {
  const VisitStudentScreen({super.key});

  static const String route = '/visiting-students-screen';

  @override
  State<VisitStudentScreen> createState() => _VisitStudentScreenState();
}

class _VisitStudentScreenState extends State<VisitStudentScreen> {
  List<double>? _distances;

  final _dateFormat = DateFormat("dd_MM_yyyy");
  DateTime _currentDate = DateTime.now();
  String get _currentDateAsString => _dateFormat.format(_currentDate);

  @override
  void initState() {
    super.initState();

    _fillAllWaypoints();
    _initializeItinariesForCurrentDate();
  }

  void _initializeItinariesForCurrentDate() {
    final itineraries = Provider.of<AllItineraries>(context, listen: false);
    if (!itineraries.containsKey(_currentDateAsString)) {
      itineraries.add(Itinerary(), key: _currentDateAsString, notify: false);
    }
  }

  void _fillAllWaypoints() async {
    final waypoints = Provider.of<AllStudentsWaypoints>(context, listen: false);
    waypoints.clear(notify: false);

    // Get the students from the registered students, but we copy them so
    // we don't mess with them
    // TODO - Comment the next lines and uncomment these after when the software is populated with students

    waypoints.add(
        await Waypoint.fromAddress('École', '1400 Tillemont, Montréal',
            priority: VisitingPriority.none),
        notify: false);
    waypoints.add(
        await Waypoint.fromAddress('CRME', 'CRME, Montréal',
            priority: VisitingPriority.mid),
        notify: false);
    waypoints.add(
        await Waypoint.fromAddress('Métro', 'Métro Jarry, Montréal',
            priority: VisitingPriority.high),
        notify: false);
    waypoints.add(
        await Waypoint.fromAddress('Café', 'Café Oui mais non, Montréal',
            priority: VisitingPriority.high),
        notify: true);

    // final studentsProvided =
    //     Provider.of<StudentsProvider>(context, listen: false);
    // for (final s in studentsProvided) {
    //   waypoints.add(
    //       await Waypoint.fromAddress(
    //         s.name,
    //         s.address,
    //         priority: VisitingPriority.low,
    //         showTitle: true,
    //       ),
    //       notify: false);
    // }
  }

  void setRouteDistances(List<double>? legs) {
    _distances = legs;
    setState(() {});
  }

  void addStopToCurrentItinerary(int indexInWaypoints) {
    final itineraries = Provider.of<AllItineraries>(context, listen: false);
    final waypoints = Provider.of<AllStudentsWaypoints>(context, listen: false);
    final itinerary = itineraries[_currentDateAsString]!;

    itinerary.add(waypoints[indexInWaypoints].copyWith());
    itineraries.replace(itinerary, key: _currentDateAsString, notify: true);
    setState(() {});
  }

  void removeStopToCurrentItinerary(int indexInItinerary) {
    final itineraries = Provider.of<AllItineraries>(context, listen: false);
    final itinerary = itineraries[_currentDateAsString]!;

    itinerary.remove(indexInItinerary);
    itineraries.replace(itinerary, key: _currentDateAsString, notify: true);
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
            _showDate(),
            _map(),
            _Distance(_distances, currentDate: _currentDateAsString),
            const SizedBox(height: 20),
            _studentsToVisitWidget(context),
          ],
        ),
      ),
    );
  }

  Widget _showDate() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Text(
            'Itinéraire du\n${DateFormat('d MMMM yyyy', 'fr_CA').format(_currentDate)}',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: _showDatePicker,
                child: Container(
                    decoration: BoxDecoration(
                        color: Colors.grey[600], shape: BoxShape.circle),
                    child: const Padding(
                      padding: EdgeInsets.all(6.0),
                      child: Icon(
                        Icons.calendar_month,
                        size: 30,
                      ),
                    )),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showDatePicker() async {
    final newDate = await showDialog(
        context: context,
        builder: (context) {
          return DatePickerDialog(
              initialDate: _currentDate,
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 31)));
        });

    if (newDate == null || !mounted) return;

    _currentDate = newDate;
    _initializeItinariesForCurrentDate();
    // Force update of all widgets

    final itineraries = Provider.of<AllItineraries>(context, listen: false);
    final itinerary = itineraries[_currentDateAsString];
    debugPrint(_currentDateAsString);
    itineraries.replace(itinerary!, key: _currentDateAsString);
    setState(() {});
  }

  Widget _map() {
    return SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height * 0.5,
        child: RoutingMap(
          currentDate: _currentDateAsString,
          onClickWaypointCallback: addStopToCurrentItinerary,
          onComputedDistancesCallback: setRouteDistances,
        ));
  }

  Widget _studentsToVisitWidget(BuildContext context) {
    final itineraries = Provider.of<AllItineraries>(context, listen: false);
    final itinerary = itineraries[_currentDateAsString];
    if (itinerary == null) return Container();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('Résumé de l\'itinéraire', style: TextStyle(fontSize: 20)),
        const SizedBox(height: 8),
        if (itinerary.isNotEmpty)
          ReorderableListView.builder(
            onReorder: (oldIndex, newIndex) {
              itinerary.move(oldIndex, newIndex);
            },
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemBuilder: (context, index) {
              final way = itinerary[index];
              return WaypointCard(
                key: ValueKey(way.id),
                name: way.title,
                waypoint: way,
                onDelete: () => removeStopToCurrentItinerary(index),
              );
            },
            itemCount: itinerary.length,
          ),
      ],
    );
  }
}

class _Distance extends StatefulWidget {
  const _Distance(this.distances, {required this.currentDate});

  final List<double>? distances;
  final String currentDate;

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
      behavior: HitTestBehavior.opaque, // Make the full box clickable
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
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
    final itineraries = Provider.of<AllItineraries>(context, listen: false);
    final itinerary = itineraries[widget.currentDate]!;

    List<Widget> out = [];
    if (distances.length + 1 != itinerary.length) return out;

    for (int i = 0; i < distances.length; i++) {
      final distance = distances[i];
      final startingPoint = itinerary[i];
      final endingPoint = itinerary[i + 1];

      out.add(Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 2.0),
        child: Text(
            '${startingPoint.title} / ${endingPoint.title} : ${(distance! / 1000).toStringAsFixed(1)}km'),
      ));
    }

    return out;
  }
}
