import 'package:flutter/material.dart';

import '/common/models/job.dart';
import '/common/widgets/form_fields/low_high_slider_form_field.dart';

class TasksStep extends StatefulWidget {
  const TasksStep({
    super.key,
    required this.job,
  });

  final Job job;

  @override
  State<TasksStep> createState() => TasksStepState();
}

class TasksStepState extends State<TasksStep> {
  final formKey = GlobalKey<FormState>();

  double? taskVariety;
  double? autonomyExpected;
  double? efficiencyWanted;

  final Map<String, bool> skillsRequired = {
    'Communiquer à l\'écrit': false,
    'Communiquer en anglais': false,
    'Conduire un chariot (élèves CFER)': false,
    'Interagir avec des clients': false,
    'Manipuler de l\'argent': false,
  };

  bool _otherSkills = false;
  String? _otherSkillsText;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '* Quel était le degré de variété des tâches assignées au ou à la stagiaire ?',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: LowHighSliderFormField(
                onSaved: (value) => taskVariety = value,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '* Quelles étaient les attentes de l\'entreprise envers le ou la stagiaire ?',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            Column(
              children: skillsRequired.keys
                  .map(
                    (skill) => CheckboxListTile(
                      visualDensity: VisualDensity.compact,
                      dense: true,
                      title: Text(
                        skill,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      value: skillsRequired[skill],
                      onChanged: (newValue) =>
                          setState(() => skillsRequired[skill] = newValue!),
                    ),
                  )
                  .toList(),
            ),
            CheckboxListTile(
              visualDensity: VisualDensity.compact,
              dense: true,
              title: Text(
                'Autre',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              value: _otherSkills,
              onChanged: (newValue) => setState(() => _otherSkills = newValue!),
            ),
            Visibility(
              visible: _otherSkills,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Préciser les autres attentes : ',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    TextFormField(
                      onSaved: (text) => _otherSkillsText = text,
                      minLines: 2,
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '* Quel était le niveau d\'autonomie souhaité ?',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: LowHighSliderFormField(
                onSaved: (value) => autonomyExpected = value,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '* Quel était le niveau de rendement attendu ?',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: LowHighSliderFormField(
                onSaved: (value) => efficiencyWanted = value,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
