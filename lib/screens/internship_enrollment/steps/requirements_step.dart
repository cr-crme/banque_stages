import 'package:flutter/material.dart';

import 'package:crcrme_banque_stages/common/models/protections.dart';
import 'package:crcrme_banque_stages/common/models/uniform.dart';
import 'package:crcrme_banque_stages/common/widgets/sub_title.dart';

class RequirementsStep extends StatefulWidget {
  const RequirementsStep({super.key});

  static const protectionsList = [
    'Chaussures à cap d\'acier',
    'Chaussures à semelles antidérapantes',
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

  bool validateProtectionsCheckboxes() {
    if (protectionsStatus == ProtectionsStatus.none) return true;

    for (final protection in _protections.keys) {
      if (_protections[protection]!) return true;
    }

    // If none is check, there is still the option for "other". If it is check
    // there is no need to check the textfield as it is already done
    if (_otherProtections) return true;

    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Indiquer au moins un équipement.')));
    return false;
  }

  ProtectionsStatus protectionsStatus = ProtectionsStatus.none;
  final Map<String, bool> _protections =
      Map.fromIterable(RequirementsStep.protectionsList, value: (e) => false);

  bool _otherProtections = false;
  String? _otherProtectionsText;
  String get otherProtections =>
      _otherProtections ? _otherProtectionsText ?? '' : '';

  List<String> get protections => protectionsStatus == ProtectionsStatus.none
      ? []
      : [
          ..._protections.entries
              .where((e) => e.value)
              .map((e) => e.key)
              .toList(),
          if (_otherProtectionsText != null &&
              _otherProtectionsText!.isNotEmpty)
            _otherProtectionsText ?? ''
        ];

  UniformStatus uniformStatus = UniformStatus.none;
  String? _uniform;

  String get uniform =>
      uniformStatus == UniformStatus.none ? '' : _uniform ?? '';

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
                  'Est-ce que l\'élève devra porter des équipements de protection individuelle (EPI)?',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RadioListTile<ProtectionsStatus>(
                        dense: true,
                        visualDensity: VisualDensity.compact,
                        value: ProtectionsStatus.suppliedByEnterprise,
                        groupValue: protectionsStatus,
                        onChanged: (newValue) =>
                            setState(() => protectionsStatus = newValue!),
                        title: Text(
                          ProtectionsStatus.suppliedByEnterprise.name,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      RadioListTile<ProtectionsStatus>(
                        dense: true,
                        visualDensity: VisualDensity.compact,
                        value: ProtectionsStatus.suppliedBySchool,
                        groupValue: protectionsStatus,
                        onChanged: (newValue) =>
                            setState(() => protectionsStatus = newValue!),
                        title: Text(
                          ProtectionsStatus.suppliedBySchool.name,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      RadioListTile<ProtectionsStatus>(
                        dense: true,
                        visualDensity: VisualDensity.compact,
                        value: ProtectionsStatus.none,
                        groupValue: protectionsStatus,
                        onChanged: (newValue) =>
                            setState(() => protectionsStatus = newValue!),
                        title: Text(
                          ProtectionsStatus.none.name,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
                Visibility(
                  visible: protectionsStatus != ProtectionsStatus.none,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Lesquels\u00a0?',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      ..._protections.keys.map(
                        (requirement) => Padding(
                          padding: const EdgeInsets.only(left: 12.0),
                          child: CheckboxListTile(
                            controlAffinity: ListTileControlAffinity.leading,
                            visualDensity: VisualDensity.compact,
                            dense: true,
                            title: Text(
                              requirement,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            value: _protections[requirement],
                            onChanged: (newValue) => setState(
                                () => _protections[requirement] = newValue!),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 12.0),
                        child: CheckboxListTile(
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
                                '* Préciser l\'équipement supplémentaire requis\u00a0: ',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              TextFormField(
                                onSaved: (text) => _otherProtectionsText = text,
                                onChanged: (text) =>
                                    _otherProtectionsText = text,
                                minLines: 2,
                                maxLines: null,
                                validator: (text) =>
                                    _otherProtections && text!.isEmpty
                                        ? 'Indiquer au moins un équipement.'
                                        : null,
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
                  'Est-ce qu\'une tenue de travail spécifique est exigée\u00a0?',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 12.0),
                  child: Column(
                    children: [
                      RadioListTile<UniformStatus>(
                        dense: true,
                        visualDensity: VisualDensity.compact,
                        value: UniformStatus.suppliedByEnterprise,
                        groupValue: uniformStatus,
                        onChanged: (newValue) =>
                            setState(() => uniformStatus = newValue!),
                        title: Text(
                          UniformStatus.suppliedByEnterprise.name,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      RadioListTile<UniformStatus>(
                        dense: true,
                        visualDensity: VisualDensity.compact,
                        value: UniformStatus.suppliedByStudent,
                        groupValue: uniformStatus,
                        onChanged: (newValue) =>
                            setState(() => uniformStatus = newValue!),
                        title: Text(
                          UniformStatus.suppliedByStudent.name,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      RadioListTile<UniformStatus>(
                        dense: true,
                        visualDensity: VisualDensity.compact,
                        value: UniformStatus.none,
                        groupValue: uniformStatus,
                        onChanged: (newValue) =>
                            setState(() => uniformStatus = newValue!),
                        title: Text(
                          UniformStatus.none.name,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
                Visibility(
                  visible: uniformStatus != UniformStatus.none,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '* Décrire la tenue exigée par l\'entreprise ou les '
                          'règles d\'habillement ? : ',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        TextFormField(
                          onSaved: (text) => _uniform = text,
                          onChanged: (text) => _uniform = text,
                          minLines: 2,
                          maxLines: null,
                          validator: (text) =>
                              uniformStatus != UniformStatus.none &&
                                      text!.isEmpty
                                  ? 'Décrire la tenue de travail.'
                                  : null,
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
