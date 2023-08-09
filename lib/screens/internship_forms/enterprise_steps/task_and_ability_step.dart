import 'package:collection/collection.dart';
import 'package:crcrme_banque_stages/common/models/enterprise.dart';
import 'package:crcrme_banque_stages/common/models/internship.dart';
import 'package:crcrme_banque_stages/common/models/required_skill.dart';
import 'package:crcrme_banque_stages/common/models/student.dart';
import 'package:crcrme_banque_stages/common/providers/enterprises_provider.dart';
import 'package:crcrme_banque_stages/common/providers/students_provider.dart';
import 'package:crcrme_banque_stages/common/widgets/form_fields/checkbox_with_other.dart';
import 'package:crcrme_banque_stages/common/widgets/sub_title.dart';
import 'package:flutter/material.dart';

enum _TaskVariety { none, low, high }

enum _TrainingPlan { none, notFilled, filled }

class TaskAndAbilityStep extends StatefulWidget {
  const TaskAndAbilityStep({
    super.key,
    required this.internship,
  });

  final Internship internship;

  @override
  State<TaskAndAbilityStep> createState() => TaskAndAbilityStepState();
}

class TaskAndAbilityStepState extends State<TaskAndAbilityStep> {
  final _formKey = GlobalKey<FormState>();

// Tasks
  var _taskVariety = _TaskVariety.none;
  double? get taskVariety => _taskVariety == _TaskVariety.none
      ? null
      : _taskVariety == _TaskVariety.low
          ? 0.0
          : 1.0;
  var _trainingPlan = _TrainingPlan.none;
  double? get trainingPlan => _trainingPlan == _TrainingPlan.none
      ? null
      : _trainingPlan == _TrainingPlan.notFilled
          ? 0.0
          : 1.0;

  final _skillKey = GlobalKey<CheckboxWithOtherState<RequiredSkills>>();
  List<String> get requiredSkills => _skillKey.currentState!.values;

  Future<String?> validate() async {
    if (!_formKey.currentState!.validate() ||
        taskVariety == null ||
        trainingPlan == null) {
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
    final student = StudentsProvider.studentsInMyGroups(context)
        .firstWhereOrNull((e) => e.id == widget.internship.studentId);

    return student == null
        ? Container()
        : Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SubTitle('Informations générales', left: 0),
                  _buildEnterpriseName(enterprise),
                  _buildStudentName(student),
                  const SubTitle('Tâches', left: 0),
                  _buildVariety(context),
                  const SizedBox(height: 8),
                  _buildTrainingPlan(context),
                  const SubTitle('Habiletés', left: 0),
                  const SizedBox(height: 16),
                  _buildSkillsRequired(context),
                ],
              ),
            ),
          );
  }

  Widget _buildSkillsRequired(BuildContext context) {
    return CheckboxWithOther(
      key: _skillKey,
      title: '* Habiletés requises pour le stage\u00a0:',
      elements: RequiredSkills.values,
      errorMessageOther: 'Préciser les autres habiletés requises.',
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

  Widget _buildVariety(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '* Tâches données à l\'élève',
          style: Theme.of(context)
              .textTheme
              .titleSmall!
              .copyWith(fontWeight: FontWeight.bold),
        ),
        Row(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.4,
              child: RadioListTile<_TaskVariety>(
                value: _TaskVariety.low,
                dense: true,
                groupValue: _taskVariety,
                visualDensity: VisualDensity.compact,
                onChanged: (value) => setState(() => _taskVariety = value!),
                title: Text(
                  'Peu variées',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.4,
              child: RadioListTile<_TaskVariety>(
                value: _TaskVariety.high,
                groupValue: _taskVariety,
                dense: true,
                visualDensity: VisualDensity.compact,
                onChanged: (value) => setState(() => _taskVariety = value!),
                title: Text(
                  'Très variées',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            )
          ],
        ),
      ],
    );
  }

  Widget _buildTrainingPlan(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '* Respect du plan de formation',
          style: Theme.of(context)
              .textTheme
              .titleSmall!
              .copyWith(fontWeight: FontWeight.bold),
        ),
        Text(
          'Tâches et compétences prévues dans le plan de formation ont été '
          'faites par l\'élève\u00a0:',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        Row(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.4,
              child: RadioListTile<_TrainingPlan>(
                value: _TrainingPlan.notFilled,
                dense: true,
                groupValue: _trainingPlan,
                visualDensity: VisualDensity.compact,
                onChanged: (value) => setState(() => _trainingPlan = value!),
                title: Text(
                  'En partie',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.4,
              child: RadioListTile<_TrainingPlan>(
                value: _TrainingPlan.filled,
                groupValue: _trainingPlan,
                dense: true,
                visualDensity: VisualDensity.compact,
                onChanged: (value) => setState(() => _trainingPlan = value!),
                title: Text(
                  'En totalité',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            )
          ],
        ),
      ],
    );
  }
}
