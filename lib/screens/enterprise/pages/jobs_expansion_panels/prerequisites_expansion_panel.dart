import 'package:flutter/material.dart';

import 'package:crcrme_banque_stages/common/models/job.dart';

class PrerequisitesExpansionPanel extends ExpansionPanel {
  PrerequisitesExpansionPanel({
    required super.isExpanded,
    required Job job,
  }) : super(
          canTapOnHeader: true,
          body: _PrerequisitesBody(job: job),
          headerBuilder: (context, isExpanded) => const ListTile(
            title: Text('Prérequis pour le recrutement'),
          ),
        );
}

class _PrerequisitesBody extends StatelessWidget {
  const _PrerequisitesBody({required this.job});

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
              'Âge minimum',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('${job.minimalAge} ans'),
            const SizedBox(height: 12),
            const Text(
              'Uniforme en vigueur',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            job.uniform.isEmpty
                ? const Text('Aucun uniforme requis')
                : Text(job.uniform),
            const SizedBox(height: 12),
            const Text(
              'L\'entreprise a demandé :',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Column(
              children: job.requirements.isEmpty
                  ? [const Text('Il n\'y a aucun prérequis pour ce métier')]
                  : job.requirements
                      .map((requirement) => Text('- $requirement'))
                      .toList(),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
