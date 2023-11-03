import 'package:crcrme_banque_stages/common/models/internship.dart';
import 'package:crcrme_banque_stages/common/models/person.dart';
import 'package:crcrme_banque_stages/common/models/visiting_priority.dart';
import 'package:crcrme_banque_stages/common/providers/auth_provider.dart';
import 'package:crcrme_banque_stages/common/providers/students_provider.dart';
import 'package:crcrme_banque_stages/common/providers/teachers_provider.dart';
import 'package:crcrme_banque_stages/initialize_program.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../utils.dart';
import '../utils.dart';

void main() {
  group('Intenship', () {
    TestWidgetsFlutterBinding.ensureInitialized();
    initializeProgram(useDatabaseEmulator: true, mockFirebase: true);

    test('"isActive" and "isClosed" behave properly', () {
      final internship = dummyInternship();

      expect(internship.isActive, isTrue);
      expect(internship.isClosed, isFalse);

      final internshipClosed =
          internship.copyWith(endDate: DateTime(2020, 2, 4));

      expect(internshipClosed.isActive, isFalse);
      expect(internshipClosed.isClosed, isTrue);
    });

    test('can add new version', () {
      final internship = dummyInternship();

      expect(internship.nbVersions, 1);
      expect(internship.versionDate.millisecondsSinceEpoch,
          DateTime(1995, 10, 31).millisecondsSinceEpoch);
      expect(internship.versionDateFrom(0), internship.versionDate);
      expect(internship.supervisor.toString(), 'Nobody Forever');
      expect(internship.supervisorFrom(0), internship.supervisor);
      expect(internship.date.start.millisecondsSinceEpoch,
          DateTime(1995, 10, 31).millisecondsSinceEpoch);
      expect(
          internship.date.end.millisecondsSinceEpoch,
          DateTime(1995, 10, 31)
              .add(const Duration(days: 20))
              .millisecondsSinceEpoch);
      expect(internship.dateFrom(0), internship.date);
      expect(internship.weeklySchedules.length, 1);
      expect(internship.weeklySchedules[0].id, 'weeklyScheduleId');
      expect(internship.weeklySchedulesFrom(0), internship.weeklySchedules);

      internship.addVersion(
        versionDate: DateTime(2020, 2, 4),
        weeklySchedules: [dummyWeeklySchedule(id: 'newWeeklyScheduleId')],
        date: DateTimeRange(
            start: DateTime(2000, 1, 1), end: DateTime(2001, 1, 1)),
        supervisor: Person(firstName: 'New', lastName: 'Supervisor'),
      );

      expect(internship.nbVersions, 2);
      expect(internship.versionDate.millisecondsSinceEpoch,
          DateTime(2020, 2, 4).millisecondsSinceEpoch);
      expect(internship.versionDateFrom(1), internship.versionDate);
      expect(internship.supervisor.toString(), 'New Supervisor');
      expect(internship.supervisorFrom(1), internship.supervisor);
      expect(internship.date.start.millisecondsSinceEpoch,
          DateTime(2000, 1, 1).millisecondsSinceEpoch);
      expect(internship.date.end.millisecondsSinceEpoch,
          DateTime(2001, 1, 1).millisecondsSinceEpoch);
      expect(internship.dateFrom(1), internship.date);
      expect(internship.weeklySchedules.length, 1);
      expect(internship.weeklySchedules[0].id, 'newWeeklyScheduleId');
      expect(internship.weeklySchedulesFrom(1), internship.weeklySchedules);
    });

    testWidgets('can add and remove supervisors', (tester) async {
      final context = await tester.contextWithNotifiers(
          withTeachers: true, withStudents: true, withInternships: true);
      final auth = AuthProvider(mockMe: true);
      final teachers = TeachersProvider.of(context, listen: false);
      teachers.initializeAuth(auth);
      teachers.add(dummyTeacher(id: 'extraTeacherId'));
      final students = StudentsProvider.instance(context, listen: false);
      students.initializeAuth(auth);
      students.add(dummyStudent());

      final internship = dummyInternship();

      expect(internship.supervisingTeacherIds.length, 1);
      expect(internship.supervisingTeacherIds, ['teacherId']);

      internship.addSupervisingTeacher(context, teacherId: 'extraTeacherId');

      expect(internship.supervisingTeacherIds.length, 2);
      expect(internship.supervisingTeacherIds, ['teacherId', 'extraTeacherId']);

      internship.removeSupervisingTeacher('extraTeacherId');

      expect(internship.supervisingTeacherIds.length, 1);
      expect(internship.supervisingTeacherIds, ['teacherId']);

      // Prevent from adding a teacher which is not related to a group
      teachers.add(dummyTeacher(id: 'bannedTeacher', groups: ['103']));
      expect(
          () => internship.addSupervisingTeacher(context,
              teacherId: 'bannedTeacher'),
          throwsException);
      expect(internship.supervisingTeacherIds.length, 1);
      expect(internship.supervisingTeacherIds, ['teacherId']);
    });

    test('"copyWith" behaves properly', () {
      final internship = dummyInternship();

      final internshipSame = internship.copyWith();
      expect(internshipSame.id, internship.id);
      expect(internshipSame.studentId, internship.studentId);
      expect(internshipSame.signatoryTeacherId, internship.signatoryTeacherId);
      expect(internshipSame.supervisingTeacherIds,
          internship.supervisingTeacherIds);
      expect(internshipSame.enterpriseId, internship.enterpriseId);
      expect(internshipSame.jobId, internship.jobId);
      expect(internshipSame.nbVersions, internship.nbVersions);
      expect(internshipSame.versionDate.toString(),
          internship.versionDate.toString());
      expect(internshipSame.supervisor.toString(),
          internship.supervisor.toString());
      expect(internshipSame.date.toString(), internship.date.toString());
      expect(internshipSame.weeklySchedules.length,
          internship.weeklySchedules.length);
      expect(internshipSame.expectedLength, internship.expectedLength);
      expect(internshipSame.achievedLength, internship.achievedLength);
      expect(internshipSame.visitingPriority, internship.visitingPriority);
      expect(internshipSame.teacherNotes, internship.teacherNotes);
      expect(internshipSame.endDate, internship.endDate);
      expect(internshipSame.skillEvaluations.length,
          internship.skillEvaluations.length);
      expect(internshipSame.attitudeEvaluations.length,
          internship.attitudeEvaluations.length);
      expect(internshipSame.enterpriseEvaluation!.id,
          internship.enterpriseEvaluation!.id);

      final internshipDifferent = internship.copyWith(
        id: 'newId',
        studentId: 'newStudentId',
        signatoryTeacherId: 'newTeacherId',
        extraSupervisingTeacherIds: ['newExtraTeacherId'],
        enterpriseId: 'newEnterpriseId',
        jobId: 'newJobId',
        extraSpecializationsId: ['newSpecializationId'],
        expectedLength: 135,
        achievedLength: 130,
        visitingPriority: VisitingPriority.high,
        teacherNotes: 'newTeacherNotes',
        endDate: DateTime(2020, 2, 4),
        skillEvaluations: [
          dummyInternshipEvaluationSkill(id: 'newSkillEvaluationId'),
          dummyInternshipEvaluationSkill(id: 'newSkillEvaluationId2'),
        ],
        attitudeEvaluations: [
          dummyInternshipEvaluationAttitude(id: 'newAttitudeEvaluationId'),
          dummyInternshipEvaluationAttitude(id: 'newAttitudeEvaluationId2'),
        ],
        enterpriseEvaluation: dummyPostInternshipEnterpriseEvaluation(
            id: 'newEnterpriseEvaluationId'),
      );

      expect(internshipDifferent.id, 'newId');
      expect(internshipDifferent.studentId, 'newStudentId');
      expect(internshipDifferent.signatoryTeacherId, 'newTeacherId');
      expect(internshipDifferent.supervisingTeacherIds,
          ['newTeacherId', 'newExtraTeacherId']);
      expect(internshipDifferent.enterpriseId, 'newEnterpriseId');
      expect(internshipDifferent.jobId, 'newJobId');
      expect(internshipDifferent.expectedLength, 135);
      expect(internshipDifferent.achievedLength, 130);
      expect(internshipDifferent.visitingPriority, VisitingPriority.high);
      expect(internshipDifferent.teacherNotes, 'newTeacherNotes');
      expect(internshipDifferent.endDate, DateTime(2020, 2, 4));
      expect(internshipDifferent.skillEvaluations.length, 2);
      expect(
          internshipDifferent.skillEvaluations[0].id, 'newSkillEvaluationId');
      expect(
          internshipDifferent.skillEvaluations[1].id, 'newSkillEvaluationId2');
      expect(internshipDifferent.attitudeEvaluations.length, 2);
      expect(internshipDifferent.attitudeEvaluations[0].id,
          'newAttitudeEvaluationId');
      expect(internshipDifferent.attitudeEvaluations[1].id,
          'newAttitudeEvaluationId2');
      expect(internshipDifferent.enterpriseEvaluation!.id,
          'newEnterpriseEvaluationId');

      // use copyWith on elements that should not be copiedWith
      expect(
          () => internship.copyWith(
              date: DateTimeRange(
                  start: DateTime(1999, 12, 31), end: DateTime(2000, 1, 1))),
          throwsArgumentError);
      expect(
          () => internship
              .copyWith(weeklySchedules: [dummyWeeklySchedule(id: 'newId')]),
          throwsArgumentError);
      expect(
          () => internship.copyWith(
              supervisor: Person(firstName: 'Impossible', lastName: 'Person'),
              enterpriseEvaluation:
                  dummyPostInternshipEnterpriseEvaluation(id: 'newId')),
          throwsArgumentError);
    });

    test('"Internship" serialization and deserialization works', () {
      final internship = dummyInternship(hasEndDate: true);
      final serialized = internship.serialize();
      final deserialized = Internship.fromSerialized(serialized);

      final period = DateTimeRange(
          start: DateTime(1995, 10, 31),
          end: DateTime(1995, 10, 31).add(const Duration(days: 20)));
      expect(serialized, {
        'id': 'internshipId',
        'student': 'studentId',
        'signatoryTeacherId': 'teacherId',
        'extraSupervisingTeacherIds': [],
        'enterprise': 'enterpriseId',
        'jobId': 'jobId',
        'extraSpecializationsId': ['8168', '8134'],
        'mutables': [
          {
            'id': serialized['mutables'][0]['id'],
            'versionDate': internship.versionDate.millisecondsSinceEpoch,
            'name': internship.supervisor.serialize(),
            'date': [
              internship.date.start.millisecondsSinceEpoch,
              internship.date.end.millisecondsSinceEpoch
            ],
            'schedule': [dummyWeeklySchedule(period: period).serialize()],
          }
        ],
        'expectedLength': 135,
        'achievedLength': 130,
        'priority': 0,
        'teacherNotes': '',
        'endDate': DateTime(2034, 10, 28).millisecondsSinceEpoch,
        'skillEvaluation': [dummyInternshipEvaluationSkill().serialize()],
        'attitudeEvaluation': [dummyInternshipEvaluationAttitude().serialize()],
        'enterpriseEvaluation':
            dummyPostInternshipEnterpriseEvaluation().serialize(),
      });

      expect(deserialized.id, 'internshipId');
      expect(deserialized.studentId, 'studentId');
      expect(deserialized.signatoryTeacherId, 'teacherId');
      expect(deserialized.supervisingTeacherIds, ['teacherId']);
      expect(deserialized.enterpriseId, 'enterpriseId');
      expect(deserialized.jobId, 'jobId');
      expect(deserialized.nbVersions, 1);
      expect(deserialized.versionDate.toString(),
          internship.versionDate.toString());
      expect(
          deserialized.supervisor.toString(), internship.supervisor.toString());
      expect(deserialized.date.toString(), internship.date.toString());
      expect(deserialized.weeklySchedules.length, 1);
      expect(
          deserialized.weeklySchedules[0].id, internship.weeklySchedules[0].id);
      expect(deserialized.expectedLength, 135);
      expect(deserialized.achievedLength, 130);
      expect(deserialized.visitingPriority, VisitingPriority.low);
      expect(deserialized.teacherNotes, '');
      expect(deserialized.endDate!.millisecondsSinceEpoch,
          internship.endDate!.millisecondsSinceEpoch);
      expect(deserialized.skillEvaluations.length, 1);
      expect(deserialized.skillEvaluations[0].id,
          internship.skillEvaluations[0].id);
      expect(deserialized.attitudeEvaluations.length, 1);
      expect(deserialized.attitudeEvaluations[0].id,
          internship.attitudeEvaluations[0].id);
      expect(deserialized.enterpriseEvaluation!.id,
          internship.enterpriseEvaluation!.id);

      // Test for empty deserialize to make sure it doesn't crash
      final emptyDeserialized = Internship.fromSerialized({'id': 'emptyId'});
      expect(emptyDeserialized.id, 'emptyId');
      expect(emptyDeserialized.studentId, '');
      expect(emptyDeserialized.signatoryTeacherId, '');
      expect(emptyDeserialized.supervisingTeacherIds, ['']);
      expect(emptyDeserialized.enterpriseId, '');
      expect(emptyDeserialized.jobId, '');
      expect(emptyDeserialized.nbVersions, 0);
      expect(emptyDeserialized.expectedLength, -1);
      expect(emptyDeserialized.achievedLength, -1);
      expect(
          emptyDeserialized.visitingPriority, VisitingPriority.notApplicable);
      expect(emptyDeserialized.teacherNotes, '');
      expect(emptyDeserialized.endDate, isNull);
      expect(emptyDeserialized.skillEvaluations.length, 0);
      expect(emptyDeserialized.attitudeEvaluations.length, 0);
      expect(emptyDeserialized.enterpriseEvaluation, isNull);

      expect(() => emptyDeserialized.date, throwsStateError);
      expect(() => emptyDeserialized.weeklySchedules, throwsStateError);
      expect(() => emptyDeserialized.supervisor, throwsStateError);
    });
  });
}
