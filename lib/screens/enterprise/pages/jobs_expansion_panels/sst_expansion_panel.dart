import 'package:crcrme_banque_stages/common/models/enterprise.dart';
import 'package:crcrme_banque_stages/router.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '/common/models/job.dart';

class SstExpansionPanel extends ExpansionPanel {
  SstExpansionPanel({
    required super.isExpanded,
    required Enterprise enterprise,
    required Job job,
    required void Function(Job job) addSstEvent,
  }) : super(
          canTapOnHeader: true,
          body: _SstBody(enterprise, job),
          headerBuilder: (context, isExpanded) => ListTile(
            title: const Text('Santé et Sécurité du travail (SST)'),
            trailing: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey[400]!,
                    blurRadius: 8.0,
                    offset: const Offset(2, 2),
                  ),
                ],
              ),
              child: IconButton(
                  onPressed: () => addSstEvent(job),
                  icon: const Icon(
                    Icons.warning,
                    color: Colors.red,
                  )),
            ),
          ),
        );
}

class _SstBody extends StatelessWidget {
  const _SstBody(
    this.enterprise,
    this.job,
  );

  final Enterprise enterprise;
  final Job job;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: Size.infinite.width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Historique d\'accidents et incidents au poste de travail '
              '(ex. blessure d\'élève même mineure, agression verbale ou '
              'harcèlement subis par l\'élève)',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              child: job.pastIncidents.isEmpty
                  ? const Text('Aucun incident signalé')
                  : Text(job.pastIncidents),
            ),
            const SizedBox(height: 8),
            Text(
              'Personne de l\'entreprise à qui s\'adresser en cas de blessure '
              'ou d\'incident?',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              child: job.incidentContact.isEmpty
                  ? const Text('Aucun contact enregistré.')
                  : Text(job.incidentContact),
            ),
            const SizedBox(height: 8),
            Text(
              'Situations dangereuses identifiées au poste de travail',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              child: job.dangerousSituations.isEmpty
                  ? const Text('Aucune situation dangereuse signalée')
                  : Text(job.dangerousSituations),
            ),
            const SizedBox(height: 8),
            Text(
              'Équipements de protection individuelle requis',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              child: Column(
                children: job.equipmentRequired.isEmpty
                    ? [const Text('Aucun équipement de protection requis')]
                    : job.equipmentRequired
                        .map((equipment) => Text('- $equipment'))
                        .toList(),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: TextButton(
                onPressed: () => GoRouter.of(context).goNamed(
                  Screens.jobSstForm,
                  params: Screens.withId(enterprise, jobId: job),
                ),
                child: const Text("Ouvrir le formulaire SST"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
