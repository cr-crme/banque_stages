import 'package:common/models/internships/internship.dart';
import 'package:common/models/internships/internship_evaluation_attitude.dart';
import 'package:common/models/internships/internship_evaluation_skill.dart';
import 'package:flutter_test/flutter_test.dart';

import '../utils.dart';

void main() {
  group('InternshipEvaluation', () {
    group('Attitude', () {
      test('"Inattendance" shows the right things', () {
        expect(Inattendance.title, 'Assiduité');
        expect(Inattendance.never.name, 'Aucune absence');
        expect(Inattendance.rarely.name, 'S\'absente rarement et avise');
        expect(Inattendance.sometime.name, 'Quelques absences injustifiées');
        expect(Inattendance.frequently.name,
            'Absences fréquentes et injustifiées');
        expect(Inattendance.values.length, 4);

        expect(Inattendance.never.index, 0);
        expect(Inattendance.rarely.index, 1);
        expect(Inattendance.sometime.index, 2);
        expect(Inattendance.frequently.index, 3);
      });

      test('"Ponctuality" shows the right things', () {
        expect(Ponctuality.title, 'Ponctualité');
        expect(Ponctuality.highly.name, 'Toujours à l\'heure');
        expect(Ponctuality.mostly.name, 'Quelques retards justifiés');
        expect(Ponctuality.sometimeLate.name, 'Quelques retards injustifiés');
        expect(Ponctuality.frequentlyLate.name,
            'Retards fréquents et injustifiés');
        expect(Ponctuality.values.length, 4);

        expect(Ponctuality.highly.index, 0);
        expect(Ponctuality.mostly.index, 1);
        expect(Ponctuality.sometimeLate.index, 2);
        expect(Ponctuality.frequentlyLate.index, 3);
      });

      test('"Sociability" shows the right things', () {
        expect(Sociability.title, 'Sociabilité');
        expect(Sociability.veryHigh.name, 'Très sociable');
        expect(Sociability.high.name, 'Sociable');
        expect(Sociability.low.name, 'Établit très peu de contacts');
        expect(Sociability.veryLow.name,
            'Pas d\'intégration à l\'équipe de travail');
        expect(Sociability.values.length, 4);

        expect(Sociability.veryHigh.index, 0);
        expect(Sociability.high.index, 1);
        expect(Sociability.low.index, 2);
        expect(Sociability.veryLow.index, 3);
      });

      test('"Politeness" shows the right things', () {
        expect(Politeness.title, 'Politesse et langage');
        expect(Politeness.exemplary.name, 'Langage exemplaire en tout temps');
        expect(
            Politeness.alwaysSuitable.name, 'Langage convenable en tout temps');
        expect(Politeness.mostlySuitable.name,
            'Langage convenable la plupart du temps');
        expect(Politeness.inappropriate.name, 'Langage inapproprié');
        expect(Politeness.values.length, 4);

        expect(Politeness.exemplary.index, 0);
        expect(Politeness.alwaysSuitable.index, 1);
        expect(Politeness.mostlySuitable.index, 2);
        expect(Politeness.inappropriate.index, 3);
      });

      test('"Motivation" shows the right things', () {
        expect(Motivation.title, 'Motivation');
        expect(Motivation.veryHigh.name, 'Très grand intérêt pour son travail');
        expect(Motivation.high.name, 'Intérêt marqué');
        expect(Motivation.low.name, 'Peu d\'intérêt');
        expect(Motivation.none.name, 'Aucun intérêt');
        expect(Motivation.values.length, 4);

        expect(Motivation.veryHigh.index, 0);
        expect(Motivation.high.index, 1);
        expect(Motivation.low.index, 2);
        expect(Motivation.none.index, 3);
      });

      test('"DressCode" shows the right things', () {
        expect(DressCode.title, 'Tenue vestimentaire');
        expect(DressCode.highlyAppropriate.name, 'Très soignée, très propre');
        expect(DressCode.appropriate.name, 'Soignée et propre');
        expect(DressCode.poorlyAppropriate.name, 'Négligée');
        expect(DressCode.notAppropriate.name, 'Très négligée, malpropre');
        expect(DressCode.values.length, 4);

        expect(DressCode.highlyAppropriate.index, 0);
        expect(DressCode.appropriate.index, 1);
        expect(DressCode.poorlyAppropriate.index, 2);
        expect(DressCode.notAppropriate.index, 3);
      });

      test('"QualityOfWork" shows the right things', () {
        expect(QualityOfWork.title, 'Qualité du travail');
        expect(QualityOfWork.veryHigh.name,
            'S\'applique et travail avec précision');
        expect(
            QualityOfWork.high.name, 'Commet quelques erreurs, mais persévère');
        expect(QualityOfWork.low.name,
            'Manque d\'application et/ou exige une supervision');
        expect(QualityOfWork.negligent.name,
            'Comment souvent des erreurs et néglige les méthodes de travail');
        expect(QualityOfWork.values.length, 4);

        expect(QualityOfWork.veryHigh.index, 0);
        expect(QualityOfWork.high.index, 1);
        expect(QualityOfWork.low.index, 2);
        expect(QualityOfWork.negligent.index, 3);
      });

      test('"Productivity" shows the right things', () {
        expect(Productivity.title, 'Rendement et constance');
        expect(Productivity.veryHigh.name,
            'Rendement et rythme de travail excellents');
        expect(Productivity.high.name,
            'Rendement et rythme de travail bons et constants');
        expect(Productivity.low.name,
            'Difficulté à maintenir le rythme de travail');
        expect(Productivity.insufficient.name, 'Rendement insuffisant');
        expect(Productivity.values.length, 4);

        expect(Productivity.veryHigh.index, 0);
        expect(Productivity.high.index, 1);
        expect(Productivity.low.index, 2);
        expect(Productivity.insufficient.index, 3);
      });

      test('"Autonomy" shows the right things', () {
        expect(Autonomy.title, 'Autonomie et sens de l\'initiative');
        expect(
            Autonomy.veryHigh.name, 'Prend très souvent de bonnes initiatives');
        expect(Autonomy.high.name, 'Prend souvent de bonnes initiatives');
        expect(Autonomy.low.name, 'Peu d\'initiative');
        expect(Autonomy.none.name, 'Aucune initiative');
        expect(Autonomy.values.length, 4);

        expect(Autonomy.veryHigh.index, 0);
        expect(Autonomy.high.index, 1);
        expect(Autonomy.low.index, 2);
        expect(Autonomy.none.index, 3);
      });

      test('"Cautiousness" shows the right things', () {
        expect(Cautiousness.title,
            'Respect des règles de santé et de sécurité du travail (SST)');
        expect(Cautiousness.always.name, 'Toujours');
        expect(Cautiousness.mostly.name, 'Souvent');
        expect(Cautiousness.sometime.name, 'Parfois');
        expect(Cautiousness.rarely.name, 'Rarement');
        expect(Cautiousness.values.length, 4);

        expect(Cautiousness.always.index, 0);
        expect(Cautiousness.mostly.index, 1);
        expect(Cautiousness.sometime.index, 2);
        expect(Cautiousness.rarely.index, 3);
      });

      test('"GeneralAppreciation" shows the right things', () {
        expect(GeneralAppreciation.title,
            'Appréciation générale du ou de la stagiaire');
        expect(GeneralAppreciation.veryHigh.name, 'Dépasse les attentes');
        expect(GeneralAppreciation.good.name, 'Répond aux attentes');
        expect(GeneralAppreciation.passable.name,
            'Répond minimalement aux attentes');
        expect(GeneralAppreciation.failed.name, 'Ne répond pas aux attentes');
        expect(GeneralAppreciation.values.length, 4);

        expect(GeneralAppreciation.veryHigh.index, 0);
        expect(GeneralAppreciation.good.index, 1);
        expect(GeneralAppreciation.passable.index, 2);
        expect(GeneralAppreciation.failed.index, 3);
      });

      test('"meetsRequirements" behaves properly', () {
        final attitude = dummyAttitudeEvaluation();

        expect(attitude.meetsRequirements.length, 4);
        expect(attitude.doesNotMeetRequirements.length, 6);
      });

      test('"Attitude" serialization and deserialization works', () {
        final attitude = dummyAttitudeEvaluation();
        final serialized = attitude.serialize();
        final deserialized = AttitudeEvaluation.fromSerialized(serialized);

        expect(serialized, {
          'id': 'attitudeEvaluationId',
          'inattendance': 1,
          'ponctuality': 2,
          'sociability': 3,
          'politeness': 1,
          'motivation': 2,
          'dressCode': 3,
          'qualityOfWork': 1,
          'productivity': 2,
          'autonomy': 3,
          'cautiousness': 1,
          'generalAppreciation': 2,
        });

        expect(deserialized.id, 'attitudeEvaluationId');
        expect(deserialized.inattendance, 1);
        expect(deserialized.ponctuality, 2);
        expect(deserialized.sociability, 3);
        expect(deserialized.politeness, 1);
        expect(deserialized.motivation, 2);
        expect(deserialized.dressCode, 3);
        expect(deserialized.qualityOfWork, 1);
        expect(deserialized.productivity, 2);
        expect(deserialized.autonomy, 3);
        expect(deserialized.cautiousness, 1);
        expect(deserialized.generalAppreciation, 2);

        // Test for empty deserialize to make sure it doesn't crash
        final emptyDeserialized =
            AttitudeEvaluation.fromSerialized({'id': 'emptyId'});
        expect(emptyDeserialized.id, 'emptyId');
        expect(emptyDeserialized.inattendance, 0);
        expect(emptyDeserialized.ponctuality, 0);
        expect(emptyDeserialized.sociability, 0);
        expect(emptyDeserialized.politeness, 0);
        expect(emptyDeserialized.motivation, 0);
        expect(emptyDeserialized.dressCode, 0);
        expect(emptyDeserialized.qualityOfWork, 0);
        expect(emptyDeserialized.productivity, 0);
        expect(emptyDeserialized.autonomy, 0);
        expect(emptyDeserialized.cautiousness, 0);
        expect(emptyDeserialized.generalAppreciation, 0);
      });

      test(
          '"InternshipEvaluationAttitude" serialization and deserialization works',
          () {
        final attitude = dummyInternshipEvaluationAttitude();
        final serialized = attitude.serialize();
        final deserialized =
            InternshipEvaluationAttitude.fromSerialized(serialized);

        expect(serialized, {
          'id': 'internshipEvaluationAttitudeId',
          'date': attitude.date.millisecondsSinceEpoch,
          'present': attitude.presentAtEvaluation,
          'attitude': attitude.attitude.serialize(),
          'comments': attitude.comments,
          'formVersion': attitude.formVersion,
        });

        expect(deserialized.id, 'internshipEvaluationAttitudeId');
        expect(deserialized.date.toString(), attitude.date.toString());
        expect(deserialized.presentAtEvaluation, attitude.presentAtEvaluation);
        expect(deserialized.attitude.id, attitude.attitude.id);
        expect(deserialized.comments, attitude.comments);
        expect(deserialized.formVersion, attitude.formVersion);

        // Test for empty deserialize to make sure it doesn't crash
        final emptyEvaluation =
            InternshipEvaluationAttitude.fromSerialized({'id': 'emptyId'});
        expect(emptyEvaluation.id, 'emptyId');
        expect(emptyEvaluation.date, DateTime(0));
        expect(emptyEvaluation.presentAtEvaluation, []);
        expect(emptyEvaluation.attitude.inattendance, 0);
        expect(emptyEvaluation.attitude.ponctuality, 0);
        expect(emptyEvaluation.attitude.sociability, 0);
        expect(emptyEvaluation.attitude.politeness, 0);
        expect(emptyEvaluation.attitude.motivation, 0);
        expect(emptyEvaluation.attitude.dressCode, 0);
        expect(emptyEvaluation.attitude.qualityOfWork, 0);
        expect(emptyEvaluation.attitude.productivity, 0);
        expect(emptyEvaluation.attitude.autonomy, 0);
        expect(emptyEvaluation.attitude.cautiousness, 0);
        expect(emptyEvaluation.attitude.generalAppreciation, 0);
        expect(emptyEvaluation.comments, '');
        expect(emptyEvaluation.formVersion, '1.0.0');
      });
    });

    group('Skill', () {
      test('"SkillAppreciation" is shown properly', () {
        expect(SkillAppreciation.acquired.name, 'Réussie');
        expect(SkillAppreciation.toPursuit.name, 'À poursuivre');
        expect(SkillAppreciation.failed.name, 'Non réussie');
        expect(SkillAppreciation.notApplicable.name, 'Non applicable');
        expect(SkillAppreciation.notSelected.name, '');
        expect(SkillAppreciation.values.length, 5);
      });

      test('"skillGranularity" is shown properly', () {
        expect(SkillEvaluationGranularity.global.toString(),
            'Évaluation globale de la compétence');
        expect(SkillEvaluationGranularity.byTask.toString(),
            'Évaluation tâche par tâche');
        expect(SkillEvaluationGranularity.values.length, 2);
      });

      test('"SkillEvaluation" serialization and deserialization works', () {
        final skill = dummySkillEvaluation();
        final serialized = skill.serialize();
        final deserialized = SkillEvaluation.fromSerialized(serialized);

        expect(serialized, {
          'id': 'skillEvaluationId',
          'jobId': 'specializationId',
          'skill': 'skillName',
          'tasks': skill.tasks.map((e) => e.serialize()).toList(),
          'appreciation': skill.appreciation.index,
          'comments': skill.comments,
        });

        expect(deserialized.id, 'skillEvaluationId');
        expect(deserialized.specializationId, 'specializationId');
        expect(deserialized.skillName, 'skillName');
        expect(deserialized.tasks.length, skill.tasks.length);
        expect(deserialized.appreciation, skill.appreciation);
        expect(deserialized.comments, skill.comments);

        // Test for empty deserialize to make sure it doesn't crash
        final emptyDeserialized =
            SkillEvaluation.fromSerialized({'id': 'emptyId'});
        expect(emptyDeserialized.id, 'emptyId');
        expect(emptyDeserialized.specializationId, '');
        expect(emptyDeserialized.skillName, '');
        expect(emptyDeserialized.tasks.length, 0);
        expect(emptyDeserialized.appreciation, SkillAppreciation.notSelected);
        expect(emptyDeserialized.comments, '');
      });

      test(
          '"InternshipEvaluationSkill" serialization and deserialization works',
          () {
        final skill = dummyInternshipEvaluationSkill();
        final serialized = skill.serialize();
        final deserialized =
            InternshipEvaluationSkill.fromSerialized(serialized);

        expect(serialized, {
          'id': 'internshipEvaluationSkillId',
          'date': skill.date.millisecondsSinceEpoch,
          'skillGranularity': skill.skillGranularity.index,
          'present': skill.presentAtEvaluation,
          'skills': skill.skills.map((e) => e.serialize()).toList(),
          'comments': skill.comments,
          'formVersion': skill.formVersion,
        });

        expect(deserialized.id, 'internshipEvaluationSkillId');
        expect(deserialized.date.toString(), skill.date.toString());
        expect(deserialized.skillGranularity, skill.skillGranularity);
        expect(deserialized.presentAtEvaluation, skill.presentAtEvaluation);
        expect(deserialized.skills.length, skill.skills.length);
        expect(deserialized.comments, skill.comments);
        expect(deserialized.formVersion, skill.formVersion);

        // Test for empty deserialize to make sure it doesn't crash
        final emptyEvaluation =
            InternshipEvaluationSkill.fromSerialized({'id': 'emptyId'});
        expect(emptyEvaluation.id, 'emptyId');
        expect(emptyEvaluation.date, DateTime(0));
        expect(emptyEvaluation.skillGranularity,
            SkillEvaluationGranularity.global);
        expect(emptyEvaluation.presentAtEvaluation, []);
        expect(emptyEvaluation.skills.length, 0);
        expect(emptyEvaluation.comments, '');
        expect(emptyEvaluation.formVersion, '1.0.0');
      });
    });
  });

  group('PostInternshipEnterpriseEvaluation', () {
    test('"hasDisorder" behaves properly', () {
      final evaluation =
          dummyPostInternshipEnterpriseEvaluation(hasDisorder: false);
      expect(evaluation.hasDisorder, isFalse);
      expect(
          dummyPostInternshipEnterpriseEvaluation(hasDisorder: true)
              .hasDisorder,
          isTrue);
    });

    test('serialization and deserialization works', () {
      final evaluation = dummyPostInternshipEnterpriseEvaluation();
      final serialized = evaluation.serialize();
      final deserialized =
          PostInternshipEnterpriseEvaluation.fromSerialized(serialized);

      expect(serialized, {
        'id': evaluation.id,
        'internshipId': evaluation.internshipId,
        'skillsRequired': evaluation.skillsRequired,
        'taskVariety': evaluation.taskVariety,
        'trainingPlanRespect': evaluation.trainingPlanRespect,
        'autonomyExpected': evaluation.autonomyExpected,
        'efficiencyExpected': evaluation.efficiencyExpected,
        'supervisionStyle': evaluation.supervisionStyle,
        'easeOfCommunication': evaluation.easeOfCommunication,
        'absenceAcceptance': evaluation.absenceAcceptance,
        'supervisionComments': evaluation.supervisionComments,
        'acceptanceTSA': evaluation.acceptanceTsa,
        'acceptanceLanguageDisorder': evaluation.acceptanceLanguageDisorder,
        'acceptanceIntellectualDisability':
            evaluation.acceptanceIntellectualDisability,
        'acceptancePhysicalDisability': evaluation.acceptancePhysicalDisability,
        'acceptanceMentalHealthDisorder':
            evaluation.acceptanceMentalHealthDisorder,
        'acceptanceBehaviorDifficulties':
            evaluation.acceptanceBehaviorDifficulties,
      });

      expect(deserialized.id, evaluation.id);
      expect(deserialized.internshipId, evaluation.internshipId);
      expect(deserialized.skillsRequired, evaluation.skillsRequired);
      expect(deserialized.taskVariety, evaluation.taskVariety);
      expect(deserialized.trainingPlanRespect, evaluation.trainingPlanRespect);
      expect(deserialized.autonomyExpected, evaluation.autonomyExpected);
      expect(deserialized.efficiencyExpected, evaluation.efficiencyExpected);
      expect(deserialized.supervisionStyle, evaluation.supervisionStyle);
      expect(deserialized.easeOfCommunication, evaluation.easeOfCommunication);
      expect(deserialized.absenceAcceptance, evaluation.absenceAcceptance);
      expect(deserialized.supervisionComments, evaluation.supervisionComments);
      expect(deserialized.acceptanceTsa, evaluation.acceptanceTsa);
      expect(deserialized.acceptanceLanguageDisorder,
          evaluation.acceptanceLanguageDisorder);
      expect(deserialized.acceptanceIntellectualDisability,
          evaluation.acceptanceIntellectualDisability);
      expect(deserialized.acceptancePhysicalDisability,
          evaluation.acceptancePhysicalDisability);
      expect(deserialized.acceptanceMentalHealthDisorder,
          evaluation.acceptanceMentalHealthDisorder);
      expect(deserialized.acceptanceBehaviorDifficulties,
          evaluation.acceptanceBehaviorDifficulties);

      // Test for empty deserialize to make sure it doesn't crash
      final emptyDeserialized =
          PostInternshipEnterpriseEvaluation.fromSerialized({'id': 'emptyId'});
      expect(emptyDeserialized.id, 'emptyId');
      expect(emptyDeserialized.internshipId, '');
      expect(emptyDeserialized.skillsRequired, []);
      expect(emptyDeserialized.taskVariety, 0);
      expect(emptyDeserialized.trainingPlanRespect, 0);
      expect(emptyDeserialized.autonomyExpected, 0);
      expect(emptyDeserialized.efficiencyExpected, 0);
      expect(emptyDeserialized.supervisionStyle, 0);
      expect(emptyDeserialized.easeOfCommunication, 0);
      expect(emptyDeserialized.absenceAcceptance, 0);
      expect(emptyDeserialized.supervisionComments, '');
      expect(emptyDeserialized.acceptanceTsa, 0);
      expect(emptyDeserialized.acceptanceLanguageDisorder, 0);
      expect(emptyDeserialized.acceptanceIntellectualDisability, 0);
      expect(emptyDeserialized.acceptancePhysicalDisability, 0);
      expect(emptyDeserialized.acceptanceMentalHealthDisorder, 0);
      expect(emptyDeserialized.acceptanceBehaviorDifficulties, 0);
    });
  });
}
