import 'package:collection/collection.dart';
import 'package:common/models/enterprises/enterprise.dart';
import 'package:common/models/internships/internship.dart';
import 'package:common/models/persons/teacher.dart';
import 'package:common/services/job_data_file_service.dart';
import 'package:common_flutter/providers/internships_provider.dart';
import 'package:common_flutter/providers/students_provider.dart';
import 'package:common_flutter/providers/teachers_provider.dart';
import 'package:crcrme_banque_stages/common/extensions/enterprise_extension.dart';
import 'package:crcrme_banque_stages/common/provider_helpers/students_helpers.dart';
import 'package:crcrme_banque_stages/common/widgets/sub_title.dart';
import 'package:crcrme_banque_stages/router.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

class InternshipsPage extends StatefulWidget {
  const InternshipsPage({
    super.key,
    required this.enterprise,
    required this.onAddInternshipRequest,
  });

  final Enterprise enterprise;
  final Function(Enterprise, Specialization?) onAddInternshipRequest;

  @override
  State<InternshipsPage> createState() => InternshipsPageState();
}

class InternshipsPageState extends State<InternshipsPage> {
  Future<void> addStage() async =>
      widget.onAddInternshipRequest(widget.enterprise, null);

  List<Internship> _getActiveInternships(List<Internship> internships) {
    final List<Internship> out = [];
    for (final internship in internships) {
      if (internship.isActive) out.add(internship);
    }

    return out;
  }

  List<Internship> _getClosedInternships(List<Internship> internships) {
    final List<Internship> out = [];
    for (final internship in internships) {
      if (internship.isClosed) out.add(internship);
    }
    return out;
  }

  List<Internship> _getToEvaluateInternships(List<Internship> internships) {
    final List<Internship> out = [];
    for (final internship in internships) {
      if (internship.isEnterpriseEvaluationPending) out.add(internship);
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final internships = widget.enterprise.internships(context, listen: true);

    final toEvaluate = _getToEvaluateInternships(internships);
    final active = _getActiveInternships(internships);
    final closed = _getClosedInternships(internships);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (toEvaluate.isNotEmpty)
            _InternshipList(
              title: 'Évaluations post-stage',
              internships: toEvaluate,
              enterprise: widget.enterprise,
            ),
          if (active.isNotEmpty)
            _InternshipList(
              title: 'En cours',
              internships: active,
              enterprise: widget.enterprise,
            ),
          if (closed.isNotEmpty)
            _InternshipList(
              title: 'Historique des stages',
              internships: closed,
              enterprise: widget.enterprise,
            ),
        ],
      ),
    );
  }
}

class _InternshipList extends StatefulWidget {
  const _InternshipList({
    required this.title,
    required this.internships,
    required this.enterprise,
  });

  final String title;
  final List<Internship> internships;
  final Enterprise enterprise;

  @override
  State<_InternshipList> createState() => _InternshipListState();
}

class _InternshipListState extends State<_InternshipList> {
  final _expanded = <String, bool>{};

  void _prepareExpander(List<Internship> internships) {
    if (_expanded.length != widget.internships.length) {
      _expanded.clear();
      for (final internship in internships) {
        _expanded[internship.id] = false;
      }
    }
  }

  Widget _dateBuild(Internship internship) {
    final endDate =
        internship.isActive ? internship.dates.end : internship.endDate;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Column(
          children: [
            const Text('Début\u00a0:'),
            Text(
              '${internship.dates.start.year.toString().padLeft(4, '0')}-'
              '${internship.dates.start.month.toString().padLeft(2, '0')}-'
              '${internship.dates.start.day.toString().padLeft(2, '0')}',
            )
          ],
        ),
        Column(
          children: [
            Text('${internship.isActive ? 'Fin prévue' : 'Fin'}\u00a0:'),
            Text(
              '${endDate.year.toString().padLeft(4, '0')}-'
              '${endDate.month.toString().padLeft(2, '0')}-'
              '${endDate.day.toString().padLeft(2, '0')}',
            ),
          ],
        )
      ],
    );
  }

  void _sendEmail(Teacher teacher) {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: teacher.email!,
    );
    launchUrl(emailLaunchUri);
  }

  /// Returns if the current teacher can control the internship that has the
  /// id [internshipId].
  bool _canSeeDetails({required String internshipId}) {
    final internship = InternshipsProvider.of(context)[internshipId];
    final student = StudentsHelpers.studentsInMyGroups(context)
        .firstWhereOrNull((e) => e.id == internship.studentId);

    return student != null;
  }

  @override
  Widget build(BuildContext context) {
    _prepareExpander(widget.internships);
    final teachers = TeachersProvider.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SubTitle(widget.title),
        ExpansionPanelList(
          expansionCallback: (panelIndex, isExpanded) => setState(
              () => _expanded[widget.internships[panelIndex].id] = isExpanded),
          children: widget.internships.map(
            (internship) {
              final specialization =
                  widget.enterprise.jobs[internship.jobId].specialization;
              final student = StudentsProvider.of(context)
                  .firstWhereOrNull((e) => e.id == internship.studentId);
              final signatoryTeacher = teachers
                  .firstWhere((e) => e.id == internship.signatoryTeacherId);
              final canSeeDetails = _canSeeDetails(internshipId: internship.id);

              if (student == null) {
                return ExpansionPanel(
                    headerBuilder: ((context, isExpanded) => Container()),
                    body: Container());
              }

              return ExpansionPanel(
                canTapOnHeader: true,
                isExpanded: _expanded[internship.id] ?? false,
                headerBuilder: (context, isExpanded) => Padding(
                  padding: const EdgeInsets.only(left: 12.0),
                  child: Row(
                    children: [
                      Text(
                        internship.dates.start.year.toString(),
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(width: 24),
                      Flexible(
                        child: Text(
                          specialization.idWithName,
                          style: Theme.of(context).textTheme.bodyLarge,
                          maxLines: null,
                        ),
                      ),
                    ],
                  ),
                ),
                body: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          'Stagiaire\u00a0: ${student.fullName} (${student.program})'),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Row(
                          children: [
                            const Text('Signataire du contrat\u00a0: '),
                            GestureDetector(
                                onTap: signatoryTeacher.email == null
                                    ? null
                                    : () => _sendEmail(signatoryTeacher),
                                child: Text(
                                  signatoryTeacher.fullName,
                                  style: signatoryTeacher.email == null
                                      ? null
                                      : Theme.of(context)
                                          .textTheme
                                          .titleSmall!
                                          .copyWith(
                                            decoration:
                                                TextDecoration.underline,
                                            color: Colors.blue,
                                          ),
                                ))
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                            'Responsable en milieu de stage\u00a0: ${widget.internships.last.supervisor.fullName}'),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0, bottom: 15),
                        child: _dateBuild(internship),
                      ),
                      if (canSeeDetails)
                        Align(
                          alignment: Alignment.centerRight,
                          child: Padding(
                            padding:
                                const EdgeInsets.only(bottom: 8.0, right: 12),
                            child: TextButton(
                              onPressed: () => GoRouter.of(context).pushNamed(
                                Screens.student,
                                pathParameters: Screens.params(student),
                                queryParameters:
                                    Screens.queryParams(pageIndex: '1'),
                              ),
                              child: const Text('Détails du stage',
                                  textAlign: TextAlign.center),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ).toList(),
        )
      ],
    );
  }
}
