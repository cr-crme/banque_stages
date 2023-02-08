import 'package:flutter/material.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';

import '/common/models/job.dart';

class RequirementsStep extends StatefulWidget {
  const RequirementsStep({
    super.key,
  });

  @override
  State<RequirementsStep> createState() => RequirementsStepState();
}

class RequirementsStepState extends State<RequirementsStep> {
  final formKey = GlobalKey<FormState>();

  bool _uniformRequired = false;

  int? minimalAge;
  String? uniform;

  final Map<String, bool> requiredForJob = {
    "Une entrevue de recrutement de l'élève en solo": false,
    "Une vérification d'empêchement pour les élèves majeurs (vérification des antécédents judiciaires)":
        false,
  };

  bool _otherRequirements = false;

  String? _otherRequirementsText;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Âge minimum requis pour le stage :",
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            Text(
              "Est-ce qu'un uniforme était exigé ?",
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            Row(
              children: [
                Radio(
                  value: true,
                  groupValue: _uniformRequired,
                  onChanged: (bool? newValue) =>
                      setState(() => _uniformRequired = newValue!),
                ),
                const Text("Oui"),
                const SizedBox(width: 32),
                Radio(
                  value: false,
                  groupValue: _uniformRequired,
                  onChanged: (bool? newValue) =>
                      setState(() => _uniformRequired = newValue!),
                ),
                const Text("Non"),
              ],
            ),
            Visibility(
              visible: _uniformRequired,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Précisez le type d'uniforme : ",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    TextFormField(
                      onSaved: (text) => uniform = text,
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
              "L'entreprise a demandé : ",
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            Column(
              children: requiredForJob.keys
                  .map(
                    (requirement) => CheckboxListTile(
                      visualDensity: VisualDensity.compact,
                      dense: true,
                      title: Text(
                        requirement,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      value: requiredForJob[requirement],
                      onChanged: (newValue) => setState(
                          () => requiredForJob[requirement] = newValue!),
                    ),
                  )
                  .toList(),
            ),
            CheckboxListTile(
              visualDensity: VisualDensity.compact,
              dense: true,
              title: Text(
                "Autre",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              value: _otherRequirements,
              onChanged: (newValue) =>
                  setState(() => _otherRequirements = newValue!),
            ),
            Visibility(
              visible: _otherRequirements,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Précisez : ",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    TextFormField(
                      onSaved: (text) => _otherRequirementsText = text,
                      minLines: 2,
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AgeSpinBox extends FormField<int> {
  const _AgeSpinBox({
    super.initialValue,
    super.onSaved,
  }) : super(builder: _build);

  static Widget _build(FormFieldState<int> state) {
    return SpinBox(
      value: 0,
      min: 0,
      max: 30,
      spacing: 0,
      decoration: const InputDecoration(border: UnderlineInputBorder()),
      onChanged: (double value) => state.didChange(value.toInt()),
    );
  }
}
