import 'package:crcrme_banque_stages/common/models/task_appreciation.dart';
import 'package:enhanced_containers/enhanced_containers.dart';

enum SkillAppreciation {
  acquired,
  toPursuit,
  failed,
  notApplicable,
  notSelected;

  String get name {
    switch (this) {
      case SkillAppreciation.acquired:
        return 'Réussie';
      case SkillAppreciation.toPursuit:
        return 'À poursuivre';
      case SkillAppreciation.failed:
        return 'Non réussie';
      case SkillAppreciation.notApplicable:
        return 'Non applicable';
      case SkillAppreciation.notSelected:
        return '';
    }
  }
}

enum SkillEvaluationGranularity {
  global,
  byTask;

  @override
  String toString() {
    switch (this) {
      case SkillEvaluationGranularity.global:
        return 'Évaluation globale de la compétence';
      case SkillEvaluationGranularity.byTask:
        return 'Évaluation tâche par tâche';
    }
  }
}

class SkillEvaluation extends ItemSerializable {
  final String specializationId;
  final String skillName;
  final List<TaskAppreciation> tasks;

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
            : (map['tasks'] as List)
                .map((e) => TaskAppreciation.fromSerialized(e))
                .toList(),
        appreciation = SkillAppreciation.values[map['appreciation']],
        comment = map['comment'],
        super.fromSerialized(map);

  @override
  Map<String, dynamic> serializedMap() {
    return {
      'id': id,
      'jobId': specializationId,
      'skill': skillName,
      'tasks': tasks.map((e) => e.serialize()).toList(),
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
  final SkillEvaluationGranularity skillGranularity;
  List<SkillEvaluation> skills;
  String comments;
  String
      formVersion; // The version of the evaluation form (so data can be parsed properly)

  InternshipEvaluationSkill({
    required this.date,
    required this.presentAtEvaluation,
    required this.skillGranularity,
    required this.skills,
    required this.comments,
    required this.formVersion,
  });
  InternshipEvaluationSkill.fromSerialized(map)
      : date = DateTime.fromMillisecondsSinceEpoch(map['date']),
        presentAtEvaluation =
            (map['present'] as List?)?.map((e) => e as String).toList() ?? [],
        skillGranularity =
            SkillEvaluationGranularity.values[map['skillGranularity']],
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
      'skillGranularity': skillGranularity.index,
      'skills': skills.map((e) => e.serialize()).toList(),
      'comments': comments,
      'formVersion': formVersion,
    };
  }

  InternshipEvaluationSkill deepCopy() {
    return InternshipEvaluationSkill(
      date: DateTime.fromMillisecondsSinceEpoch(date.millisecondsSinceEpoch),
      presentAtEvaluation: presentAtEvaluation.map((e) => e).toList(),
      skillGranularity: skillGranularity,
      skills: skills.map((e) => e.deepCopy()).toList(),
      comments: comments,
      formVersion: formVersion,
    );
  }
}
