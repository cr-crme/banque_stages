import 'package:crcrme_banque_stages/common/models/student.dart';
import 'package:crcrme_banque_stages/common/models/visiting_priority.dart';
import 'package:crcrme_banque_stages/common/providers/enterprises_provider.dart';
import 'package:crcrme_banque_stages/common/providers/internships_provider.dart';
import 'package:crcrme_banque_stages/common/providers/schools_provider.dart';
import 'package:crcrme_banque_stages/common/providers/students_provider.dart';
import 'package:crcrme_banque_stages/common/providers/teachers_provider.dart';
import 'package:crcrme_banque_stages/screens/visiting_students/models/all_itineraries.dart';
import 'package:crcrme_banque_stages/screens/visiting_students/models/itinerary.dart';
import 'package:crcrme_banque_stages/screens/visiting_students/models/waypoints.dart';
import 'package:crcrme_banque_stages/screens/visiting_students/widgets/routing_map.dart';
import 'package:crcrme_banque_stages/screens/visiting_students/widgets/waypoint_card.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ItineraryScreen extends StatefulWidget {
  const ItineraryScreen({super.key});

  @override
  State<ItineraryScreen> createState() => _ItineraryScreenState();
}

class _ItineraryScreenState extends State<ItineraryScreen> {
  List<double>? _distances;

  final _dateFormat = DateFormat('dd_MM_yyyy');
  DateTime _currentDate = DateTime.now();
  String get _currentDateAsString => _dateFormat.format(_currentDate);

  @override
  void initState() {
    super.initState();

    _fillAllWaypoints();
    _initializeItinariesForCurrentDate();
  }

  void _initializeItinariesForCurrentDate() {
    final itineraries = AllItineraries.of(context, listen: false);
    if (!itineraries.containsKey(_currentDateAsString)) {
      itineraries.add(Itinerary(), key: _currentDateAsString, notify: false);
    }
  }

  void _fillAllWaypoints() async {
    final teacher = TeachersProvider.of(context, listen: false).currentTeacher;
    final school =
        SchoolsProvider.of(context, listen: false).fromId(teacher.schoolId);
    final enterprises = EnterprisesProvider.of(context, listen: false);
    final waypoints = AllStudentsWaypoints.of(context, listen: false);
    final internships = InternshipsProvider.of(context, listen: false);
    final students =
        (await StudentsProvider.getMySupervizedStudents(context, listen: false))
            .map<Student>((e) => e);
    waypoints.clear(notify: false);

    // Add the school as the first waypoint
    waypoints.add(
      await Waypoint.fromAddress(
        'École',
        school.address.toString(),
        priority: VisitingPriority.school,
      ),
      notify: false,
    );

    // Get the students from the registered students, but we copy them so
    // we don't mess with them
    for (final student in students) {
      final studentInterships = internships.byStudentId(student.id);
      if (studentInterships.isEmpty) continue;
      final intership = studentInterships.last;

      waypoints.add(
        await Waypoint.fromAddress(
          '${student.firstName} ${student.lastName[0]}.',
          enterprises.fromId(intership.enterpriseId).address.toString(),
          priority: intership.visitingPriority,
        ),
        notify: false, // Only notify at the end
      );
    }
    waypoints.notifyListeners();
  }

  void setRouteDistances(List<double>? legs) {
    _distances = legs;
    setState(() {});
  }

  void addStopToCurrentItinerary(int indexInWaypoints) {
    final itineraries = AllItineraries.of(context, listen: false);
    final waypoints = AllStudentsWaypoints.of(context, listen: false);
    final itinerary = itineraries[_currentDateAsString]!;

    itinerary.add(waypoints[indexInWaypoints].copyWith());
    itineraries.replace(itinerary, key: _currentDateAsString, notify: true);
    setState(() {});
  }

  void removeStopToCurrentItinerary(int indexInItinerary) {
    final itineraries = AllItineraries.of(context, listen: false);
    final itinerary = itineraries[_currentDateAsString]!;

    itinerary.remove(indexInItinerary);
    itineraries.replace(itinerary, key: _currentDateAsString, notify: true);
    setState(() {});
  }

  // TODO: Add the enterprise in the Provider and make the provider a firebase
  // TODO: Check if the itinerary is computed when changing back date
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Itinéraire des visites')),
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
            'Faire l\'itinéraire du\n${DateFormat('d MMMM yyyy', 'fr_CA').format(_currentDate)}',
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
    final itineraries = AllItineraries.of(context, listen: false);
    itineraries.forceNotify();
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
    final itineraries = AllItineraries.of(context, listen: false);
    final itinerary = itineraries[_currentDateAsString];
    if (itinerary == null) return Container();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 8),
        if (itinerary.isNotEmpty)
          ReorderableListView.builder(
            onReorder: (oldIndex, newIndex) {
              itinerary.move(oldIndex, newIndex);
              itineraries.forceNotify();
              setState(() {});
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
                        'Kilométrage : '
                        '${(widget.distances!.reduce((a, b) => a + b).toDouble() / 1000).toStringAsFixed(1)}km',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 16,
                            fontWeight: FontWeight.w700)),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      border:
                          Border.all(color: Theme.of(context).disabledColor),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Icon(
                      _isExpanded ? Icons.expand_less : Icons.expand_more,
                      color: Theme.of(context).disabledColor,
                    ),
                  ),
                ],
              ),
            if (_isExpanded) ..._distancesTo(widget.distances!)
          ],
        ),
      ),
    );
  }

  List<Widget> _distancesTo(List<double?> distances) {
    final itineraries = AllItineraries.of(context, listen: false);
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
