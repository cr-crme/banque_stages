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

    for (final internship
        in widget.enterprise.internships(context, listen: false)) {
      _expanded[internship.id] = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final internships = widget.enterprise.internships(context, listen: false);

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
          ExpansionPanelList(
            expansionCallback: (panelIndex, isExpanded) => setState(
                () => _expanded[internships[panelIndex].id] = !isExpanded),
            children: internships
                .map(
                  (internship) => ExpansionPanel(
                    canTapOnHeader: true,
                    isExpanded: _expanded[internship.id]!,
                    headerBuilder: (context, isExpanded) => ListTile(
                      leading: Text(
                          '${internship.date.start.year}-${internship.date.end.year}'),
                      title: Text(widget.enterprise.jobs[internship.jobId]
                          .specialization.idWithName),
                    ),
                    body: Container(), // TODO reintroduce
                    // Column(
                    //   children: [
                    //     ListTile(
                    //       leading: Text(internship.program),
                    //       title: Selector<TeachersProvider, String>(
                    //         builder: (context, name, _) => Text(name),
                    //         selector: (context, teachers) =>
                    //             teachers[internship.teacherId].fullName,
                    //       ),
                    //     ),
                    //     Selector<StudentsProvider, String>(
                    //       builder: (context, name, _) => Text(name),
                    //       selector: (context, students) =>
                    //           students[internship.studentId].fullName,
                    //     ),
                    //   ],
                    // ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}
