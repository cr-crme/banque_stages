import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '/common/models/enterprise.dart';
import '/common/models/internship.dart';
import '/common/models/student.dart';
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

  Widget _dateBuild(Internship internship) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Column(
          children: [
            const Text('Début :'),
            Text(
              '${internship.date.start.year.toString().padLeft(4, '0')}-'
              '${internship.date.start.month.toString().padLeft(2, '0')}-'
              '${internship.date.start.day.toString().padLeft(2, '0')}',
            )
          ],
        ),
        Column(
          children: [
            const Text('Fin :'),
            Text(
              '${internship.date.end.year.toString().padLeft(4, '0')}-'
              '${internship.date.end.month.toString().padLeft(2, '0')}-'
              '${internship.date.end.day.toString().padLeft(2, '0')}',
            ),
          ],
        )
      ],
    );
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
            children: internships.map(
              (internship) {
                final specialization =
                    widget.enterprise.jobs[internship.jobId].specialization;
                final teacher =
                    TeachersProvider.of(context).fromId(internship.teacherId);
                final student =
                    StudentsProvider.of(context).fromId(internship.studentId);

                return ExpansionPanel(
                  canTapOnHeader: true,
                  isExpanded: _expanded[internship.id]!,
                  headerBuilder: (context, isExpanded) => ListTile(
                    leading: Text(internship.date.start.year.toString()),
                    title: Text(specialization.idWithName),
                  ),
                  body: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            'Stagiaire : ${student.fullName} (${student.program.title})'),
                        const SizedBox(height: 8),
                        Text(
                            'Professeur\u00b7e en charge : ${teacher.fullName}'),
                        const SizedBox(height: 10),
                        _dateBuild(internship),
                        const SizedBox(height: 15),
                      ],
                    ),
                  ),
                );
              },
            ).toList(),
          ),
        ],
      ),
    );
  }
}
