import 'package:crcrme_banque_stages/router.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '/common/models/internship.dart';
import '/common/models/internship_evaluation.dart';
import '/common/providers/enterprises_provider.dart';

class InternshipSkills extends StatefulWidget {
  const InternshipSkills({super.key, required this.internship});

  final Internship internship;

  @override
  State<InternshipSkills> createState() => _InternshipSkillsState();
}

class _InternshipSkillsState extends State<InternshipSkills> {
  bool _isExpanded = true;

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
            body: Stack(
              alignment: Alignment.topRight,
              children: [
                Align(
                    alignment: Alignment.centerLeft,
                    child: _SpecificSkillBody(
                        internship: widget.internship,
                        evaluation: widget.internship.studentEvaluation)),
                IconButton(
                    onPressed: () => GoRouter.of(context).pushNamed(
                        Screens.studentEvaluationMainScreen,
                        params: {'internshipId': widget.internship.id}),
                    icon: const Icon(
                      Icons.add_chart_rounded,
                      color: Colors.black,
                    ))
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
  final List<InternshipEvaluation> evaluation;

  @override
  State<_SpecificSkillBody> createState() => _SpecificSkillBodyState();
}

class _SpecificSkillBodyState extends State<_SpecificSkillBody> {
  static const _interline = 12.0;
  late var _currentEvaluationIndex = widget.evaluation.length - 1;

  Widget _buildLastEvaluation() {
    return Padding(
      padding: const EdgeInsets.only(bottom: _interline),
      child: Text('Dernière évaluation : '
          '${DateFormat('dd MMMM yyyy', 'fr_CA').format(widget.evaluation[_currentEvaluationIndex].date)}'),
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

  Widget _buillSkillSection(String jobId) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSkill(
            title: 'Compétences acquises',
            skills: widget.evaluation[_currentEvaluationIndex].skills
                .map<SkillEvaluation?>((e) => e.specializationId == jobId &&
                        e.appreciation == SkillAppreciation.acquired
                    ? e
                    : null)
                .where((e) => e != null)
                .cast<SkillEvaluation>()
                .toList()),
        _buildSkill(
            title: 'Compétences à poursuivre',
            skills: widget.evaluation[_currentEvaluationIndex].skills
                .map<SkillEvaluation?>((e) => e.specializationId == jobId &&
                        e.appreciation == SkillAppreciation.toPursuit
                    ? e
                    : null)
                .where((e) => e != null)
                .cast<SkillEvaluation>()
                .toList()),
        _buildSkill(
            title: 'Compétences échouées',
            skills: widget.evaluation[_currentEvaluationIndex].skills
                .map<SkillEvaluation?>((e) => e.specializationId == jobId &&
                        e.appreciation == SkillAppreciation.failed
                    ? e
                    : null)
                .where((e) => e != null)
                .cast<SkillEvaluation>()
                .toList()),
        _buildSkill(
            title: 'Compétences non-évaluées',
            skills: widget.evaluation[_currentEvaluationIndex].skills
                .map<SkillEvaluation?>((e) => e.specializationId == jobId &&
                        e.appreciation == SkillAppreciation.notEvaluated
                    ? e
                    : null)
                .where((e) => e != null)
                .cast<SkillEvaluation>()
                .toList()),
      ],
    );
  }

  Widget _buildSkill({required title, required List<SkillEvaluation> skills}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: _interline),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title),
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

  Widget _buildShowOtherForms() {
    return Padding(
      padding: const EdgeInsets.only(bottom: _interline),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Afficher formulaire d\'évaluation'),
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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('C1. Compétences spécifiques du métier',
            style: TextStyle(fontWeight: FontWeight.bold)),
        if (widget.evaluation.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 8.0, bottom: 4.0),
            child: Text('Aucune évaluation disponible pour ce stage'),
          ),
        if (widget.evaluation.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLastEvaluation(),
              _buildPresentAtMeeting(),
              if (widget.internship.extraSpecializationsId.isNotEmpty)
                const Text(
                  'Métier principal',
                  style: TextStyle(fontWeight: FontWeight.bold),
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
                                'Métier secondaire${widget.internship.extraSpecializationsId.length > 1 ? ' (${index + 1})' : ''}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              _buillSkillSection(widget
                                  .internship.extraSpecializationsId[index]),
                            ],
                          ),
                        )),
              _buildComment(),
              _buildShowOtherForms(),
            ],
          )
      ],
    );
  }
}
