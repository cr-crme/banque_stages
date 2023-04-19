import 'package:flutter/material.dart';

import '/common/widgets/sub_title.dart';

class RequirementsStep extends StatefulWidget {
  const RequirementsStep({super.key});

  static const protectionsList = [
    'Chaussures de sécurité',
    'Lunettes de sécurité',
    'Protections auditives',
    'Masque',
    'Casque',
    'Gants',
  ];

  @override
  State<RequirementsStep> createState() => RequirementsStepState();
}

class RequirementsStepState extends State<RequirementsStep> {
  final formKey = GlobalKey<FormState>();

  bool _protectionsRequired = false;
  final Map<String, bool> _protection =
      Map.fromIterable(RequirementsStep.protectionsList, value: (e) => false);

  bool _otherProtections = false;
  String? _otherProtectionsText;

  List<String> get protections => _protectionsRequired
      ? [
          ..._protection.entries
              .where((e) => e.value)
              .map((e) => e.key)
              .toList(),
          if (_protectionsRequired &&
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SubTitle('EPI et Tenue de travail', top: 0, left: 0),
          Padding(
            padding: const EdgeInsets.only(left: 12.0, right: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '*Est-ce que l\'élève devra porter des équipements de protection individuelle?',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 12.0),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 125,
                        child: RadioListTile(
                          value: true,
                          groupValue: _protectionsRequired,
                          onChanged: (bool? newValue) =>
                              setState(() => _protectionsRequired = newValue!),
                          title: const Text('Oui'),
                        ),
                      ),
                      SizedBox(
                        width: 125,
                        child: RadioListTile(
                          value: false,
                          groupValue: _protectionsRequired,
                          onChanged: (bool? newValue) =>
                              setState(() => _protectionsRequired = newValue!),
                          title: const Text('Non'),
                        ),
                      ),
                    ],
                  ),
                ),
                Visibility(
                  visible: _protectionsRequired,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Lesquels ?',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      ..._protection.keys.map(
                        (requirement) => CheckboxListTile(
                          controlAffinity: ListTileControlAffinity.leading,
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
                        controlAffinity: ListTileControlAffinity.leading,
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
                const SizedBox(height: 16),
                Text(
                  'Est-ce qu\'un uniforme est exigé ?',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 12.0),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 125,
                        child: RadioListTile(
                          value: true,
                          groupValue: _uniformRequired,
                          onChanged: (bool? newValue) =>
                              setState(() => _uniformRequired = newValue!),
                          title: const Text('Oui'),
                        ),
                      ),
                      SizedBox(
                        width: 125,
                        child: RadioListTile(
                          value: false,
                          groupValue: _uniformRequired,
                          onChanged: (bool? newValue) =>
                              setState(() => _uniformRequired = newValue!),
                          title: const Text('Non'),
                        ),
                      ),
                    ],
                  ),
                ),
                Visibility(
                  visible: _uniformRequired,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 24),
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
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.multiline,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
