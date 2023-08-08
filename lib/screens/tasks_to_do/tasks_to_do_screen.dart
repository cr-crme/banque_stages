import 'package:crcrme_banque_stages/common/models/enterprise.dart';
import 'package:crcrme_banque_stages/common/models/internship.dart';
import 'package:crcrme_banque_stages/common/models/job.dart';
import 'package:crcrme_banque_stages/common/models/student.dart';
import 'package:crcrme_banque_stages/common/providers/enterprises_provider.dart';
import 'package:crcrme_banque_stages/common/providers/internships_provider.dart';
import 'package:crcrme_banque_stages/common/providers/students_provider.dart';
import 'package:crcrme_banque_stages/common/widgets/main_drawer.dart';
import 'package:crcrme_banque_stages/common/widgets/sub_title.dart';
import 'package:crcrme_banque_stages/router.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

List<JobEnterpriseInternshipStudent> enterprisesToEvaluate(context) {
  // We should evaluate a job of an enterprise if there is at least one
  // intership in this job and the no evaluation was ever performed
  final enterprises = EnterprisesProvider.of(context);
  final internships = InternshipsProvider.of(context);

  // This happens sometimes, so we need to wait a frame
  if (internships.isEmpty || enterprises.isEmpty) return [];

  List<JobEnterpriseInternshipStudent> out = [];

  for (final enterprise in enterprises) {
    for (final job in enterprise.jobs) {
      if (!job.sstEvaluation.isFilled &&
          internships.any((e) => e.jobId == job.id)) {
        final interns = internships.where((e) => e.jobId == job.id).toList();
        interns.sort((a, b) => a.date.start.compareTo(b.date.start));
        out.add(JobEnterpriseInternshipStudent(
            enterprise: enterprise, job: job, internship: interns[0]));
      }
    }
  }

  out.sort((a, b) => a.enterprise!.name.compareTo(b.enterprise!.name));
  return out;
}

List<JobEnterpriseInternshipStudent> internshipsToTerminate(context) {
  // We should terminate an internship if the end date is passed for more that
  // one day
  final internships = InternshipsProvider.of(context);
  final students = StudentsProvider.of(context);
  final enterprises = EnterprisesProvider.of(context);

  // This happens sometimes, so we need to wait a frame
  if (internships.isEmpty || students.isEmpty || enterprises.isEmpty) return [];

  List<JobEnterpriseInternshipStudent> out = [];

  for (final internship in internships) {
    // TODO check if not supervized students should appear here
    if (internship.shouldTerminate && students.hasId(internship.studentId)) {
      final student = students.fromId(internship.studentId);
      final enterprise = enterprises.fromId(internship.enterpriseId);

      out.add(JobEnterpriseInternshipStudent(
        internship: internship,
        student: student,
        enterprise: enterprise,
      ));
    }
  }

  return out;
}

List<JobEnterpriseInternshipStudent> postInternshipEvaluationToDo(context) {
  // We should evaluate an internship as soon as it is terminated
  final internships = InternshipsProvider.of(context);
  final students = StudentsProvider.of(context);
  final enterprises = EnterprisesProvider.of(context);

  // This happens sometimes, so we need to wait a frame
  if (internships.isEmpty || students.isEmpty || enterprises.isEmpty) return [];

  List<JobEnterpriseInternshipStudent> out = [];

  for (final internship in internships) {
    // TODO check if not supervized students should appear here
    if (internship.isEnterpriseEvaluationPending &&
        students.hasId(internship.studentId)) {
      final student = students.fromId(internship.studentId);
      final enterprise = enterprises.fromId(internship.enterpriseId);

      out.add(JobEnterpriseInternshipStudent(
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
    return Scaffold(
      drawer: const MainDrawer(),
      appBar: AppBar(
        title: const Text('Tâches à réaliser'),
      ),
      body: const SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SstRisk(),
            _EndingInternship(),
            _PostInternshipEvaluation(),
          ],
        ),
      ),
    );
  }
}

class _SstRisk extends StatelessWidget {
  const _SstRisk();

  @override
  Widget build(BuildContext context) {
    final jobs = enterprisesToEvaluate(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SubTitle('Repérer les risques SST'),
        ...jobs.map(
          (e) {
            final enterprise = e.enterprise!;
            final job = e.job!;
            final internship = e.internship!;

            return _TaskTile(
                title: enterprise.name,
                subtitle: job.specialization.name,
                icon: Icons.warning,
                date: internship.date.start,
                buttonTitle: 'Remplir le\nquestionnaire SST',
                onTap: () => GoRouter.of(context).pushNamed(
                      Screens.jobSstForm,
                      params: Screens.params(enterprise, jobId: job),
                    ));
          },
        ),
      ],
    );
  }
}

class _EndingInternship extends StatelessWidget {
  const _EndingInternship();

  @override
  Widget build(BuildContext context) {
    final internships = internshipsToTerminate(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SubTitle('Terminer les stages'),
        ...internships.map(
          (e) {
            final internship = e.internship!;
            final student = e.student!;
            final enterprise = e.enterprise!;

            return _TaskTile(
              title: student.fullName,
              subtitle: enterprise.name,
              icon: Icons.task_alt,
              date: internship.date.end,
              buttonTitle: 'Aller au stage',
              onTap: () => GoRouter.of(context).pushNamed(
                Screens.student,
                params: Screens.params(student),
                queryParams: Screens.queryParams(pageIndex: '1'),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _PostInternshipEvaluation extends StatelessWidget {
  const _PostInternshipEvaluation();

  @override
  Widget build(BuildContext context) {
    final internships = postInternshipEvaluationToDo(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SubTitle('Faire les évaluations post-stage'),
        ...internships.map(
          (e) {
            final internship = e.internship!;
            final student = e.student!;
            final enterprise = e.enterprise!;

            return _TaskTile(
              title: student.fullName,
              subtitle: enterprise.name,
              icon: Icons.rate_review,
              date: internship.endDate!,
              buttonTitle: 'Évaluer l\'entreprise',
              onTap: () => GoRouter.of(context).pushNamed(
                Screens.enterpriseEvaluationScreen,
                params: Screens.params(internship.id),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _TaskTile extends StatelessWidget {
  const _TaskTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.date,
    required this.buttonTitle,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
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
            SizedBox(width: 60, child: Icon(icon, color: Colors.grey)),
            Column(
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

class JobEnterpriseInternshipStudent {
  final Enterprise? enterprise;
  final Job? job;
  final Internship? internship;
  final Student? student;

  JobEnterpriseInternshipStudent({
    this.enterprise,
    this.job,
    this.internship,
    this.student,
  });
}
