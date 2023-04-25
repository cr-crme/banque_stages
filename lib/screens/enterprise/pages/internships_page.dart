import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '/common/models/enterprise.dart';
import '/common/models/internship.dart';
import '/common/models/student.dart';
import '/common/models/teacher.dart';
import '/common/providers/students_provider.dart';
import '/common/providers/teachers_provider.dart';
import '/common/widgets/sub_title.dart';
import '/misc/job_data_file_service.dart';
import '/router.dart';

class InternshipsPage extends StatefulWidget {
  const InternshipsPage({
    super.key,
    required this.enterprise,
    required this.onAddIntershipRequest,
  });

  final Enterprise enterprise;
  final Function(Enterprise) onAddIntershipRequest;

  @override
  State<InternshipsPage> createState() => InternshipsPageState();
}

class InternshipsPageState extends State<InternshipsPage> {
  Future<void> addStage() async =>
      widget.onAddIntershipRequest(widget.enterprise);

  List<Internship> _getActiveInternships(List<Internship> internships) {
    final List<Internship> current = [];
    for (final internship in internships) {
      if (internship.isActive) current.add(internship);
    }

    return current;
  }

  List<Internship> _getDoneInternships(List<Internship> internships) {
    final List<Internship> current = [];
    for (final internship in internships) {
      if (internship.isClosed) current.add(internship);
    }
    return current;
  }

  List<Internship> _getToFinalizeInternships(List<Internship> internships) {
    final List<Internship> current = [];
    for (final internship in internships) {
      if (internship.isEnterpriseEvaluationPending) current.add(internship);
    }
    return current;
  }

  @override
  Widget build(BuildContext context) {
    final internships = widget.enterprise.internships(context, listen: true);

    final toFinalize = _getToFinalizeInternships(internships);
    final active = _getActiveInternships(internships);
    final done = _getDoneInternships(internships);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (toFinalize.isNotEmpty)
            _InternshipList(
              title: 'Évaluations post-stage',
              internships: toFinalize,
              enterprise: widget.enterprise,
            ),
          if (active.isNotEmpty)
            _InternshipList(
              title: 'En cours',
              internships: active,
              enterprise: widget.enterprise,
            ),
          if (done.isNotEmpty)
            _InternshipList(
              title: 'Historique des stages',
              internships: done,
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

  void _evaluateInternship(Internship internship) async {
    GoRouter.of(context).pushNamed(
      Screens.enterpriseEvaluationScreen,
      params: Screens.params(internship.enterpriseId, jobId: internship.jobId),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    _prepareExpander(widget.internships);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SubTitle(widget.title),
        ExpansionPanelList(
          expansionCallback: (panelIndex, isExpanded) => setState(
              () => _expanded[widget.internships[panelIndex].id] = !isExpanded),
          children: widget.internships.map(
            (internship) {
              final teachers = TeachersProvider.of(context);
              late Specialization specialization;
              late Teacher teacher;
              late Future<Student> student;

              try {
                specialization =
                    widget.enterprise.jobs[internship.jobId].specialization;
                teacher = teachers.fromId(internship.teacherId);
                student = StudentsProvider.fromLimitedId(context,
                    studentId: internship.studentId);
              } catch (e) {
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
                        internship.date.start.year.toString(),
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
                body: FutureBuilder<Student>(
                    future: student,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return Container();
                      final student = snapshot.data!;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text('Stagiaire : '),
                                GestureDetector(
                                  onTap: () => GoRouter.of(context).pushNamed(
                                    Screens.student,
                                    params: Screens.params(student),
                                    queryParams:
                                        Screens.queryParams(pageIndex: '1'),
                                  ),
                                  child: Text(
                                    student.fullName,
                                    style: const TextStyle(
                                        color: Colors.blue,
                                        fontWeight: FontWeight.bold,
                                        decoration: TextDecoration.underline),
                                  ),
                                ),
                                Text(' (${student.program.title})'),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                  'Enseignant\u00b7e superviseur\u00b7e : ${teacher.fullName}'),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                  'Responsable en milieu de stage : ${widget.internships.last.supervisor.fullName}'),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: 10.0, bottom: 15),
                              child: _dateBuild(internship),
                            ),
                            if (internship.isEnterpriseEvaluationPending)
                              Align(
                                alignment: Alignment.centerRight,
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: TextButton(
                                    onPressed: () =>
                                        _evaluateInternship(internship),
                                    style: Theme.of(context)
                                        .textButtonTheme
                                        .style!
                                        .copyWith(
                                          minimumSize:
                                              MaterialStateProperty.all(
                                                  const Size(0, 50)),
                                          maximumSize:
                                              MaterialStateProperty.all(
                                                  const Size(200, 50)),
                                        ),
                                    child: const Text(
                                      'Évaluer l\'entreprise \npour ce stage',
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    }),
              );
            },
          ).toList(),
        )
      ],
    );
  }
}
