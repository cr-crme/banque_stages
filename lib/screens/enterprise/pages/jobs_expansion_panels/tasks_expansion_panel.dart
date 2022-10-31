import 'package:flutter/material.dart';

import '/common/models/job.dart';
import '/common/widgets/form_fields/low_high_slider_form_field.dart';

class TasksExpansionPanel extends ExpansionPanel {
  TasksExpansionPanel({
    required super.isExpanded,
    required Job job,
  }) : super(
          canTapOnHeader: true,
          body: _TasksBody(job: job),
          headerBuilder: (context, isExpanded) => const ListTile(
              title: Text("Tâches et exigences envers les stagiaires")),
        );
}

class _TasksBody extends StatelessWidget {
  const _TasksBody({required this.job});

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
              "Variété des tâches",
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: LowHighSliderFormField(
                initialValue: job.taskVariety,
                enabled: false,
              ),
            ),
            Text(
              "Compétences obligatoires",
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              child: Column(
                children: job.skillsRequired.isEmpty
                    ? [const Text("Aucune compétence requise")]
                    : job.skillsRequired
                        .map((skills) => Text("- $skills"))
                        .toList(),
              ),
            ),
            Text(
              "Niveau d’autonomie souhaité",
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: LowHighSliderFormField(
                initialValue: job.autonomyExpected,
                enabled: false,
              ),
            ),
            Text(
              "Rendement attendu",
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: LowHighSliderFormField(
                initialValue: job.efficiencyWanted,
                enabled: false,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
