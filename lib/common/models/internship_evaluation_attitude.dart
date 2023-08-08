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

  List<String> _fromRequirements(int min, int max) {
    List<String> out = [];
    if (inattendance >= min && inattendance <= max) out.add(Inattendance.title);
    if (ponctuality >= min && ponctuality <= max) out.add(Ponctuality.title);
    if (sociability >= min && sociability <= max) out.add(Sociability.title);
    if (politeness >= min && politeness <= max) out.add(Politeness.title);
    if (motivation >= min && motivation <= max) out.add(Motivation.title);
    if (dressCode >= min && dressCode <= max) out.add(DressCode.title);
    if (qualityOfWork >= min && qualityOfWork <= max) {
      out.add(QualityOfWork.title);
    }
    if (productivity >= min && productivity <= max) out.add(Productivity.title);
    if (autonomy >= min && autonomy <= max) out.add(Autonomy.title);
    if (cautiousness >= min && cautiousness <= max) out.add(Cautiousness.title);
    return out;
  }

  List<String> get meetsRequirements => _fromRequirements(0, 1);
  List<String> get doesNotMeetRequirements => _fromRequirements(2, 3);

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
  String
      formVersion; // The version of the evaluation form (so data can be parsed properly)

  InternshipEvaluationAttitude({
    required this.date,
    required this.presentAtEvaluation,
    required this.attitude,
    required this.comments,
    required this.formVersion,
  });
  InternshipEvaluationAttitude.fromSerialized(map)
      : date = DateTime.fromMillisecondsSinceEpoch(map['date']),
        presentAtEvaluation =
            (map['present'] as List).map((e) => e as String).toList(),
        attitude = AttitudeEvaluation.fromSerialized(map['attitude']),
        comments = map['comments'],
        formVersion = map['formVersion'],
        super.fromSerialized(map);

  @override
  Map<String, dynamic> serializedMap() {
    return {
      'id': id,
      'date': date.millisecondsSinceEpoch,
      'present': presentAtEvaluation,
      'attitude': attitude.serialize(),
      'comments': comments,
      'formVersion': formVersion,
    };
  }

  InternshipEvaluationAttitude deepCopy() {
    return InternshipEvaluationAttitude(
      date: DateTime.fromMillisecondsSinceEpoch(date.millisecondsSinceEpoch),
      presentAtEvaluation: [...presentAtEvaluation],
      attitude: attitude.deepCopy(),
      comments: comments,
      formVersion: formVersion,
    );
  }
}

abstract class AttitudeCategoryEnum {
  String get name;
  int get index;
}

class Inattendance implements AttitudeCategoryEnum {
  static String get title => 'Assiduité';

  @override
  final int index;

  @override
  String get name {
    switch (index) {
      case 0:
        return 'Aucune absence';
      case 1:
        return 'S\'absente rarement et avise';
      case 2:
        return 'Quelques absences injustifiées';
      case 3:
        return 'Absences fréquentes et injustifiées';
      default:
        throw 'Wrong choice of $title';
    }
  }

  const Inattendance._(this.index);
  static Inattendance get never => const Inattendance._(0);
  static Inattendance get rarely => const Inattendance._(1);
  static Inattendance get sometime => const Inattendance._(2);
  static Inattendance get frequently => const Inattendance._(3);

  static List<Inattendance> get values => [
        Inattendance.never,
        Inattendance.rarely,
        Inattendance.sometime,
        Inattendance.frequently,
      ];
}

class Ponctuality implements AttitudeCategoryEnum {
  static String get title => 'Ponctualité';

  @override
  final int index;

  @override
  String get name {
    switch (index) {
      case 0:
        return 'Toujours à l\'heure';
      case 1:
        return 'Quelques retards justifiés';
      case 2:
        return 'Quelques retards injustifiés';
      case 3:
        return 'Retards fréquents et injustifiés';
      default:
        throw 'Wrong choice of $title';
    }
  }

  const Ponctuality._(this.index);
  static Ponctuality get highly => const Ponctuality._(0);
  static Ponctuality get mostly => const Ponctuality._(1);
  static Ponctuality get sometimeLate => const Ponctuality._(2);
  static Ponctuality get frequentlyLate => const Ponctuality._(3);

  static List<Ponctuality> get values => [
        Ponctuality.highly,
        Ponctuality.mostly,
        Ponctuality.sometimeLate,
        Ponctuality.frequentlyLate,
      ];
}

class Sociability implements AttitudeCategoryEnum {
  static String get title => 'Sociabilité';

  @override
  final int index;

  @override
  String get name {
    switch (index) {
      case 0:
        return 'Très sociable';
      case 1:
        return 'Sociable';
      case 2:
        return 'Établit très peu de contacts';
      case 3:
        return 'Pas d\'intégration à l\'équipe de travail';
      default:
        throw 'Wrong choice of $title';
    }
  }

  const Sociability._(this.index);
  static Sociability get veryHigh => const Sociability._(0);
  static Sociability get high => const Sociability._(1);
  static Sociability get low => const Sociability._(2);
  static Sociability get veryLow => const Sociability._(3);

  static List<Sociability> get values => [
        Sociability.veryHigh,
        Sociability.high,
        Sociability.low,
        Sociability.veryLow,
      ];
}

class Politeness implements AttitudeCategoryEnum {
  static String get title => 'Politesse et langage';

  @override
  final int index;

  @override
  String get name {
    switch (index) {
      case 0:
        return 'Langage exemplaire en tout temps';
      case 1:
        return 'Langage convenable en tout temps';
      case 2:
        return 'Langage convenable la plupart du temps';
      case 3:
        return 'Langage inapproprié';
      default:
        throw 'Wrong choice of $title';
    }
  }

  const Politeness._(this.index);
  static Politeness get exemplary => const Politeness._(0);
  static Politeness get alwaysSuitable => const Politeness._(1);
  static Politeness get mostlySuitable => const Politeness._(2);
  static Politeness get inappropriate => const Politeness._(3);

  static List<Politeness> get values => [
        Politeness.exemplary,
        Politeness.alwaysSuitable,
        Politeness.mostlySuitable,
        Politeness.inappropriate,
      ];
}

class Motivation implements AttitudeCategoryEnum {
  static String get title => 'Motivation';

  @override
  final int index;

  @override
  String get name {
    switch (index) {
      case 0:
        return 'Très grand intérêt pour son travail';
      case 1:
        return 'Intérêt marqué';
      case 2:
        return 'Peu d\'intérêt';
      case 3:
        return 'Aucun intérêt';
      default:
        throw 'Wrong choice of $title';
    }
  }

  const Motivation._(this.index);
  static Motivation get veryHigh => const Motivation._(0);
  static Motivation get high => const Motivation._(1);
  static Motivation get low => const Motivation._(2);
  static Motivation get none => const Motivation._(3);

  static List<Motivation> get values => [
        Motivation.veryHigh,
        Motivation.high,
        Motivation.low,
        Motivation.none,
      ];
}

class DressCode implements AttitudeCategoryEnum {
  static String get title => 'Tenue vestimentaire';

  @override
  final int index;

  @override
  String get name {
    switch (index) {
      case 0:
        return 'Très soignée, très propre';
      case 1:
        return 'Soignée et propre';
      case 2:
        return 'Négligée';
      case 3:
        return 'Très négligée, malpropre';
      default:
        throw 'Wrong choice of $title';
    }
  }

  const DressCode._(this.index);
  static DressCode get highlyAppropriate => const DressCode._(0);
  static DressCode get appropriate => const DressCode._(1);
  static DressCode get poorlyAppropriate => const DressCode._(2);
  static DressCode get notAppropriate => const DressCode._(3);

  static List<DressCode> get values => [
        DressCode.highlyAppropriate,
        DressCode.appropriate,
        DressCode.poorlyAppropriate,
        DressCode.notAppropriate,
      ];
}

class QualityOfWork implements AttitudeCategoryEnum {
  static String get title => 'Qualité du travail';

  @override
  final int index;

  @override
  String get name {
    switch (index) {
      case 0:
        return 'S\'applique et travail avec précision';
      case 1:
        return 'Commet quelques erreurs, mais persévère';
      case 2:
        return 'Manque d\'application et/ou exige une supervision';
      case 3:
        return 'Comment souvent des erreurs et néglige les méthodes de travail';
      default:
        throw 'Wrong choice of $title';
    }
  }

  const QualityOfWork._(this.index);
  static QualityOfWork get veryHigh => const QualityOfWork._(0);
  static QualityOfWork get high => const QualityOfWork._(1);
  static QualityOfWork get low => const QualityOfWork._(2);
  static QualityOfWork get negligent => const QualityOfWork._(3);

  static List<QualityOfWork> get values => [
        QualityOfWork.veryHigh,
        QualityOfWork.high,
        QualityOfWork.low,
        QualityOfWork.negligent,
      ];
}

class Productivity implements AttitudeCategoryEnum {
  static String get title => 'Rendement et constance';

  @override
  final int index;

  @override
  String get name {
    switch (index) {
      case 0:
        return 'Rendement et rythme de travail excellents';
      case 1:
        return 'Rendement et rythme de travail bons et constants';
      case 2:
        return 'Difficulté à maintenir le rythme de travail';
      case 3:
        return 'Rendement insuffisant';
      default:
        throw 'Wrong choice of $title';
    }
  }

  const Productivity._(this.index);
  static Productivity get veryHigh => const Productivity._(0);
  static Productivity get high => const Productivity._(1);
  static Productivity get low => const Productivity._(2);
  static Productivity get insufficient => const Productivity._(3);

  static List<Productivity> get values => [
        Productivity.veryHigh,
        Productivity.high,
        Productivity.low,
        Productivity.insufficient,
      ];
}

class Autonomy implements AttitudeCategoryEnum {
  static String get title => 'Autonomie et sens de l\'initiative';

  @override
  final int index;

  @override
  String get name {
    switch (index) {
      case 0:
        return 'Prend très souvent de bonnes initiatives';
      case 1:
        return 'Prend souvent de bonnes initiatives';
      case 2:
        return 'Peu d\'initiative';
      case 3:
        return 'Aucune initiative';
      default:
        throw 'Wrong choice of $title';
    }
  }

  const Autonomy._(this.index);
  static Autonomy get veryHigh => const Autonomy._(0);
  static Autonomy get high => const Autonomy._(1);
  static Autonomy get low => const Autonomy._(2);
  static Autonomy get none => const Autonomy._(3);

  static List<Autonomy> get values => [
        Autonomy.veryHigh,
        Autonomy.high,
        Autonomy.low,
        Autonomy.none,
      ];
}

class Cautiousness implements AttitudeCategoryEnum {
  static String get title =>
      'Respect des règles de santé et de sécurité du travail (SST)';

  @override
  final int index;

  @override
  String get name {
    switch (index) {
      case 0:
        return 'Toujours';
      case 1:
        return 'Souvent';
      case 2:
        return 'Parfois';
      case 3:
        return 'Rarement';
      default:
        throw 'Wrong choice of $title';
    }
  }

  const Cautiousness._(this.index);
  static Cautiousness get always => const Cautiousness._(0);
  static Cautiousness get mostly => const Cautiousness._(1);
  static Cautiousness get sometime => const Cautiousness._(2);
  static Cautiousness get rarely => const Cautiousness._(3);

  static List<Cautiousness> get values => [
        Cautiousness.always,
        Cautiousness.mostly,
        Cautiousness.sometime,
        Cautiousness.rarely,
      ];
}

class GeneralAppreciation implements AttitudeCategoryEnum {
  static String get title => 'Appréciation générale du ou de la stagiaire';

  @override
  final int index;

  @override
  String get name {
    switch (index) {
      case 0:
        return 'Dépasse les attentes';
      case 1:
        return 'Répond aux attentes';
      case 2:
        return 'Répond minimalement aux attentes';
      case 3:
        return 'Ne répond pas aux attentes';
      default:
        throw 'Wrong choice of $title';
    }
  }

  const GeneralAppreciation._(this.index);
  static GeneralAppreciation get veryHigh => const GeneralAppreciation._(0);
  static GeneralAppreciation get good => const GeneralAppreciation._(1);
  static GeneralAppreciation get passable => const GeneralAppreciation._(2);
  static GeneralAppreciation get failed => const GeneralAppreciation._(3);

  static List<GeneralAppreciation> get values => [
        GeneralAppreciation.veryHigh,
        GeneralAppreciation.good,
        GeneralAppreciation.passable,
        GeneralAppreciation.failed,
      ];
}
