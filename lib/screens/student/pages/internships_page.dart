import 'package:flutter/material.dart';

import '/common/models/internship.dart';
import '/common/models/student.dart';
import '/common/providers/internships_provider.dart';
import '/common/widgets/sub_title.dart';
import 'widgets/internship_details.dart';
import 'widgets/internship_skills.dart';

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
  final Map<String, bool> _expanded = {};

  void _prepareExpander(List<Internship> internships) {
    if (_expanded.length != internships.length) {
      for (final internship in internships) {
        _expanded[internship.id] = internship.isActive;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final allInternships = InternshipsProvider.of(context);
    final internships = allInternships.byStudentId(widget.student.id);
    _prepareExpander(internships);

    return ListView.builder(
      itemCount: internships.length,
      itemBuilder: (context, index) {
        final internship = internships[internships.length - index - 1];
        return ExpansionPanelList(
          expansionCallback: (int panelIndex, bool isExpanded) =>
              setState(() => _expanded[internship.id] = !isExpanded),
          children: [
            ExpansionPanel(
              canTapOnHeader: true,
              isExpanded: _expanded[internship.id]!,
              headerBuilder: (context, isExpanded) => ListTile(
                title: SubTitle(
                  'Année ${internship.date.start.year}${internship.date.end.year != internship.date.start.year ? '-${internship.date.end.year}' : ''}',
                  top: 0,
                  left: 0,
                  bottom: 0,
                ),
              ),
              body: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InternshipDetails(internship: internship),
                    InternshipSkills(internship: internship),
                  ]),
            ),
          ],
        );
      },
    );
  }
}
