import 'package:flutter/material.dart';

import 'package:crcrme_banque_stages/common/models/job.dart';
import 'package:crcrme_banque_stages/common/widgets/form_fields/low_high_slider_form_field.dart';

class TasksExpansionPanel extends ExpansionPanel {
  TasksExpansionPanel({
    required super.isExpanded,
    required Job job,
  }) : super(
          canTapOnHeader: true,
          body: _TasksBody(job: job),
          headerBuilder: (context, isExpanded) => const ListTile(
              title: Text('Tâches et exigences envers les stagiaires')),
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
        padding: const EdgeInsets.only(left: 24, right: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Variété des tâches',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            LowHighSliderFormField(
              initialValue: job.taskVariety,
              enabled: false,
            ),
            const SizedBox(height: 12),
            Text(
              'Habiletés obligatoires',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            Column(
              children: job.skillsRequired.isEmpty
                  ? [const Text('Aucune habileté requise')]
                  : job.skillsRequired
                      .map((skills) => Text('- $skills'))
                      .toList(),
            ),
            const SizedBox(height: 12),
            Text(
              'Niveau d\'autonomie souhaité',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            LowHighSliderFormField(
              initialValue: job.autonomyExpected,
              enabled: false,
            ),
            const SizedBox(height: 12),
            Text(
              'Rendement attendu',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            LowHighSliderFormField(
              initialValue: job.efficiencyWanted,
              enabled: false,
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
