import 'package:enhanced_containers/enhanced_containers.dart';

class AttitudeEvaluation extends ItemSerializable {
  final String skillName;

  AttitudeEvaluation({
    required this.skillName,
  });
  AttitudeEvaluation.fromSerialized(map)
      : skillName = map['skill'],
        super.fromSerialized(map);

  @override
  Map<String, dynamic> serializedMap() {
    return {
      'id': id,
      'skill': skillName,
    };
  }

  AttitudeEvaluation deepCopy() {
    return AttitudeEvaluation(
      skillName: skillName,
    );
  }
}

class InternshipEvaluationAttitude extends ItemSerializable {
  DateTime date;
  List<String> presentAtEvaluation;
  List<AttitudeEvaluation> attitude;
  String comments;

  InternshipEvaluationAttitude({
    required this.date,
    required this.presentAtEvaluation,
    required this.attitude,
    required this.comments,
  });
  InternshipEvaluationAttitude.fromSerialized(map)
      : date = DateTime.fromMillisecondsSinceEpoch(map['date']),
        presentAtEvaluation =
            (map['present'] as List).map((e) => e as String).toList(),
        attitude = (map['attitude'] as List)
            .map((e) => AttitudeEvaluation.fromSerialized(e))
            .toList(),
        comments = map['comments'],
        super.fromSerialized(map);

  @override
  Map<String, dynamic> serializedMap() {
    return {
      'id': id,
      'date': date.millisecondsSinceEpoch,
      'present': presentAtEvaluation,
      'skills': attitude.map((e) => e.serializedMap()).toList(),
      'comments': comments,
    };
  }

  InternshipEvaluationAttitude deepCopy() {
    return InternshipEvaluationAttitude(
      date: DateTime.fromMillisecondsSinceEpoch(date.millisecondsSinceEpoch),
      presentAtEvaluation: presentAtEvaluation.map((e) => e).toList(),
      attitude: attitude.map((e) => e.deepCopy()).toList(),
      comments: comments,
    );
  }
}
