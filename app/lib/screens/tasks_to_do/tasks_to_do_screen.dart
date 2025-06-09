import 'package:collection/collection.dart';
import 'package:common/models/enterprises/enterprise.dart';
import 'package:common/models/enterprises/job.dart';
import 'package:common/models/internships/internship.dart';
import 'package:common/models/persons/student.dart';
import 'package:common_flutter/providers/internships_provider.dart';
import 'package:crcrme_banque_stages/common/providers/enterprises_provider.dart';
import 'package:crcrme_banque_stages/common/providers/students_provider.dart';
import 'package:crcrme_banque_stages/common/providers/teachers_provider.dart';
import 'package:crcrme_banque_stages/common/widgets/main_drawer.dart';
import 'package:crcrme_banque_stages/common/widgets/sub_title.dart';
import 'package:crcrme_banque_stages/router.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

int numberOfTasksToDo(context) {
  final taskFunctions = [
    _enterprisesToEvaluate,
    _internshipsToTerminate,
    _postInternshipEvaluationToDo
  ];
  return taskFunctions.fold<int>(0, (prev, e) => prev + e(context).length);
}

List<_JobEnterpriseInternshipStudent> _enterprisesToEvaluate(context) {
  // We should evaluate a job of an enterprise if there is at least one
  // internship in this job and the no evaluation was ever performed
  final myId = TeachersProvider.of(context).currentTeacherId;
  final enterprises = EnterprisesProvider.of(context);
  final internships = InternshipsProvider.of(context);

  // This happens sometimes, so we need to wait a frame
  if (internships.isEmpty || enterprises.isEmpty) return [];

  List<_JobEnterpriseInternshipStudent> out = [];
  for (final enterprise in enterprises) {
    for (final job in enterprise.jobs) {
      if (!job.sstEvaluation.isFilled) {
        final interns = internships
            .where((e) =>
                e.isActive &&
                e.jobId == job.id &&
                e.supervisingTeacherIds.contains(myId))
            .toList();
        if (interns.isEmpty) continue;

        interns.sort((a, b) => a.dates.start.compareTo(b.dates.start));

        out.add(_JobEnterpriseInternshipStudent(
            enterprise: enterprise, job: job, internship: interns[0]));
      }
    }
  }

  return out;
}

List<_JobEnterpriseInternshipStudent> _internshipsToTerminate(context) {
  // We should terminate an internship if the end date is passed for more that
  // one day
  final internships = InternshipsProvider.of(context);
  final students = StudentsProvider.mySupervizedStudents(context);
  final enterprises = EnterprisesProvider.of(context);

  // This happens sometimes, so we need to wait a frame
  if (internships.isEmpty || students.isEmpty || enterprises.isEmpty) return [];

  List<_JobEnterpriseInternshipStudent> out = [];

  for (final internship in internships) {
    if (internship.shouldTerminate) {
      final student =
          students.firstWhereOrNull((e) => e.id == internship.studentId);
      if (student == null) continue;

      final enterprise = enterprises.fromIdOrNull(internship.enterpriseId);
      if (enterprise == null) continue;

      out.add(_JobEnterpriseInternshipStudent(
        internship: internship,
        student: student,
        enterprise: enterprise,
      ));
    }
  }

  return out;
}

List<_JobEnterpriseInternshipStudent> _postInternshipEvaluationToDo(context) {
  // We should evaluate an internship as soon as it is terminated
  final internships = InternshipsProvider.of(context);
  final students = StudentsProvider.mySupervizedStudents(context);
  final enterprises = EnterprisesProvider.of(context);

  // This happens sometimes, so we need to wait a frame
  if (internships.isEmpty || students.isEmpty || enterprises.isEmpty) return [];

  List<_JobEnterpriseInternshipStudent> out = [];

  for (final internship in internships) {
    if (internship.isEnterpriseEvaluationPending) {
      final student =
          students.firstWhereOrNull((e) => e.id == internship.studentId);
      if (student == null) continue;

      final enterprise = enterprises.fromIdOrNull(internship.enterpriseId);
      if (enterprise == null) continue;

      out.add(_JobEnterpriseInternshipStudent(
        internship: internship,
        student: student,
        enterprise: enterprise,
      ));
    }
  }

  return out;
}

class TasksToDoScreen extends StatelessWidget {
  const TasksToDoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    int nbTasksToDo = numberOfTasksToDo(context);

    return Scaffold(
      drawer: const MainDrawer(),
      appBar: AppBar(
        title: const Text('Tâches à réaliser'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (nbTasksToDo == 0) const _AllTasksDoneTitle(),
            const _SstRisk(),
            const _EndingInternship(),
            const _PostInternshipEvaluation(),
          ],
        ),
      ),
    );
  }
}

class _AllTasksDoneTitle extends StatelessWidget {
  const _AllTasksDoneTitle();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 24.0),
        child: Text(
          'Bravo!\nToutes les tâches ont été réalisées!',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
    );
  }
}

class _SstRisk extends StatelessWidget {
  const _SstRisk();

  @override
  Widget build(BuildContext context) {
    final jobs = _enterprisesToEvaluate(context);

    jobs.sort((a, b) =>
        a.internship!.dates.start.compareTo(b.internship!.dates.start));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SubTitle('Repérer les risques SST'),
        ...(jobs.isEmpty
            ? [const _AllTasksDone()]
            : jobs.map(
                (e) {
                  final enterprise = e.enterprise!;
                  final job = e.job!;
                  final internship = e.internship!;

                  return _TaskTile(
                      title: enterprise.name,
                      subtitle: job.specialization.name,
                      icon: Icons.warning,
                      iconColor: Theme.of(context).colorScheme.secondary,
                      date: internship.dates.start,
                      buttonTitle: 'Remplir le\nquestionnaire SST',
                      onTap: () => GoRouter.of(context).pushNamed(
                            Screens.jobSstForm,
                            pathParameters:
                                Screens.params(enterprise, jobId: job),
                          ));
                },
              )),
      ],
    );
  }
}

class _EndingInternship extends StatelessWidget {
  const _EndingInternship();

  @override
  Widget build(BuildContext context) {
    final internships = _internshipsToTerminate(context);

    internships.sort(
        (a, b) => a.internship!.dates.end.compareTo(b.internship!.dates.end));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SubTitle('Terminer les stages'),
        ...(internships.isEmpty
            ? [const _AllTasksDone()]
            : internships.map(
                (e) {
                  final internship = e.internship!;
                  final student = e.student!;
                  final enterprise = e.enterprise!;

                  return _TaskTile(
                    title: student.fullName,
                    subtitle: enterprise.name,
                    icon: Icons.flag,
                    iconColor: Colors.yellow.shade700,
                    date: internship.dates.end,
                    buttonTitle: 'Aller au stage',
                    onTap: () => GoRouter.of(context).pushNamed(
                      Screens.student,
                      pathParameters: Screens.params(student),
                      queryParameters: Screens.queryParams(pageIndex: '1'),
                    ),
                  );
                },
              )),
      ],
    );
  }
}

class _PostInternshipEvaluation extends StatelessWidget {
  const _PostInternshipEvaluation();

  @override
  Widget build(BuildContext context) {
    final internships = _postInternshipEvaluationToDo(context);

    internships
        .sort((a, b) => a.internship!.endDate.compareTo(b.internship!.endDate));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SubTitle('Faire les évaluations post-stage'),
        ...(internships.isEmpty
            ? [const _AllTasksDone()]
            : internships.map(
                (e) {
                  final internship = e.internship!;
                  final student = e.student!;
                  final enterprise = e.enterprise!;

                  return _TaskTile(
                    title: student.fullName,
                    subtitle: enterprise.name,
                    icon: Icons.rate_review,
                    iconColor: Colors.blueGrey,
                    date: internship.endDate,
                    buttonTitle: 'Évaluer l\'entreprise',
                    onTap: () => GoRouter.of(context).pushNamed(
                      Screens.enterpriseEvaluationScreen,
                      pathParameters: Screens.params(internship.id),
                    ),
                  );
                },
              )),
      ],
    );
  }
}

class _TaskTile extends StatelessWidget {
  const _TaskTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.date,
    required this.buttonTitle,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final DateTime date;
  final String buttonTitle;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 10,
      child: Column(
        children: [
          const SizedBox(height: 8),
          Row(children: [
            SizedBox(width: 60, child: Icon(icon, color: iconColor)),
            SizedBox(
              width: MediaQuery.of(context).size.width - 72,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            )
          ]),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                DateFormat.yMMMEd('fr_CA').format(date),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              TextButton(
                  onPressed: onTap,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Text(
                      buttonTitle,
                      textAlign: TextAlign.center,
                    ),
                  ))
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _JobEnterpriseInternshipStudent {
  final Enterprise? enterprise;
  final Job? job;
  final Internship? internship;
  final Student? student;

  _JobEnterpriseInternshipStudent({
    this.enterprise,
    this.job,
    this.internship,
    this.student,
  });
}

class _AllTasksDone extends StatelessWidget {
  const _AllTasksDone();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(left: 24.0),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline, color: Colors.green),
          SizedBox(width: 4),
          Text('Aucune tâche à faire'),
        ],
      ),
    );
  }
}
