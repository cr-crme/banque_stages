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
  const _SstBody({required this.job});

  final Job job;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: Size.infinite.width,
      child: Padding(
        padding: const EdgeInsets.only(left: 24, right: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Historique d\'accidents et incidents au poste de travail '
              '(ex. blessure d\'élève même mineure, agression verbale ou '
              'harcèlement subis par l\'élève)',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...job.pastIncidents.isEmpty
                    ? [const Text('Aucun incident signalé')]
                    : job.pastIncidents.map((incident) => Text('- $incident')),
                ...job.pastWounds.isEmpty
                    ? [const Text('Aucune blessure signalée')]
                    : job.pastWounds.map((wound) => Text('- $wound')),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Personne de l’entreprise à qui s’adresser en cas de blessure ou d’incident?',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: job.equipmentRequired.isEmpty
                  ? [const Text('Contact')]
                  : job.equipmentRequired
                      .map((equipment) => Text('- $equipment'))
                      .toList(),
            ),
            const SizedBox(height: 12),
            const Text(
              'Situations dangereuses identifiées au poste de travail',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: job.dangerousSituations.isEmpty
                  ? [const Text('Aucune situation dangereuse signalée')]
                  : job.dangerousSituations
                      .map((situation) => Text('- $situation'))
                      .toList(),
            ),
            const SizedBox(height: 12),
            const Text(
              'Équipements de protection individuelle requis',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: job.equipmentRequired.isEmpty
                  ? [const Text('Aucun équipement de protection requis')]
                  : job.equipmentRequired
                      .map((equipment) => Text('- $equipment'))
                      .toList(),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
