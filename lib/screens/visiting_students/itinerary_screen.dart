import 'package:crcrme_banque_stages/common/models/itinerary.dart';
import 'package:crcrme_banque_stages/common/models/student.dart';
import 'package:crcrme_banque_stages/common/models/visiting_priority.dart';
import 'package:crcrme_banque_stages/common/models/waypoints.dart';
import 'package:crcrme_banque_stages/common/providers/enterprises_provider.dart';
import 'package:crcrme_banque_stages/common/providers/internships_provider.dart';
import 'package:crcrme_banque_stages/common/providers/itineraries_provider.dart';
import 'package:crcrme_banque_stages/common/providers/schools_provider.dart';
import 'package:crcrme_banque_stages/common/providers/students_provider.dart';
import 'package:crcrme_banque_stages/common/providers/teachers_provider.dart';
import 'package:crcrme_banque_stages/screens/visiting_students/widgets/routing_map.dart';
import 'package:crcrme_banque_stages/screens/visiting_students/widgets/waypoint_card.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ItineraryMainScreen extends StatefulWidget {
  const ItineraryMainScreen({super.key});

  @override
  State<ItineraryMainScreen> createState() => _ItineraryMainScreenState();
}

class _ItineraryMainScreenState extends State<ItineraryMainScreen> {
  final List<Waypoint> _waypoints = [];

  Future<T?> _waitFor<T>(
      Function(BuildContext context, {bool listen}) providerOf) async {
    var provided = providerOf(context, listen: false);
    while (provided.isEmpty) {
      await Future.delayed(const Duration(milliseconds: 100));
      if (!mounted) return null;
      provided = providerOf(context, listen: false);
    }
    return provided;
  }

  Future<bool> _fillAllWaypoints() async {
    final teacher = TeachersProvider.of(context, listen: false).currentTeacher;
    var school = (await _waitFor<SchoolsProvider>(SchoolsProvider.of))
        ?.fromId(teacher.schoolId);
    if (!mounted || school == null) return false;

    final enterprises =
        await _waitFor<EnterprisesProvider>(EnterprisesProvider.of);
    if (!mounted || enterprises == null) return false;

    final internships = InternshipsProvider.of(context, listen: false);
    if (!mounted) return false;

    final students =
        (await StudentsProvider.getMySupervizedStudents(context, listen: false))
            .map<Student>((e) => e);
    if (!mounted) return false;

    // Add the school as the first waypoint
    _waypoints.clear();
    _waypoints.add(
      await Waypoint.fromAddress(
        'École',
        school.address.toString(),
        priority: VisitingPriority.school,
      ),
    );

    // Get the students from the registered students, but we copy them so
    // we don't mess with them
    for (final student in students) {
      final studentInterships = internships.byStudentId(student.id);
      if (studentInterships.isEmpty) continue;
      final intership = studentInterships.last;

      _waypoints.add(
        await Waypoint.fromAddress(
          '${student.firstName} ${student.lastName[0]}.',
          enterprises.fromId(intership.enterpriseId).address.toString(),
          priority: intership.visitingPriority,
        ),
      );
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Itinéraire des visites')),
      body: SingleChildScrollView(
        physics: const ScrollPhysics(),
        child: FutureBuilder(
          future: _fillAllWaypoints(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) const CircularProgressIndicator();

            return ItineraryScreen(waypoints: _waypoints);
          },
        ),
      ),
    );
  }
}

class ItineraryScreen extends StatefulWidget {
  const ItineraryScreen({super.key, required this.waypoints});

  @override
  State<ItineraryScreen> createState() => _ItineraryScreenState();
  final List<Waypoint> waypoints;
}

class _ItineraryScreenState extends State<ItineraryScreen> {
  List<double>? _distances;

  DateTime _currentDate = DateTime.now();

  void setRouteDistances(List<double>? legs) {
    _distances = legs;
    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
  }

  void addStopToCurrentItinerary(int indexInWaypoints) {
    final itineraries = ItinerariesProvider.of(context, listen: false);
    final itinerary =
        itineraries.fromDate(_currentDate) ?? Itinerary(date: _currentDate);

    itinerary.add(widget.waypoints[indexInWaypoints].copyWith());
    itineraries.replace(itinerary, notify: true);
    setState(() {});
  }

  void removeStopToCurrentItinerary(int indexInItinerary) {
    final itineraries = ItinerariesProvider.of(context, listen: false);
    final itinerary = itineraries.fromDate(_currentDate);
    if (itinerary == null) return;

    itinerary.remove(indexInItinerary);
    itineraries.replace(itinerary, notify: true);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _showDate(),
        if (widget.waypoints.isNotEmpty) _map(),
        if (widget.waypoints.isEmpty) const CircularProgressIndicator(),
        _Distance(_distances, currentDate: _currentDate),
        const SizedBox(height: 20),
        _studentsToVisitWidget(context),
      ],
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
                        color: Theme.of(context).primaryColor,
                        shape: BoxShape.circle),
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

    // Force update of all widgets
    final itineraries = ItinerariesProvider.of(context, listen: false);
    itineraries.forceNotify();
    setState(() {});
  }

  Widget _map() {
    return SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height * 0.5,
        child: RoutingMap(
          waypoints: widget.waypoints,
          currentDate: _currentDate,
          onClickWaypointCallback: addStopToCurrentItinerary,
          onComputedDistancesCallback: setRouteDistances,
        ));
  }

  Widget _studentsToVisitWidget(BuildContext context) {
    final itineraries = ItinerariesProvider.of(context, listen: false);
    if (itineraries.isEmpty || !itineraries.hasDate(_currentDate)) {
      return Container();
    }

    final itinerary = itineraries.fromDate(_currentDate)!;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 8),
        if (itinerary.isNotEmpty)
          ReorderableListView.builder(
            onReorder: (oldIndex, newIndex) {
              itinerary.move(oldIndex, newIndex);
              itineraries.replace(itinerary);
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
  final DateTime currentDate;

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
    final itineraries = ItinerariesProvider.of(context, listen: false);
    final itinerary = itineraries.fromDate(widget.currentDate);
    if (itinerary == null) return [];

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
