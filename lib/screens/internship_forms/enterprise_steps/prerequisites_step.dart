import 'package:collection/collection.dart';
import 'package:crcrme_banque_stages/common/models/enterprise.dart';
import 'package:crcrme_banque_stages/common/models/internship.dart';
import 'package:crcrme_banque_stages/common/models/student.dart';
import 'package:crcrme_banque_stages/common/providers/enterprises_provider.dart';
import 'package:crcrme_banque_stages/common/providers/students_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';

class PrerequisitesStep extends StatefulWidget {
  const PrerequisitesStep({
    super.key,
    required this.internship,
  });

  final Internship internship;

  @override
  State<PrerequisitesStep> createState() => PrerequisitesStepState();
}

class PrerequisitesStepState extends State<PrerequisitesStep> {
  final _formKey = GlobalKey<FormState>();

  int minimalAge = 15;

  final Map<String, bool> requiredForJob = {
    'Une entrevue de recrutement de l\'élève en solo': false,
    'Une vérification des antécédents judiciaires pour les élèves majeurs':
        false,
  };
  bool _otherRequirements = false;
  String? otherRequirementsText;

  final Map<String, bool> skillsRequired = {
    'Communiquer à l\'écrit': false,
    'Communiquer en anglais': false,
    'Conduire un chariot (élèves CFER)': false,
    'Interagir avec des clients': false,
    'Manipuler de l\'argent': false,
  };

  bool _otherSkills = false;
  String? otherSkillsText;

  Future<String?> validate() async {
    if (!_formKey.currentState!.validate()) {
      return 'Remplir tous les champs avec un *.';
    }
    _formKey.currentState!.save();
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final enterprise = EnterprisesProvider.of(context, listen: false)
        .firstWhereOrNull((e) => e.id == widget.internship.enterpriseId);

    // Sometimes for some reason the build is called this with these
    // provider empty on the first call
    if (enterprise == null) return Container();

    return FutureBuilder<Student?>(
        future: StudentsProvider.fromLimitedId(context,
            studentId: widget.internship.studentId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          final student = snapshot.data;
          if (student == null) return Container();

          return Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStudentName(student),
                  _buildEnterpriseName(enterprise),
                  _buildScholarYear(widget.internship),
                  _buildMinimumAge(context),
                  const SizedBox(height: 16),
                  _buildRequirements(context),
                  const SizedBox(height: 16),
                  _buildSkillsRequired(context),
                ],
              ),
            ),
          );
        });
  }

  Widget _buildSkillsRequired(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '* Habiletés requises pour le stage\u00a0:',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        Column(
          children: skillsRequired.keys
              .map(
                (skill) => CheckboxListTile(
                  visualDensity: VisualDensity.compact,
                  dense: true,
                  controlAffinity: ListTileControlAffinity.leading,
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
          controlAffinity: ListTileControlAffinity.leading,
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
                  '* Préciser\u00a0:',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                TextFormField(
                  onChanged: (text) => otherSkillsText = text,
                  minLines: 2,
                  maxLines: null,
                  validator: (value) => _otherSkills &&
                          (otherSkillsText == null || otherSkillsText!.isEmpty)
                      ? 'Préciser les autres habiletés requises.'
                      : null,
                  keyboardType: TextInputType.multiline,
                ),
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget _buildRequirements(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '* Exigences de l\'entreprise avant d\'accueillir des élèves en stage\u00a0:',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        ...requiredForJob.keys
            .map(
              (requirement) => CheckboxListTile(
                visualDensity: VisualDensity.compact,
                dense: true,
                controlAffinity: ListTileControlAffinity.leading,
                title: Text(
                  requirement,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                value: requiredForJob[requirement],
                onChanged: (newValue) =>
                    setState(() => requiredForJob[requirement] = newValue!),
              ),
            )
            .toList(),
        CheckboxListTile(
          visualDensity: VisualDensity.compact,
          dense: true,
          controlAffinity: ListTileControlAffinity.leading,
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
                  'Préciser\u00a0:',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                TextFormField(
                  onChanged: (text) => otherRequirementsText = text,
                  minLines: 2,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  validator: (value) => _otherRequirements &&
                          (otherRequirementsText == null ||
                              otherRequirementsText!.isEmpty)
                      ? 'Préciser les autres exigences de l\'entreprise.'
                      : null,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMinimumAge(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '* Âge minimum des stagiaires (ans)\u00a0:',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.3,
          child: _AgeSpinBox(
            initialValue: minimalAge,
            onSaved: (newValue) => minimalAge = newValue!,
          ),
        ),
      ],
    );
  }

  TextField _buildScholarYear(Internship internship) {
    final starting = internship.dateFrom(0).start;
    final startingYear = starting.month < 9 ? starting.year - 1 : starting.year;
    final scholarYear = DateTimeRange(
        start: DateTime(startingYear), end: DateTime(startingYear + 1));

    return TextField(
      decoration: const InputDecoration(
          labelText: 'Année scolaire', border: InputBorder.none),
      controller: TextEditingController(
          text: '${scholarYear.start.year}-${scholarYear.end.year}'),
      enabled: false,
    );
  }

  TextField _buildEnterpriseName(Enterprise enterprise) {
    return TextField(
      decoration: const InputDecoration(
          labelText: 'Nom de l\'entreprise', border: InputBorder.none),
      controller: TextEditingController(text: enterprise.name),
      enabled: false,
    );
  }

  TextField _buildStudentName(Student student) {
    return TextField(
      decoration: const InputDecoration(
          labelText: 'Nom de l\'élève', border: InputBorder.none),
      controller: TextEditingController(text: student.fullName),
      enabled: false,
    );
  }
}

class _AgeSpinBox extends FormField<int> {
  const _AgeSpinBox({super.onSaved, super.initialValue = 0})
      : super(builder: _build);

  static Widget _build(FormFieldState<int> state) {
    return SpinBox(
      value: state.widget.initialValue!.toDouble(),
      min: 10,
      max: 30,
      spacing: 0,
      decoration: const InputDecoration(border: UnderlineInputBorder()),
      onChanged: (double value) => state.didChange(value.toInt()),
    );
  }
}
