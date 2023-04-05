import 'package:flutter/material.dart';

import '/common/models/student.dart';
import '/common/widgets/sub_title.dart';
import '/misc/job_data_file_service.dart';

class SkillsPage extends StatefulWidget {
  const SkillsPage({super.key, required this.student});

  final Student student;

  @override
  State<SkillsPage> createState() => SkillsPageState();
}

class SkillsPageState extends State<SkillsPage> {
  Map<Specialization, List<Skill>> _getCurrentSkills(
      Map<Specialization, List<Skill>> jobs) {
    return jobs;
  }

  Map<Specialization, List<Skill>> _getFutureSkills(
      Map<Specialization, List<Skill>> jobs) {
    return jobs;
  }

  Map<Specialization, List<Skill>> _getAllStudentSkills(BuildContext context) {
    // TODO, parse for a specific student after the evaluation is done
    Map<Specialization, List<Skill>> out = {};
    for (final sector in ActivitySectorsService.sectors) {
      for (final specialization in sector.specializations) {
        for (final skill in specialization.skills) {
          if (!out.containsKey(specialization)) out[specialization] = [];
          out[specialization]!.add(skill);
        }
      }
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final jobs = _getAllStudentSkills(context);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SkillTile(
              title: 'Compétences acquises', jobs: _getCurrentSkills(jobs)),
          _SkillTile(
              title: 'Compétences à poursuivre', jobs: _getFutureSkills(jobs)),
        ],
      ),
    );
  }
}

class _SkillTile extends StatelessWidget {
  const _SkillTile({required this.title, required this.jobs});

  final String title;
  final Map<Specialization, List<Skill>> jobs;

  Map<int, Map<Specialization, List<Skill>>> _filterByLevel() {
    final Map<int, Map<Specialization, List<Skill>>> out = {};
    for (final specialization in jobs.keys) {
      for (final skill in jobs[specialization]!) {
        final level = int.parse(skill.complexity);
        if (!out.containsKey(level)) out[level] = {};
        if (!out[level]!.containsKey(specialization)) {
          out[level]![specialization] = [];
        }
        out[level]![specialization]!.add(skill);
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
                        jobs: filteredSkills[level]!,
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
  const _LeveledSkillTile({required this.title, required this.jobs});

  final String title;
  final Map<Specialization, List<Skill>> jobs;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        ...jobs.keys
            .map((specialization) => Padding(
                padding:
                    const EdgeInsets.only(left: 12.0, bottom: 8.0, right: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(specialization.idWithName),
                    ...jobs[specialization]!.map(
                      (skill) => Padding(
                          padding:
                              const EdgeInsets.only(left: 12.0, right: 12.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('\u2022 '),
                              Flexible(child: Text(skill.name)),
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
