part of 'package:common/models/enterprises/job.dart';

class JobSstEvaluation extends ItemSerializable {
  final Map<String, List<String>?> questions;
  DateTime date;

  bool get isFilled => questions.isNotEmpty;

  void update({
    required Map<String, List<String>?> questions,
  }) {
    this.questions.clear();
    this.questions.addAll({...questions});
    this.questions.removeWhere((key, value) => value == null);

    date = DateTime.now();
  }

  JobSstEvaluation({
    super.id,
    required this.questions,
    DateTime? date,
  }) : date = date ?? DateTime.now();

  static JobSstEvaluation get empty => JobSstEvaluation(questions: {});

  JobSstEvaluation.fromSerialized(super.map)
      : questions = {
          for (final entry in (map['questions'] as Map? ?? {}).entries)
            entry.key: (entry.value as List?)?.map((e) => e as String).toList()
        },
        date = DateTime.fromMillisecondsSinceEpoch(map['date'] ?? 0),
        super.fromSerialized();

  @override
  Map<String, dynamic> serializedMap() => {
        'id': id,
        'questions': questions,
        'date': date.millisecondsSinceEpoch,
      };

  @override
  String toString() => 'JobSstEvaluation($questions, $date)';
}
