import 'package:flutter/material.dart';

import '/common/models/job.dart';

class PrerequisitesExpansionPanel extends ExpansionPanel {
  PrerequisitesExpansionPanel({
    required super.isExpanded,
    required Job job,
  }) : super(
          canTapOnHeader: true,
          body: _PrerequisitesBody(job: job),
          headerBuilder: (context, isExpanded) => const ListTile(
            title: Text("Prérequis pour le recrutement"),
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
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Âge minimum",
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              child: Text("${job.minimalAge} ans"),
            ),
            Text(
              "Uniforme en vigueur",
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              child: job.uniform.isEmpty
                  ? const Text("Aucun uniforme requis")
                  : Text(job.uniform),
            ),
            Text(
              "L'entreprise a demandé :",
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              child: Column(
                children: job.requirements.isEmpty
                    ? [const Text("Il n'y a aucun prérequis pour ce métier")]
                    : job.requirements
                        .map((requirement) => Text("- $requirement"))
                        .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
