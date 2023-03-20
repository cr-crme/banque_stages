import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '/common/models/internship.dart';
import '/common/models/student.dart';
import '/common/models/teacher.dart';
import '/common/providers/internships_provider.dart';
import '/common/providers/teachers_provider.dart';

class InternshipsPage extends StatefulWidget {
  const InternshipsPage({
    super.key,
    required this.student,
  });

  final Student student;

  @override
  State<InternshipsPage> createState() => InternshipsPageState();
}

class InternshipsPageState extends State<InternshipsPage> {
  @override
  Widget build(BuildContext context) {
    final allInternships = InternshipsProvider.of(context);
    final internships = allInternships.byStudentId(widget.student.id);

    return ListView.builder(
      itemCount: internships.length,
      itemBuilder: (context, index) =>
          Selector<InternshipsProvider, Internship>(
        builder: (context, internship, _) => ExpansionPanelList(
          children: [
            ExpansionPanel(
              headerBuilder: (context, isExpanded) => ListTile(
                title: Text(
                    'Année ${internship.date.start.year}-${internship.date.end.year}. ${internship.type}'),
              ),
              body: Column(
                children: [
                  ListTile(
                    title: Text(
                        AppLocalizations.of(context)!.internship_teacherName),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Selector<TeachersProvider, Teacher>(
                      builder: (context, teacher, _) => Text(teacher.fullName),
                      selector: (context, teachers) =>
                          teachers[internship.teacherId],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
        selector: (context, internships) => internships[index],
      ),
    );
  }
}
