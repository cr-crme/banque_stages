import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '/common/models/enterprise.dart';
import '/common/models/internship.dart';
import '/common/providers/internships_provider.dart';
import '/common/providers/students_provider.dart';
import '/common/providers/teachers_provider.dart';
import '/router.dart';

class InternshipsPage extends StatefulWidget {
  const InternshipsPage({
    super.key,
    required this.enterprise,
  });

  final Enterprise enterprise;

  @override
  State<InternshipsPage> createState() => InternshipsPageState();
}

class InternshipsPageState extends State<InternshipsPage> {
  final _expanded = <String, bool>{};

  void addStage() {
    GoRouter.of(context).goNamed(
      Screens.internshipEnrollement,
      params: Screens.withId(widget.enterprise.id),
    );
  }

  @override
  void initState() {
    super.initState();

    for (final i in widget.enterprise.internshipIds) {
      _expanded[i] = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          ListTile(
            title: Text(
              'Historique des stages',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          const Divider(),
          Selector<InternshipsProvider, List<Internship>>(
            builder: (context, internships, _) => ExpansionPanelList(
              expansionCallback: (panelIndex, isExpanded) => setState(
                  () => _expanded[internships[panelIndex].id] = !isExpanded),
              children: [
                ...internships.map(
                  (internship) => ExpansionPanel(
                    canTapOnHeader: true,
                    isExpanded: _expanded[internship.id] ?? false,
                    headerBuilder: (context, isExpanded) => ListTile(
                      leading: Text(
                          '${internship.date.start.year}-${internship.date.end.year}'),
                      title: Text(widget.enterprise.jobs[internship.jobId]
                          .specialization!.idWithName),
                    ),
                    body: Column(
                      children: [
                        ListTile(
                          leading: Text(internship.program),
                          title: Selector<TeachersProvider, String>(
                            builder: (context, name, _) => Text(name),
                            selector: (context, teachers) =>
                                teachers[internship.teacherId].fullName,
                          ),
                        ),
                        Selector<StudentsProvider, String>(
                          builder: (context, name, _) => Text(name),
                          selector: (context, students) =>
                              students[internship.studentId].fullName,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            selector: (context, internships) => internships
                .where(
                  (internship) =>
                      widget.enterprise.internshipIds.contains(internship.id) &&
                      internship.date.start.isBefore(DateTime.now()) &&
                      internship.date.end.isAfter(DateTime.now()),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}
