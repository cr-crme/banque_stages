import 'package:flutter/material.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';

class PrerequisitesStep extends StatefulWidget {
  const PrerequisitesStep({super.key});

  @override
  State<PrerequisitesStep> createState() => PrerequisitesStepState();
}

class PrerequisitesStepState extends State<PrerequisitesStep> {
  final _formKey = GlobalKey<FormState>();

  Future<String?> validate() async {
    if (!_formKey.currentState!.validate()) {
      return 'Remplir tous les champs avec un *.';
    }
    _formKey.currentState!.save();
    return null;
  }

  int? minimalAge;

  final Map<String, bool> requiredForJob = {
    'Une entrevue de recrutement de l\'élève en solo': false,
    'Une vérification des antécédents judiciaires pour les élèves majeurs':
        false,
  };

  bool _otherRequirements = false;

  String? otherRequirementsText;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Âge minimum requis pour le stage :',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            _AgeSpinBox(
              onSaved: (newValue) => minimalAge = newValue,
            ),
            const SizedBox(height: 16),
            Text(
              'L\'entreprise a demandé : ',
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
                'Autre',
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
                      'Préciser : ',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    TextFormField(
                      onSaved: (text) => otherRequirementsText = text,
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
  const _AgeSpinBox({super.onSaved}) : super(builder: _build);

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
