import 'package:crcrme_banque_stages/common/models/job.dart';
import 'package:flutter/material.dart';

import '/common/widgets/form_fields/question_with_checkbox_list.dart';
import '/common/widgets/form_fields/question_with_radio_bool.dart';
import '/common/widgets/form_fields/question_with_text.dart';

class DangerStep extends StatefulWidget {
  const DangerStep({
    super.key,
    required this.job,
  });

  final Job job;

  @override
  State<DangerStep> createState() => DangerStepState();
}

class DangerStepState extends State<DangerStep> {
  final formKey = GlobalKey<FormState>();

  bool isProfessor = true;

  String? dangerousSituations;
  List<String>? equipmentRequired;
  String? pastIncidents;
  String? incidentContact;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: SingleChildScrollView(
        child: Column(
          children: [
            QuestionWithText(
              initialValue: widget.job.dangerousSituations,
              question:
                  'Quelles sont les situations de travail qui pourraient être '
                  'dangereuses pour mon élève? Comment faudrait-il l\'y préparer?',
              onSaved: (text) => dangerousSituations = text,
            ),
            QuestionWithCheckboxList(
              initialChoices: widget.job.equipmentRequired.toSet(),
              choicesQuestion:
                  'Est-ce que l\'élève devra porter un des équipements de '
                  'protection individuelle suivants?',
              choices: const {
                'Chaussures de sécurité',
                'Lunettes de sécurité',
                'Protections auditives (p. ex. bouchons)',
                'Masque',
                'Casque',
                'Gants',
              },
              onSavedChoices: (choices) =>
                  equipmentRequired = choices?.toList(),
            ),
            QuestionWithRadioBool(
              initialChoice: widget.job.pastIncidents.isNotEmpty,
              initialText: widget.job.pastIncidents,
              choiceQuestion:
                  'Est-ce qu\'il y a déjà eu des incidents ou des accidents du '
                  'travail au poste que l\'élève occupera en stage?',
              textQuestion: 'Pouvez-vous me raconter ce qu\'il s\'est passé?',
              onSavedText: (text) => pastIncidents = text,
            ),
            const QuestionWithText(
              question:
                  'À quelle personne dans l\'entreprise, l\'élève doit-il '
                  's\'adresser en cas de blessure ou d\'incident?',
            ),
          ],
        ),
      ),
    );
  }
}
