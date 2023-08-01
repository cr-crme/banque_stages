import 'package:crcrme_banque_stages/common/models/enterprise.dart';
import 'package:crcrme_banque_stages/common/models/job.dart';
import 'package:crcrme_banque_stages/router.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class SstExpansionPanel extends ExpansionPanel {
  SstExpansionPanel({
    required super.isExpanded,
    required Enterprise enterprise,
    required Job job,
    required void Function(Job job) addSstEvent,
  }) : super(
          canTapOnHeader: true,
          body: _SstBody(enterprise, job, addSstEvent),
          headerBuilder: (context, isExpanded) => const ListTile(
            title: Text('Repérage des risques SST'),
          ),
        );
}

class _SstBody extends StatelessWidget {
  const _SstBody(
    this.enterprise,
    this.job,
    this.addSstEvent,
  );

  final Enterprise enterprise;
  final Job job;
  final void Function(Job job) addSstEvent;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: Size.infinite.width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(job.sstEvaluation.isFilled
                ? 'Formulaire «\u00a0Repérer les risques SST\u00a0» rempli '
                    '(ou mis à jour) avec l\'entreprise le '
                    '${DateFormat.yMMMEd('fr_CA').format(job.sstEvaluation.date)}'
                : 'Le questionnaire «\u00a0Repérer les risques SST\u00a0» n\'a '
                    'jamais été rempli pour ce poste de travail.'),
            const SizedBox(height: 12),
            Center(
              child: TextButton(
                onPressed: () => GoRouter.of(context).pushNamed(
                  Screens.jobSstForm,
                  params: Screens.params(enterprise, jobId: job),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Text(
                    '${job.sstEvaluation.isFilled ? 'Visualiser le\n' : 'Remplir le\n'}questionnaire SST',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
