import 'package:flutter/material.dart';

import '/common/models/internship_evaluation_skill.dart';
import '/common/models/student.dart';
import '/common/providers/enterprises_provider.dart';
import '/common/providers/internships_provider.dart';
import '/common/widgets/sub_title.dart';
import '/misc/job_data_file_service.dart';

class SkillsPage extends StatefulWidget {
  const SkillsPage({super.key, required this.student});

  final Student student;

  @override
  State<SkillsPage> createState() => SkillsPageState();
}

class SkillsPageState extends State<SkillsPage> {
  Map<Specialization, List<SkillEvaluation>> _getAcquiredSkills(
      Map<Specialization, List<SkillEvaluation>> skills) {
    final Map<Specialization, List<SkillEvaluation>> out = {};
    for (final specialization in skills.keys) {
      out[specialization] = [];
      for (final skillEvaluation in skills[specialization]!) {
        if (skillEvaluation.appreciation == SkillAppreciation.acquired) {
          out[specialization]!.add(skillEvaluation);
        }
      }
    }
    return out;
  }

  Map<Specialization, List<SkillEvaluation>> _getToPursuitSkills(
      Map<Specialization, List<SkillEvaluation>> skills) {
    final Map<Specialization, List<SkillEvaluation>> out = {};
    for (final specialization in skills.keys) {
      out[specialization] = [];
      for (final skillEvaluation in skills[specialization]!) {
        if (skillEvaluation.appreciation != SkillAppreciation.acquired) {
          out[specialization]!.add(skillEvaluation);
        }
      }
    }
    return out;
  }

  Map<Specialization, List<SkillEvaluation>> _getAllStudentSkills(
      BuildContext context) {
    final enterprises = EnterprisesProvider.of(context, listen: false);
    final internships = InternshipsProvider.of(context, listen: false)
        .byStudentId(widget.student.id);

    Map<Specialization, List<SkillEvaluation>> out = {};
    for (final internship in internships) {
      final List<Specialization> specializations = [];

      // Fetch all the specialization of the current internship
      specializations.add(enterprises
          .fromId(internship.enterpriseId)
          .jobs[internship.jobId]
          .specialization);
      specializations.addAll(internship.extraSpecializationsId
          .map((id) => ActivitySectorsService.specialization(id)));

      for (final specialization in specializations) {
        if (!out.containsKey(specialization)) out[specialization] = [];

        for (final evaluation in internship.skillEvaluations) {
          out[specialization]!.addAll(evaluation.skills);
        }
      }
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final skills = _getAllStudentSkills(context);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SkillTile(
              title: 'Compétences acquises',
              skills: _getAcquiredSkills(skills)),
          _SkillTile(
              title: 'Compétences à poursuivre',
              skills: _getToPursuitSkills(skills)),
        ],
      ),
    );
  }
}

class _SkillTile extends StatelessWidget {
  const _SkillTile({required this.title, required this.skills});

  final String title;
  final Map<Specialization, List<SkillEvaluation>> skills;

  Map<int, Map<Specialization, List<SkillEvaluation>>> _filterByLevel() {
    final Map<int, Map<Specialization, List<SkillEvaluation>>> out = {};

    for (final specialization in skills.keys) {
      for (final skillEvaluation in skills[specialization]!) {
        final skill = specialization.skills.firstWhere(
            (skill) => skill.idWithName == skillEvaluation.skillName);

        final level = int.parse(skill.complexity);
        if (!out.containsKey(level)) out[level] = {};

        if (!out[level]!.containsKey(specialization)) {
          out[level]![specialization] = [];
        }
        out[level]![specialization]!.add(skillEvaluation);
      }
    }

    return out;
  }

  @override
  Widget build(BuildContext context) {
    final filteredSkills = _filterByLevel();
    final levels = filteredSkills.keys.toList();
    levels.sort();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SubTitle(title),
        Padding(
          padding: const EdgeInsets.only(left: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: levels
                .map((level) => Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: _LeveledSkillTile(
                        title: 'Compétences de niveau $level',
                        specializations: filteredSkills[level]!,
                      ),
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }
}

class _LeveledSkillTile extends StatelessWidget {
  const _LeveledSkillTile({required this.title, required this.specializations});

  final String title;
  final Map<Specialization, List<SkillEvaluation>> specializations;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 4.0),
          child: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        ...specializations.keys
            .map((specialization) => Padding(
                padding: const EdgeInsets.only(bottom: 12.0, right: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(specialization.idWithName),
                    ...specializations[specialization]!.map(
                      (skillEvaluation) => Padding(
                          padding: const EdgeInsets.only(right: 12.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('\u2022 '),
                              Flexible(child: Text(skillEvaluation.skillName)),
                            ],
                          )),
                    ),
                  ],
                )))
            .toList(),
      ],
    );
  }
}
