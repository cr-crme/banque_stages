import 'package:crcrme_banque_stages/common/models/enterprise.dart';
import 'package:crcrme_banque_stages/common/models/job.dart';
import 'package:crcrme_banque_stages/common/widgets/itemized_text.dart';
import 'package:crcrme_banque_stages/router.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class IncidentsExpansionPanel extends ExpansionPanel {
  IncidentsExpansionPanel({
    required super.isExpanded,
    required Enterprise enterprise,
    required Job job,
    required void Function(Job job) addSstEvent,
  }) : super(
          canTapOnHeader: true,
          body: _IncidentsBody(enterprise, job, addSstEvent),
          headerBuilder: (context, isExpanded) => ListTile(
            title: const Text('Accidents et incidents en stage'),
            trailing: Visibility(
              visible: job.incidents.isNotEmpty,
              child: Tooltip(
                message:
                    'Il y a au moins eu un accident répertorié pour cette entreprise',
                margin: EdgeInsets.only(
                    left: MediaQuery.of(context).size.width / 4, right: 12),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.warning_amber,
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ),
            ),
          ),
        );
}

class _IncidentsBody extends StatelessWidget {
  const _IncidentsBody(
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
            Center(
              child: ElevatedButton(
                onPressed: () => addSstEvent(job),
                child: const Text('Signaler un incident'),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Blessures graves d\'élèves',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const Padding(
              padding: EdgeInsets.only(bottom: 8.0),
              child: Text(
                '(ex. blessure d\'élève même mineure, agression verbale '
                'harcèlement subis par l\'élève)',
              ),
            ),
            Text(
              'Cas d\'agression ou de harcèlement',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            job.incidents.isEmpty
                ? const Text('Aucun incident rapporté')
                : ItemizedText(job.incidents.verbalAbuses),
            const SizedBox(height: 8),
            Text(
              'Blessures mineures d\'élèves',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            Text(job.sstEvaluation.isFilled
                ? 'Le formulaire n\'a jamais été rempli avec cette entreprise'
                : 'Formulaire SST rempli avec l\'entreprise\n'
                    'Mis à jour le ${DateFormat.yMMMEd('fr_CA').format(job.sstEvaluation.date)}'),
            const SizedBox(height: 12),
            Center(
              child: TextButton(
                onPressed: () => GoRouter.of(context).pushNamed(
                  Screens.jobSstForm,
                  params: Screens.params(enterprise, jobId: job),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 4.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('Afficher le'),
                      Text('formulaire'),
                    ],
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
