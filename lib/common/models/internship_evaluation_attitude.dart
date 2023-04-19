import 'package:enhanced_containers/enhanced_containers.dart';

class AttitudeEvaluation extends ItemSerializable {
  int inattendance;
  int ponctuality;
  int sociability;
  int politeness;
  int motivation;
  int dressCode;
  int qualityOfWork;
  int productivity;
  int autonomy;
  int cautiousness;
  int generalAppreciation;

  AttitudeEvaluation({
    required this.inattendance,
    required this.ponctuality,
    required this.sociability,
    required this.politeness,
    required this.motivation,
    required this.dressCode,
    required this.qualityOfWork,
    required this.productivity,
    required this.autonomy,
    required this.cautiousness,
    required this.generalAppreciation,
  });
  AttitudeEvaluation.fromSerialized(map)
      : inattendance = map['inattendance'],
        ponctuality = map['ponctuality'],
        sociability = map['sociability'],
        politeness = map['politeness'],
        motivation = map['motivation'],
        dressCode = map['dressCode'],
        qualityOfWork = map['qualityOfWork'],
        productivity = map['productivity'],
        autonomy = map['autonomy'],
        cautiousness = map['cautiousness'],
        generalAppreciation = map['generalAppreciation'],
        super.fromSerialized(map);

  @override
  Map<String, dynamic> serializedMap() {
    return {
      'id': id,
      'inattendance': inattendance,
      'ponctuality': ponctuality,
      'sociability': sociability,
      'politeness': politeness,
      'motivation': motivation,
      'dressCode': dressCode,
      'qualityOfWork': qualityOfWork,
      'productivity': productivity,
      'autonomy': autonomy,
      'cautiousness': cautiousness,
      'generalAppreciation': generalAppreciation,
    };
  }

  AttitudeEvaluation deepCopy() {
    return AttitudeEvaluation(
      inattendance: inattendance,
      ponctuality: ponctuality,
      sociability: sociability,
      politeness: politeness,
      motivation: motivation,
      dressCode: dressCode,
      qualityOfWork: qualityOfWork,
      productivity: productivity,
      autonomy: autonomy,
      cautiousness: cautiousness,
      generalAppreciation: generalAppreciation,
    );
  }
}

class InternshipEvaluationAttitude extends ItemSerializable {
  DateTime date;
  List<String> presentAtEvaluation;
  AttitudeEvaluation attitude;
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
        attitude = AttitudeEvaluation.fromSerialized(map['attitude']),
        comments = map['comments'],
        super.fromSerialized(map);

  @override
  Map<String, dynamic> serializedMap() {
    return {
      'id': id,
      'date': date.millisecondsSinceEpoch,
      'present': presentAtEvaluation,
      'skills': attitude.serializedMap(),
      'comments': comments,
    };
  }

  InternshipEvaluationAttitude deepCopy() {
    return InternshipEvaluationAttitude(
      date: DateTime.fromMillisecondsSinceEpoch(date.millisecondsSinceEpoch),
      presentAtEvaluation: presentAtEvaluation.map((e) => e).toList(),
      attitude: attitude.deepCopy(),
      comments: comments,
    );
  }
}
