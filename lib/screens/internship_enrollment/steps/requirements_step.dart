import 'package:flutter/material.dart';

class RequirementsStep extends StatefulWidget {
  const RequirementsStep({
    super.key,
  });

  @override
  State<RequirementsStep> createState() => RequirementsStepState();
}

class RequirementsStepState extends State<RequirementsStep> {
  final formKey = GlobalKey<FormState>();

  bool _protectionRequired = false;
  final Map<String, bool> _protection = {
    'Chaussures de sécurité': false,
    'Lunettes de sécurité': false,
    'Protections auditives': false,
    'Masque': false,
    'Casque': false,
    'Gants': false,
  };

  bool _otherProtections = false;
  String? _otherProtectionsText;

  List<String> get protection => _protectionRequired
      ? [
          ..._protection.entries
              .where((e) => e.value)
              .map((e) => e.key)
              .toList(),
          if (_protectionRequired &&
              _otherProtectionsText != null &&
              _otherProtectionsText!.isNotEmpty)
            _otherProtectionsText ?? ''
        ]
      : [];

  bool _uniformRequired = false;
  String? _uniform;

  String get uniform => _uniformRequired ? _uniform ?? '' : '';

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                'EPI et Tenue de travail',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            Text(
              '*Est-ce que l’élève devra porter des équipements de protection individuelle?',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            Row(
              children: [
                Radio(
                  value: true,
                  groupValue: _protectionRequired,
                  onChanged: (bool? newValue) =>
                      setState(() => _protectionRequired = newValue!),
                ),
                const Text('Oui'),
                const SizedBox(width: 32),
                Radio(
                  value: false,
                  groupValue: _protectionRequired,
                  onChanged: (bool? newValue) =>
                      setState(() => _protectionRequired = newValue!),
                ),
                const Text('Non'),
              ],
            ),
            Visibility(
              visible: _protectionRequired,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Text(
                      'Lesquels ?',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    ..._protection.keys.map(
                      (requirement) => CheckboxListTile(
                        visualDensity: VisualDensity.compact,
                        dense: true,
                        title: Text(
                          requirement,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        value: _protection[requirement],
                        onChanged: (newValue) => setState(
                            () => _protection[requirement] = newValue!),
                      ),
                    ),
                    CheckboxListTile(
                      visualDensity: VisualDensity.compact,
                      dense: true,
                      title: Text(
                        'Autre',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      value: _otherProtections,
                      onChanged: (newValue) =>
                          setState(() => _otherProtections = newValue!),
                    ),
                    Visibility(
                      visible: _otherProtections,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Précisez l\'équipement supplémentaire requis : ',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            TextFormField(
                              onSaved: (text) => _otherProtectionsText = text,
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
            ),
            const SizedBox(height: 16),
            Text(
              'Est-ce qu\'un uniforme est exigé ?',
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
                const Text('Oui'),
                const SizedBox(width: 32),
                Radio(
                  value: false,
                  groupValue: _uniformRequired,
                  onChanged: (bool? newValue) =>
                      setState(() => _uniformRequired = newValue!),
                ),
                const Text('Non'),
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
                      'Précisez le type d\'uniforme : ',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    TextFormField(
                      onSaved: (text) => _uniform = text,
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
