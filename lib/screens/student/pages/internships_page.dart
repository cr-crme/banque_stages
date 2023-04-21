import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '/common/models/internship.dart';
import '/common/models/student.dart';
import '/common/providers/enterprises_provider.dart';
import '/common/providers/internships_provider.dart';
import '/common/widgets/sub_title.dart';
import 'widgets/internship_details.dart';
import 'widgets/internship_documents.dart';
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
  final List<GlobalKey<InternshipDetailsState>> detailKeys = [];

  void _prepareExpander(List<Internship> internships) {
    if (_expanded.length != internships.length) {
      for (final internship in internships) {
        _expanded[internship.id] = internship.isActive;
      }
    }

    if (detailKeys.length != internships.length) {
      detailKeys.clear();
      for (final _ in internships) {
        detailKeys.add(GlobalKey<InternshipDetailsState>());
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
                  '${DateFormat('dd MMMM yyyy', 'fr_CA').format(internship.date.start)} - '
                  '${DateFormat('dd MMMM yyyy', 'fr_CA').format(internship.date.end)}',
                  top: 0,
                  left: 0,
                  bottom: 0,
                ),
                subtitle: Text(EnterprisesProvider.of(context)
                    .fromId(internship.enterpriseId)
                    .jobs
                    .fromId(internship.jobId)
                    .specialization
                    .idWithName),
              ),
              body: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InternshipDetails(
                        key: detailKeys[index], internship: internship),
                    InternshipSkills(internship: internship),
                    InternshipDocuments(internship: internship),
                  ]),
            ),
          ],
        );
      },
    );
  }
}
