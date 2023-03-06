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
  void addStage() {
    GoRouter.of(context).goNamed(
      Screens.internshipEnrollement,
      params: Screens.withId(widget.enterprise.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          ListTile(
            title: Text(
              "Historique des stages",
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          const Divider(),
          Selector<InternshipsProvider, Iterable<Internship>>(
            builder: (context, internships, _) => ExpansionPanelList(
              children: [
                ...internships.map(
                  (internship) => ExpansionPanel(
                    headerBuilder: (context, isExpanded) => ListTile(
                      leading: Text(
                          "${internship.date.start.year}-${internship.date.end.year}"),
                      title: Text(widget.enterprise.jobs[internship.jobId]
                          .specialization!.idWithName),
                    ),
                    body: Column(
                      children: [
                        ListTile(
                          leading: Text(internship.type),
                          title: Selector<TeachersProvider, String>(
                            builder: (context, name, _) => Text(name),
                            selector: (context, teachers) =>
                                teachers[internship.teacherId].name,
                          ),
                        ),
                        Selector<StudentsProvider, String>(
                          builder: (context, name, _) => Text(name),
                          selector: (context, students) =>
                              students[internship.studentId].name,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            selector: (context, internships) => internships.where(
              (internship) =>
                  widget.enterprise.internshipIds.contains(internship.id) &&
                  internship.date.start.isBefore(DateTime.now()) &&
                  internship.date.end.isAfter(DateTime.now()),
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            itemCount: widget.enterprise.internshipIds.length,
            itemBuilder: (context, index) =>
                Selector<InternshipsProvider, Internship>(
              builder: (context, internship, _) => ListTile(
                title: Text(internship.id),
              ),
              selector: (context, internships) =>
                  internships[widget.enterprise.internshipIds[index]],
            ),
          ),
        ],
      ),
    );
  }
}
