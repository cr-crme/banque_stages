import 'package:common/models/internships/internship.dart';
import 'package:common/models/persons/student.dart';
import 'package:common_flutter/providers/enterprises_provider.dart';
import 'package:common_flutter/providers/internships_provider.dart';
import 'package:common_flutter/providers/teachers_provider.dart';
import 'package:crcrme_banque_stages/common/extensions/internship_extension.dart';
import 'package:crcrme_banque_stages/common/widgets/sub_title.dart';
import 'package:crcrme_material_theme/crcrme_material_theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'widgets/internship_details.dart';
import 'widgets/internship_documents.dart';
import 'widgets/internship_quick_access.dart';
import 'widgets/internship_skills.dart';

class InternshipsPage extends StatefulWidget {
  const InternshipsPage({super.key, required this.student});

  final Student student;

  @override
  State<InternshipsPage> createState() => InternshipsPageState();
}

class InternshipsPageState extends State<InternshipsPage> {
  final activeKey = GlobalKey<_StudentInternshipListViewState>();
  final closedKey = GlobalKey<_StudentInternshipListViewState>();
  final toEvaluateKey = GlobalKey<_StudentInternshipListViewState>();

  List<Internship> _getActiveInternships(List<Internship> internships) {
    final List<Internship> out = [];
    for (final internship in internships) {
      if (internship.isActive) out.add(internship);
    }
    _sortByDate(out);
    return out;
  }

  List<Internship> _getClosedInternships(List<Internship> internships) {
    final List<Internship> out = [];
    for (final internship in internships) {
      if (internship.isClosed) out.add(internship);
    }
    _sortByDate(out);
    return out;
  }

  List<Internship> _getToEvaluateInternships(List<Internship> internships) {
    final List<Internship> out = [];
    for (final internship in internships) {
      if (internship.isEnterpriseEvaluationPending) out.add(internship);
    }
    _sortByDate(out);
    return out;
  }

  void _sortByDate(List<Internship> internships) {
    internships.sort((a, b) => a.dates.start.compareTo(b.dates.start));
  }

  @override
  Widget build(BuildContext context) {
    final internships =
        InternshipsProvider.of(context).byStudentId(widget.student.id);
    final toEvaluateInternships = _getToEvaluateInternships(internships);
    final activeInternships = _getActiveInternships(internships);
    final closedInternships = _getClosedInternships(internships);

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (activeInternships.isNotEmpty)
            _StudentInternshipListView(
              key: activeKey,
              title: 'En cours',
              internships: activeInternships,
            ),
          if (activeInternships.isNotEmpty && toEvaluateInternships.isNotEmpty)
            const SizedBox(height: 12),
          if (toEvaluateInternships.isNotEmpty)
            _StudentInternshipListView(
                key: toEvaluateKey,
                title: 'Évaluations post-stage',
                internships: toEvaluateInternships),
          if (toEvaluateInternships.isNotEmpty && closedInternships.isNotEmpty)
            const SizedBox(height: 12),
          if (closedInternships.isNotEmpty)
            _StudentInternshipListView(
                key: closedKey,
                title: 'Historique des stages',
                internships: closedInternships),
        ],
      ),
    );
  }
}

class _StudentInternshipListView extends StatefulWidget {
  const _StudentInternshipListView(
      {super.key, required this.title, required this.internships});

  final String title;
  final List<Internship> internships;

  @override
  State<_StudentInternshipListView> createState() =>
      _StudentInternshipListViewState();
}

class _StudentInternshipListViewState
    extends State<_StudentInternshipListView> {
  final Map<String, bool> _expanded = {};
  final Map<String, GlobalKey<InternshipDetailsState>> detailKeys = {};

  void _prepareExpander(List<Internship> internships) {
    if (_expanded.length != internships.length) {
      for (final internship in internships) {
        _expanded[internship.id] =
            internship.isActive || internship.isEnterpriseEvaluationPending;
      }
    }

    if (detailKeys.length != internships.length) {
      detailKeys.clear();
      for (final internship in internships) {
        detailKeys[internship.id] = GlobalKey<InternshipDetailsState>();
      }
    }
  }

  bool _isSupervisingInternship(Internship internship) {
    final myId = TeachersProvider.of(context, listen: false).myTeacher?.id;
    return internship.supervisingTeacherIds.contains(myId);
  }

  @override
  Widget build(BuildContext context) {
    _prepareExpander(widget.internships);

    final myId = TeachersProvider.of(context, listen: false).myTeacher?.id;
    if (myId == null) {
      return const Center(child: Text('Vous n\'êtes pas connecté.'));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SubTitle(widget.title),
        ExpansionPanelList(
            expansionCallback: (int panelIndex, bool isExpanded) => setState(
                () =>
                    _expanded[widget.internships[panelIndex].id] = isExpanded),
            children: widget.internships.asMap().keys.map((index) {
              final internship = widget.internships[index];
              final canChangeSupervisingStatus =
                  internship.signatoryTeacherId != myId;

              final endDate = internship.isActive
                  ? DateFormat.yMMMd('fr_CA').format(internship.dates.end)
                  : DateFormat.yMMMd('fr_CA').format(internship.endDate);

              final String specializationIdWithName =
                  EnterprisesProvider.of(context)
                          .fromIdOrNull(internship.enterpriseId)
                          ?.jobs
                          .fromIdOrNull(internship.jobId)
                          ?.specialization
                          .idWithName ??
                      '';

              return ExpansionPanel(
                canTapOnHeader: true,
                isExpanded: _expanded[internship.id]!,
                headerBuilder: (context, isExpanded) => ListTile(
                  title: Text(
                    '${DateFormat.yMMMd('fr_CA').format(internship.dates.start)} - $endDate',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge!
                        .copyWith(color: Colors.black),
                  ),
                  subtitle: Text(specializationIdWithName),
                  trailing: Tooltip(
                    message: 'Ajouter ou retirer l\'élève à votre tableau '
                        'de supervision',
                    child: InkWell(
                      borderRadius: BorderRadius.circular(25),
                      onTap: canChangeSupervisingStatus
                          ? () => InternshipsProvider.of(context, listen: false)
                              .replace(_isSupervisingInternship(internship)
                                  ? internship.copyWithoutTeacher(context,
                                      teacherId: myId)
                                  : internship.copyWithTeacher(context,
                                      teacherId: myId))
                          : null,
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Icon(
                            _isSupervisingInternship(internship)
                                ? Icons.person_add
                                : Icons.person_remove,
                            color: canChangeSupervisingStatus
                                ? Theme.of(context).primaryColor
                                : disabled),
                      ),
                    ),
                  ),
                ),
                body: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InternshipQuickAccess(internshipId: internship.id),
                      InternshipDetails(
                          key: detailKeys[internship.id],
                          internshipId: internship.id),
                      InternshipSkills(internshipId: internship.id),
                      InternshipDocuments(internship: internship),
                    ]),
              );
            }).toList()),
      ],
    );
  }
}
