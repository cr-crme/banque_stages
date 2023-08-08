import 'package:crcrme_banque_stages/common/models/enterprise.dart';
import 'package:crcrme_banque_stages/common/models/internship.dart';
import 'package:crcrme_banque_stages/common/models/job.dart';
import 'package:crcrme_banque_stages/common/providers/enterprises_provider.dart';
import 'package:crcrme_banque_stages/common/providers/internships_provider.dart';
import 'package:crcrme_banque_stages/common/providers/students_provider.dart';
import 'package:crcrme_banque_stages/common/widgets/main_drawer.dart';
import 'package:crcrme_banque_stages/common/widgets/sub_title.dart';
import 'package:crcrme_banque_stages/router.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class TasksToDoScreen extends StatelessWidget {
  const TasksToDoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final students = StudentsProvider.of(context);
    final internships = InternshipsProvider.of(context);

    return Scaffold(
      drawer: const MainDrawer(),
      appBar: AppBar(
        title: const Text('Tâches à réaliser'),
      ),
      body: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SstRisk(),
        ],
      ),
    );
  }
}

class _JobInEnterprise {
  final Enterprise enterprise;
  final Job job;
  final Internship internship;

  _JobInEnterprise({
    required this.enterprise,
    required this.job,
    required this.internship,
  });
}

class _SstRisk extends StatelessWidget {
  const _SstRisk();

  List<_JobInEnterprise> _extractWithTaskToDo(context) {
    // We should evaluate a job of an enterprise if there is at least one
    // intership in this job and the no evaluation was ever performed
    final entreprises = EnterprisesProvider.of(context);
    final internships = InternshipsProvider.of(context);

    List<_JobInEnterprise> out = [];

    for (final enterprise in entreprises) {
      for (final job in enterprise.jobs) {
        if (!job.sstEvaluation.isFilled &&
            internships.any((e) => e.jobId == job.id)) {
          final interns = internships.where((e) => e.jobId == job.id).toList();
          interns.sort((a, b) => a.date.start.compareTo(b.date.start));
          out.add(_JobInEnterprise(
              enterprise: enterprise, job: job, internship: interns[0]));
        }
      }
    }

    return out;
  }

  @override
  Widget build(BuildContext context) {
    final jobs = _extractWithTaskToDo(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SubTitle('Repérer les risques SST'),
        SizedBox(
          height: 200,
          child: ListView.builder(
            itemCount: jobs.length,
            itemBuilder: (context, index) {
              final enterprise = jobs[index].enterprise;
              final job = jobs[index].job;
              final internship = jobs[index].internship;

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
