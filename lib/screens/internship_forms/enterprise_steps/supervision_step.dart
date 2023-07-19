import 'package:crcrme_banque_stages/common/models/job.dart';
import 'package:crcrme_banque_stages/common/widgets/form_fields/low_high_slider_form_field.dart';
import 'package:crcrme_banque_stages/common/widgets/sub_title.dart';
import 'package:flutter/material.dart';

enum _TaskVariety { none, low, high }

enum _TrainingPlan { none, notFilled, filled }

class SupervisionStep extends StatefulWidget {
  const SupervisionStep({
    super.key,
    required this.job,
  });

  final Job job;

  @override
  State<SupervisionStep> createState() => SupervisionStepState();
}

class SupervisionStepState extends State<SupervisionStep> {
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

  // Expectations
  double? autonomyExpected;
  double? efficiencyExpected;

  // Management
  double? supervisionStyle;
  double? easeOfCommunication;
  double? absenceAcceptance;

  // Commentaires
  final _commentsController = TextEditingController();
  String get supervisionComments => _commentsController.text;

  Future<String?> validate() async {
    if (!_formKey.currentState!.validate() || taskVariety == null) {
      return 'Remplir tous les champs avec un *.';
    }
    _formKey.currentState!.save();
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SubTitle('Tâches', left: 0),
            _buildVariety(context),
            const SizedBox(height: 8),
            _buildTrainingPlan(context),
            const SizedBox(height: 8),
            const SubTitle('Attentes envers le stagiaire', left: 0),
            _buildAutonomyRequired(context),
            const SizedBox(height: 8),
            _buildEfficiency(context),
            const SubTitle('Encadrement', left: 0),
            _buildSupervisionStyle(context),
            const SizedBox(height: 8),
            _buildCommunication(context),
            const SizedBox(height: 8),
            _buildAbsenceTolerance(context),
            const SizedBox(height: 8),
            _Comments(controller: _commentsController),
          ],
        ),
      ),
    );
  }

  Widget _buildAbsenceTolerance(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '* Tolérance du milieu à l\'égard des retards et absences de l\'élève',
          style: Theme.of(context)
              .textTheme
              .bodyLarge!
              .copyWith(fontWeight: FontWeight.bold),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: LowHighSliderFormField(
            onSaved: (value) => absenceAcceptance = value,
            lowLabel: 'Aucune\ntolérance',
            highLabel: 'Grande\ntolérance',
          ),
        )
      ],
    );
  }

  Widget _buildCommunication(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '* Communication avec l\'entreprise',
          style: Theme.of(context)
              .textTheme
              .bodyLarge!
              .copyWith(fontWeight: FontWeight.bold),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: LowHighSliderFormField(
            onSaved: (value) => easeOfCommunication = value,
            lowLabel: 'Retour\ndifficile à\nobtenir',
            highLabel: 'Retour\ntrès facile à\nobtenir',
          ),
        )
      ],
    );
  }

  Widget _buildSupervisionStyle(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '* Type d\'encadrement',
          style: Theme.of(context)
              .textTheme
              .bodyLarge!
              .copyWith(fontWeight: FontWeight.bold),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: LowHighSliderFormField(
            onSaved: (value) => supervisionStyle = value,
            lowLabel: 'Milieu peu\nencadrant',
            highLabel: 'Milieu très\nencadrant',
          ),
        )
      ],
    );
  }

  Widget _buildEfficiency(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '* Rendement de l\'élève',
          style: Theme.of(context)
              .textTheme
              .bodyLarge!
              .copyWith(fontWeight: FontWeight.bold),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: LowHighSliderFormField(
            onSaved: (value) => efficiencyExpected = value,
            lowLabel: 'Aucun\nrendement\nexigé',
            highLabel: 'Élève\nproductif',
          ),
        )
      ],
    );
  }

  Widget _buildAutonomyRequired(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '* Niveau d\'autonomie de l\'élève souhaité',
          style: Theme.of(context)
              .textTheme
              .bodyLarge!
              .copyWith(fontWeight: FontWeight.bold),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: LowHighSliderFormField(
            onSaved: (value) => autonomyExpected = value,
            lowLabel: 'Élève pas\nautonome',
            highLabel: 'Élève très\nautonome',
          ),
        ),
      ],
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
              .bodyLarge!
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
              .bodyLarge!
              .copyWith(fontWeight: FontWeight.bold),
        ),
        Text(
          'Tâches et compétences prévues dans le plan de formation ont été'
          'faites par l\'élève\u00a0:',
          style: Theme.of(context).textTheme.bodyLarge,
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

class _Comments extends StatelessWidget {
  const _Comments({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    const spacing = 8.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: spacing),
          child: Text(
            'Autres commentaires sur l\'encadrement',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        TextFormField(
          controller: controller,
          enabled: true,
          maxLines: null,
        ),
      ],
    );
  }
}
