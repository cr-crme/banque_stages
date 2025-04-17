part of 'package:common/models/enterprises/job.dart';

class JobSstEvaluation extends ItemSerializable {
  final Map<String, dynamic> questions;
  DateTime date;

  bool get isFilled => questions.isNotEmpty;

  void update({
    required Map<String, dynamic> questions,
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
      : questions = _stringMapFromSerialized(map['questions']),
        date = DateTime.fromMillisecondsSinceEpoch(map['date'] ?? 0),
        super.fromSerialized();

  @override
  Map<String, dynamic> serializedMap() => {
        'id': id,
        'questions': questions,
        'date': date.millisecondsSinceEpoch,
      };
}
