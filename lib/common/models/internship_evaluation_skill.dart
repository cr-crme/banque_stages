import 'package:enhanced_containers/enhanced_containers.dart';

enum SkillAppreciation {
  acquired,
  toPursuit,
  failed,
  notEvaluated,
}

extension SkillAppreciationNamed on SkillAppreciation {
  String get name {
    switch (this) {
      case SkillAppreciation.acquired:
        return 'Réussie';
      case SkillAppreciation.toPursuit:
        return 'À poursuivre';
      case SkillAppreciation.failed:
        return 'Non réussie';
      case SkillAppreciation.notEvaluated:
        return 'Non évaluée';
    }
  }
}

class SkillEvaluation extends ItemSerializable {
  final String specializationId;
  final String skillName;
  final List<String> tasks;
  final SkillAppreciation appreciation;
  final String comment;

  SkillEvaluation({
    required this.specializationId,
    required this.skillName,
    required this.tasks,
    required this.appreciation,
    required this.comment,
  });
  SkillEvaluation.fromSerialized(map)
      : specializationId = map['jobId'],
        skillName = map['skill'],
        tasks = map['tasks'] == null
            ? []
            : (map['tasks'] as List).map((e) => e as String).toList(),
        appreciation = SkillAppreciation.values[map['appreciation']],
        comment = map['comment'],
        super.fromSerialized(map);

  @override
  Map<String, dynamic> serializedMap() {
    return {
      'id': id,
      'jobId': specializationId,
      'skill': skillName,
      'tasks': tasks,
      'appreciation': appreciation.index,
      'comment': comment,
    };
  }

  SkillEvaluation deepCopy() {
    return SkillEvaluation(
      specializationId: specializationId,
      skillName: skillName,
      tasks: tasks.map((e) => e).toList(),
      appreciation: appreciation,
      comment: comment,
    );
  }
}

class InternshipEvaluationSkill extends ItemSerializable {
  DateTime date;
  List<String> presentAtEvaluation;
  List<SkillEvaluation> skills;
  String comments;
  String
      formVersion; // The version of the evaluation form (so data can be parsed properly)

  InternshipEvaluationSkill({
    required this.date,
    required this.presentAtEvaluation,
    required this.skills,
    required this.comments,
    required this.formVersion,
  });
  InternshipEvaluationSkill.fromSerialized(map)
      : date = DateTime.fromMillisecondsSinceEpoch(map['date']),
        presentAtEvaluation =
            (map['present'] as List).map((e) => e as String).toList(),
        skills = (map['skills'] as List)
            .map((e) => SkillEvaluation.fromSerialized(e))
            .toList(),
        comments = map['comments'],
        formVersion = map['formVersion'],
        super.fromSerialized(map);

  @override
  Map<String, dynamic> serializedMap() {
    return {
      'id': id,
      'date': date.millisecondsSinceEpoch,
      'present': presentAtEvaluation,
      'skills': skills.map((e) => e.serialize()).toList(),
      'comments': comments,
      'formVersion': formVersion,
    };
  }

  InternshipEvaluationSkill deepCopy() {
    return InternshipEvaluationSkill(
      date: DateTime.fromMillisecondsSinceEpoch(date.millisecondsSinceEpoch),
      presentAtEvaluation: presentAtEvaluation.map((e) => e).toList(),
      skills: skills.map((e) => e.deepCopy()).toList(),
      comments: comments,
      formVersion: formVersion,
    );
  }
}
