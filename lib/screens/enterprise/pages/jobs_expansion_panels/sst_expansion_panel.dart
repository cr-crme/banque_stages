import 'package:flutter/material.dart';

import '/common/models/job.dart';

class SstExpansionPanel extends ExpansionPanel {
  SstExpansionPanel({
    required super.isExpanded,
    required Job job,
    required void Function(Job job) addSstEvent,
  }) : super(
          canTapOnHeader: true,
          body: _SstBody(job: job),
          headerBuilder: (context, isExpanded) => ListTile(
            title: const Text('Santé et Sécurité du travail (SST)'),
            trailing: IconButton(
                onPressed: () => addSstEvent(job),
                icon: const Icon(Icons.add_box_outlined)),
          ),
        );
}

class _SstBody extends StatelessWidget {
  const _SstBody({required this.job});

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
              'Historique d’accidents et incidents au poste de travail (ex. blessure d’élève même mineure, agression verbale ou harcèlement subis par l’élève)',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              child: Column(children: [
                ...job.pastIncidents.isEmpty
                    ? [const Text('Aucun incident signalé')]
                    : job.pastIncidents.map((incident) => Text('- $incident')),
                ...job.pastWounds.isEmpty
                    ? [const Text('Aucune blessure signalée')]
                    : job.pastWounds.map((wound) => Text('- $wound')),
              ]),
            ),
            const SizedBox(height: 8),
            Text(
              'Personne de l’entreprise à qui s’adresser en cas de blessure ou d’incident?',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              child: Column(
                children: job.equipmentRequired.isEmpty
                    ? [const Text('contact')]
                    : job.equipmentRequired
                        .map((equipment) => Text('- $equipment'))
                        .toList(),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Situations dangereuses identifiées au poste de travail',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              child: Column(
                children: job.dangerousSituations.isEmpty
                    ? [const Text('Aucune situation dangereuse signalée')]
                    : job.dangerousSituations
                        .map((situation) => Text('- $situation'))
                        .toList(),
              ),
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
          ],
        ),
      ),
    );
  }
}
