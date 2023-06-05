import 'package:crcrme_banque_stages/common/models/enterprise.dart';
import 'package:crcrme_banque_stages/router.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:crcrme_banque_stages/common/models/job.dart';

class SstExpansionPanel extends ExpansionPanel {
  SstExpansionPanel({
    required super.isExpanded,
    required Enterprise enterprise,
    required Job job,
    required void Function(Job job) addSstEvent,
  }) : super(
          canTapOnHeader: true,
          body: SstBody(enterprise, job, addSstEvent),
          headerBuilder: (context, isExpanded) => ListTile(
            title: const Text('Santé et Sécurité (SST)'),
            trailing: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey[900]!,
                    blurRadius: 8.0,
                    offset: const Offset(2, 2),
                  ),
                ],
              ),
              child: Visibility(
                visible: job.pastIncidents.isNotEmpty,
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

class SstBody extends StatelessWidget {
  const SstBody(
    this.enterprise,
    this.job,
    this.addSstEvent, {
    super.key,
  });

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
                child: const Text('Signaler un événement'),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Historique d\'accidents et d\'incidents au poste de travail',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 8),
              child: job.pastIncidents.isEmpty
                  ? const Text('Aucun incident signalé')
                  : Text(job.pastIncidents),
            ),
            const SizedBox(height: 8),
            Text(
              'Personne de l\'entreprise à qui s\'adresser en cas de blessure '
              'ou d\'incident',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 8),
              child: job.incidentContact.isEmpty
                  ? const Text('Aucun contact enregistré')
                  : Text(job.incidentContact),
            ),
            const SizedBox(height: 8),
            Text(
              'Situations dangereuses repérées sur le poste de travail',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 8),
              child: job.dangerousSituations.isEmpty
                  ? const Text('Aucune situation')
                  : Text(job.dangerousSituations),
            ),
            const SizedBox(height: 8),
            Text(
              'Équipements de protection individuelle requis',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 8),
              child: Column(
                children: job.equipmentRequired.isEmpty
                    ? [const Text('Aucun équipement')]
                    : job.equipmentRequired
                        .map((equipment) => Text('- $equipment'))
                        .toList(),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Détail des tâches et risques associés',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const Text("Formulaire SST rempli avec l’entreprise"),
            Text(
                "Mis à jour le ${job.sstLastUpdate.year}-${job.sstLastUpdate.month}-${job.sstLastUpdate.day}"),
            const SizedBox(height: 8),
            Center(
              child: TextButton(
                onPressed: () => GoRouter.of(context).pushNamed(
                  Screens.jobSstForm,
                  params: Screens.params(enterprise, jobId: job),
                ),
                child: const Text(
                  'Aborder la SST \navec l\'entreprise',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
