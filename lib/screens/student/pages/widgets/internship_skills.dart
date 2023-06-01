import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:crcrme_banque_stages/common/models/internship.dart';
import 'package:crcrme_banque_stages/common/models/internship_evaluation_attitude.dart';
import 'package:crcrme_banque_stages/common/models/internship_evaluation_skill.dart';
import 'package:crcrme_banque_stages/common/providers/enterprises_provider.dart';
import 'package:crcrme_banque_stages/misc/job_data_file_service.dart';
import 'package:crcrme_banque_stages/router.dart';
import 'package:crcrme_banque_stages/screens/internship_forms/student_steps/attitude_evaluation_form_controller.dart';
import 'package:crcrme_banque_stages/screens/internship_forms/student_steps/skill_evaluation_form_controller.dart';

class InternshipSkills extends StatefulWidget {
  const InternshipSkills({super.key, required this.internship});

  final Internship internship;

  @override
  State<InternshipSkills> createState() => _InternshipSkillsState();
}

class _InternshipSkillsState extends State<InternshipSkills> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 24),
      child: ExpansionPanelList(
        elevation: 0,
        expansionCallback: (index, isExpanded) =>
            setState(() => _isExpanded = !_isExpanded),
        children: [
          ExpansionPanel(
            isExpanded: _isExpanded,
            canTapOnHeader: true,
            headerBuilder: (context, isExpanded) => Text('Compétences',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge!
                    .copyWith(color: Colors.black)),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  alignment: Alignment.topRight,
                  children: [
                    Align(
                        alignment: Alignment.centerLeft,
                        child: _SpecificSkillBody(
                            internship: widget.internship,
                            evaluation: widget.internship.skillEvaluations)),
                    Container(
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: Theme.of(context).colorScheme.primary,
                              width: 3),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(18))),
                      child: IconButton(
                        onPressed: () => GoRouter.of(context).pushNamed(
                          Screens.skillEvaluationMainScreen,
                          params: Screens.params(widget.internship.id),
                          queryParams: Screens.queryParams(editMode: '1'),
                        ),
                        icon: const Icon(Icons.add_chart_rounded),
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 16.0),
                Stack(
                  alignment: Alignment.topRight,
                  children: [
                    Align(
                        alignment: Alignment.centerLeft,
                        child: _AttitudeBody(
                            internship: widget.internship,
                            evaluation: widget.internship.attitudeEvaluations)),
                    Container(
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: Theme.of(context).colorScheme.primary,
                              width: 3),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(18))),
                      child: IconButton(
                        onPressed: () => GoRouter.of(context).pushNamed(
                            Screens.attitudeEvaluationScreen,
                            queryParams: Screens.queryParams(editMode: '1'),
                            extra: AttitudeEvaluationFormController(
                                internshipId: widget.internship.id)),
                        icon: const Icon(Icons.playlist_add_sharp),
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    )
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _SpecificSkillBody extends StatefulWidget {
  const _SpecificSkillBody({
    required this.internship,
    required this.evaluation,
  });

  final Internship internship;
  final List<InternshipEvaluationSkill> evaluation;

  @override
  State<_SpecificSkillBody> createState() => _SpecificSkillBodyState();
}

class _SpecificSkillBodyState extends State<_SpecificSkillBody> {
  static const _interline = 12.0;
  int _currentEvaluationIndex = -1;
  int _nbPreviousEvaluations = -1;

  void _resetIndex() {
    if (_nbPreviousEvaluations != widget.evaluation.length) {
      _currentEvaluationIndex = widget.evaluation.length - 1;
      _nbPreviousEvaluations = widget.evaluation.length;
    }
  }

  Widget _buildLastEvaluation() {
    return Padding(
      padding: const EdgeInsets.only(bottom: _interline),
      child: Row(
        children: [
          const Text('Évaluation du : '),
          DropdownButton<int>(
            value: _currentEvaluationIndex,
            onChanged: (value) =>
                setState(() => _currentEvaluationIndex = value!),
            items: widget.evaluation
                .asMap()
                .keys
                .map((index) => DropdownMenuItem(
                    value: index,
                    child: Text(DateFormat('dd MMMM yyyy', 'fr_CA')
                        .format(widget.evaluation[index].date))))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPresentAtMeeting() {
    return Padding(
      padding: const EdgeInsets.only(bottom: _interline),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Personnes présentes',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          ...widget.evaluation[_currentEvaluationIndex].presentAtEvaluation
              .map((e) => Padding(
                    padding: const EdgeInsets.only(left: 12.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('\u2022 '),
                        Flexible(child: Text(e)),
                      ],
                    ),
                  ))
        ],
      ),
    );
  }

  Widget _buillSkillSection(String specializationId) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSkill(
            title: 'Compétences réussies',
            skills: widget.evaluation[_currentEvaluationIndex].skills
                .map<SkillEvaluation?>((e) =>
                    e.specializationId == specializationId &&
                            e.appreciation == SkillAppreciation.acquired
                        ? e
                        : null)
                .where((e) => e != null)
                .cast<SkillEvaluation>()
                .toList()),
        _buildSkill(
            title: 'Compétences à poursuivre',
            skills: widget.evaluation[_currentEvaluationIndex].skills
                .map<SkillEvaluation?>((e) =>
                    e.specializationId == specializationId &&
                            e.appreciation == SkillAppreciation.toPursuit
                        ? e
                        : null)
                .where((e) => e != null)
                .cast<SkillEvaluation>()
                .toList()),
        _buildSkill(
            title: 'Compétences non réussies',
            skills: widget.evaluation[_currentEvaluationIndex].skills
                .map<SkillEvaluation?>((e) =>
                    e.specializationId == specializationId &&
                            e.appreciation == SkillAppreciation.failed
                        ? e
                        : null)
                .where((e) => e != null)
                .cast<SkillEvaluation>()
                .toList()),
        _buildSkill(
            title: 'Compétences non évaluées',
            skills: widget.evaluation[_currentEvaluationIndex].skills
                .map<SkillEvaluation?>((e) =>
                    e.specializationId == specializationId &&
                            e.appreciation == SkillAppreciation.notEvaluated
                        ? e
                        : null)
                .where((e) => e != null)
                .cast<SkillEvaluation>()
                .toList()),
      ],
    );
  }

  Widget _buildSkill({
    required String title,
    required List<SkillEvaluation> skills,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: _interline),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(color: Theme.of(context).colorScheme.primary)),
          if (skills.isEmpty)
            const Padding(
                padding: EdgeInsets.only(left: 12.0),
                child: Text('\u2022 Aucune')),
          if (skills.isNotEmpty)
            ...skills.map((e) => Padding(
                  padding: const EdgeInsets.only(left: 12.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('\u2022 '),
                      Flexible(child: Text(e.skillName)),
                    ],
                  ),
                ))
        ],
      ),
    );
  }

  Widget _buildComment() {
    return Padding(
      padding: const EdgeInsets.only(bottom: _interline),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Commentaires sur le stage',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 12.0),
            child: Text(
                widget.evaluation[_currentEvaluationIndex].comments.isEmpty
                    ? 'Aucun commentaire'
                    : widget.evaluation[_currentEvaluationIndex].comments),
          ),
        ],
      ),
    );
  }

  Widget _buildShowOtherDate() {
    return Padding(
      padding: const EdgeInsets.only(bottom: _interline),
      child: Center(
        child: OutlinedButton(
            onPressed: () {
              GoRouter.of(context).pushNamed(Screens.skillEvaluationFormScreen,
                  queryParams: Screens.queryParams(editMode: '0'),
                  extra: SkillEvaluationFormController.fromInternshipId(
                    context,
                    internshipId: widget.internship.id,
                    evaluationIndex: _currentEvaluationIndex,
                  ));
            },
            child: const Text('Voir l\'évaluation détaillée')),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _resetIndex();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('C1. Compétences spécifiques du métier',
            style: TextStyle(fontWeight: FontWeight.bold)),
        if (widget.evaluation.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 8.0, bottom: 4.0),
            child: Text('Aucune évaluation disponible pour ce stage.'),
          ),
        if (widget.evaluation.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLastEvaluation(),
              _buildPresentAtMeeting(),
              if (widget.internship.extraSpecializationsId.isNotEmpty)
                Text(
                  EnterprisesProvider.of(context, listen: false)
                      .fromId(widget.internship.enterpriseId)
                      .jobs
                      .fromId(widget.internship.jobId)
                      .specialization
                      .idWithName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              _buillSkillSection(EnterprisesProvider.of(context)
                  .fromId(widget.internship.enterpriseId)
                  .jobs
                  .fromId(widget.internship.jobId)
                  .specialization
                  .id),
              if (widget.internship.extraSpecializationsId.isNotEmpty)
                ...widget.internship.extraSpecializationsId
                    .asMap()
                    .keys
                    .map((index) => Padding(
                          padding: const EdgeInsets.only(bottom: _interline),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ActivitySectorsService.specialization(widget
                                        .internship
                                        .extraSpecializationsId[index])
                                    .idWithName,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              _buillSkillSection(widget
                                  .internship.extraSpecializationsId[index]),
                            ],
                          ),
                        )),
              _buildComment(),
              _buildShowOtherDate(),
            ],
          )
      ],
    );
  }
}

class _AttitudeBody extends StatefulWidget {
  const _AttitudeBody({
    required this.internship,
    required this.evaluation,
  });

  final Internship internship;
  final List<InternshipEvaluationAttitude> evaluation;

  @override
  State<_AttitudeBody> createState() => _AttitudeBodyState();
}

class _AttitudeBodyState extends State<_AttitudeBody> {
  static const _interline = 12.0;
  int _currentEvaluationIndex = -1;
  int _nbPreviousEvaluations = -1;

  void _resetIndex() {
    if (_nbPreviousEvaluations != widget.evaluation.length) {
      _currentEvaluationIndex = widget.evaluation.length - 1;
      _nbPreviousEvaluations = widget.evaluation.length;
    }
  }

  Widget _buildLastEvaluation() {
    return Padding(
      padding: const EdgeInsets.only(bottom: _interline),
      child: Row(
        children: [
          const Text('Évaluation du : '),
          DropdownButton<int>(
            value: _currentEvaluationIndex,
            onChanged: (value) =>
                setState(() => _currentEvaluationIndex = value!),
            items: widget.evaluation
                .asMap()
                .keys
                .map((index) => DropdownMenuItem(
                    value: index,
                    child: Text(DateFormat('dd MMMM yyyy', 'fr_CA')
                        .format(widget.evaluation[index].date))))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPresentAtMeeting() {
    return Padding(
      padding: const EdgeInsets.only(bottom: _interline),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Personnes présentes',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          ...widget.evaluation[_currentEvaluationIndex].presentAtEvaluation
              .map((e) => Padding(
                    padding: const EdgeInsets.only(left: 12.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('\u2022 '),
                        Flexible(child: Text(e)),
                      ],
                    ),
                  ))
        ],
      ),
    );
  }

  Widget _buildAttitudeIsGood() {
    return Padding(
      padding: const EdgeInsets.only(bottom: _interline),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Conformes aux exigences',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          ...widget
              .evaluation[_currentEvaluationIndex].attitude.meetsRequirements
              .map((e) => Padding(
                    padding: const EdgeInsets.only(left: 12.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('\u2022 '),
                        Flexible(child: Text(e)),
                      ],
                    ),
                  ))
        ],
      ),
    );
  }

  Widget _buildAttitudeIsBad() {
    return Padding(
      padding: const EdgeInsets.only(bottom: _interline),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'À améliorer',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          ...widget.evaluation[_currentEvaluationIndex].attitude
              .doesNotMeetRequirements
              .map((e) => Padding(
                    padding: const EdgeInsets.only(left: 12.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('\u2022 '),
                        Flexible(child: Text(e)),
                      ],
                    ),
                  ))
        ],
      ),
    );
  }

  Widget _buildGeneralAppreciation() {
    return Padding(
      padding: const EdgeInsets.only(bottom: _interline),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Appréciation générale',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 12.0),
            child: Text(GeneralAppreciation
                .values[widget.evaluation[_currentEvaluationIndex].attitude
                    .generalAppreciation]
                .name),
          ),
        ],
      ),
    );
  }

  Widget _buildComment() {
    return Padding(
      padding: const EdgeInsets.only(bottom: _interline),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Commentaires sur le stage',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 12.0),
            child: Text(
                widget.evaluation[_currentEvaluationIndex].comments.isEmpty
                    ? 'Aucun commentaire'
                    : widget.evaluation[_currentEvaluationIndex].comments),
          ),
        ],
      ),
    );
  }

  Widget _buildShowOtherForms() {
    return Padding(
      padding: const EdgeInsets.only(bottom: _interline),
      child: Center(
        child: OutlinedButton(
            onPressed: () {
              GoRouter.of(context).pushNamed(Screens.attitudeEvaluationScreen,
                  queryParams: Screens.queryParams(editMode: '0'),
                  extra: AttitudeEvaluationFormController.fromInternshipId(
                    context,
                    internshipId: widget.internship.id,
                    evaluationIndex: _currentEvaluationIndex,
                  ));
            },
            child: const Text('Voir l\'évaluation détaillée')),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _resetIndex();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('C2. Attitudes et comportements',
            style: TextStyle(fontWeight: FontWeight.bold)),
        if (widget.evaluation.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 8.0, bottom: 4.0),
            child: Text('Aucune évaluation disponible pour ce stage.'),
          ),
        if (widget.evaluation.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLastEvaluation(),
              _buildPresentAtMeeting(),
              _buildAttitudeIsGood(),
              _buildAttitudeIsBad(),
              _buildGeneralAppreciation(),
              _buildComment(),
              _buildShowOtherForms(),
            ],
          )
      ],
    );
  }
}
