import 'package:backend/repositories/mysql_helpers.dart';
import 'package:backend/repositories/repository_abstract.dart';
import 'package:backend/utils/exceptions.dart';
import 'package:common/models/internships/internship.dart';
import 'package:common/models/internships/schedule.dart';
import 'package:common/models/internships/time_utils.dart';
import 'package:common/models/itineraries/visiting_priority.dart';
import 'package:common/utils.dart';
import 'package:mysql1/mysql1.dart';

abstract class InternshipsRepository implements RepositoryAbstract {
  @override
  Future<Map<String, dynamic>> getAll({List<String>? fields}) async {
    final internships = await _getAllInternships();
    return internships
        .map((key, value) => MapEntry(key, value.serializeWithFields(fields)));
  }

  @override
  Future<Map<String, dynamic>> getById(
      {required String id, List<String>? fields}) async {
    final internship = await _getInternshipById(id: id);
    if (internship == null) throw MissingDataException('Internship not found');

    return internship.serializeWithFields(fields);
  }

  @override
  Future<void> putAll({required Map<String, dynamic> data}) async =>
      throw InvalidRequestException('Internships must be created individually');

  @override
  Future<List<String>> putById(
      {required String id, required Map<String, dynamic> data}) async {
    // Update if exists, insert if not
    final previous = await _getInternshipById(id: id);

    final newInternship = previous?.copyWithData(data) ??
        Internship.fromSerialized(<String, dynamic>{'id': id}..addAll(data));

    await _putInternship(internship: newInternship, previous: previous);
    return newInternship.getDifference(previous);
  }

  Future<Map<String, Internship>> _getAllInternships();

  Future<Internship?> _getInternshipById({required String id});

  Future<void> _putInternship(
      {required Internship internship, required Internship? previous});
}

class MySqlInternshipsRepository extends InternshipsRepository {
  // coverage:ignore-start
  final MySqlConnection connection;
  MySqlInternshipsRepository({required this.connection});

  @override
  Future<Map<String, Internship>> _getAllInternships(
      {String? internshipId}) async {
    final internships = await MySqlHelpers.performSelectQuery(
        connection: connection,
        tableName: 'internships',
        id: internshipId,
        subqueries: [
          MySqlSelectSubQuery(
            dataTableName: 'internship_supervising_teachers',
            asName: 'supervising_teachers',
            fieldsToFetch: ['teacher_id', 'is_signatory_teacher'],
            idNameToDataTable: 'internship_id',
          ),
          MySqlSelectSubQuery(
            dataTableName: 'internship_extra_specializations',
            asName: 'extra_specializations',
            fieldsToFetch: ['specialization_id'],
            idNameToDataTable: 'internship_id',
          ),
          MySqlSelectSubQuery(
            dataTableName: 'internship_mutable_data',
            asName: 'mutables',
            fieldsToFetch: [
              'id',
              'creation_date',
              'supervisor_id',
              'starting_date',
              'ending_date',
            ],
            idNameToDataTable: 'internship_id',
          ),
          MySqlSelectSubQuery(
            dataTableName: 'internship_skill_evaluations',
            asName: 'skill_evaluations',
            fieldsToFetch: [
              'id',
              'date',
              'skill_granularity',
              'comments',
              'form_version'
            ],
            idNameToDataTable: 'internship_id',
          ),
          MySqlSelectSubQuery(
            dataTableName: 'internship_attitude_evaluations',
            asName: 'attitude_evaluations',
            fieldsToFetch: ['id', 'date', 'comments', 'form_version'],
            idNameToDataTable: 'internship_id',
          ),
          MySqlSelectSubQuery(
            dataTableName: 'post_internship_enterprise_evaluations',
            asName: 'enterprise_evaluation',
            fieldsToFetch: [
              'id',
              'internship_id',
              'task_variety',
              'training_plan_respect',
              'autonomy_expected',
              'efficiency_expected',
              'supervision_style',
              'ease_of_communication',
              'absence_acceptance',
              'supervision_comments',
              'acceptance_tsa',
              'acceptance_language_disorder',
              'acceptance_intellectual_disability',
              'acceptance_physical_disability',
              'acceptance_mental_health_disorder',
              'acceptance_behavior_difficulties'
            ],
            idNameToDataTable: 'internship_id',
          ),
        ]);

    final map = <String, Internship>{};
    for (final internship in internships) {
      final id = internship['id'].toString();

      internship['priority'] = internship['visiting_priority'];

      internship['signatory_teacher_id'] =
          (internship['supervising_teachers'] as List?)?.firstWhereOrNull(
              (e) => e['is_signatory_teacher'] as int == 1)?['teacher_id'];
      if (internship['signatory_teacher_id'] == null) {
        throw MissingDataException('Internship $id has no signatory teacher');
      }
      internship['extra_supervising_teacher_ids'] =
          (internship['supervising_teachers'] as List?)
                  ?.map((e) => e['teacher_id'].toString())
                  .toList() ??
              [];

      internship['extra_specialization_ids'] =
          (internship['extra_specializations'] as List?)
                  ?.map((e) => e['specialization_id'].toString())
                  .toList() ??
              [];

      for (final mutable in (internship['mutables'] as List? ?? [])) {
        final schedules = await MySqlHelpers.performSelectQuery(
            connection: connection,
            tableName: 'internship_weekly_schedules',
            idName: 'mutable_data_id',
            id: mutable['id'],
            subqueries: [
              MySqlSelectSubQuery(
                dataTableName: 'internship_daily_schedules',
                asName: 'daily_schedules',
                fieldsToFetch: [
                  'day',
                  'starting_hour',
                  'starting_minute',
                  'ending_hour',
                  'ending_minute'
                ],
                idNameToDataTable: 'weekly_schedule_id',
              ),
            ]);

        for (final schedule in schedules) {
          schedule['start'] = schedule['starting_date'];
          schedule['end'] = schedule['ending_date'];
          schedule['days'] = [
            for (final day in (schedule['daily_schedules'] as List? ?? []))
              {
                'id': day['id'],
                'day': day['day'],
                'start': [day['starting_hour'], day['starting_minute']],
                'end': [day['ending_hour'], day['ending_minute']]
              }
          ];
        }
        mutable['schedules'] = schedules;
      }

      final skillEvaluations = [];
      for (final Map<String, dynamic> evaluation
          in (internship['skill_evaluations'] as List? ?? [])) {
        final evaluationSubquery = (await MySqlHelpers.performSelectQuery(
                connection: connection,
                tableName: 'internship_skill_evaluations',
                id: evaluation['id'],
                subqueries: [
              MySqlSelectSubQuery(
                dataTableName: 'internship_skill_evaluation_persons',
                asName: 'present',
                fieldsToFetch: ['person_name'],
                idNameToDataTable: 'evaluation_id',
              ),
              MySqlSelectSubQuery(
                dataTableName: 'internship_skill_evaluation_items',
                asName: 'skills',
                fieldsToFetch: [
                  'id',
                  'job_id',
                  'skill_name',
                  'appreciation',
                  'comments'
                ],
                idNameToDataTable: 'evaluation_id',
              ),
            ]))
            .first;

        evaluation['skills'] = [];
        for (final skill in (evaluationSubquery['skills'] as List? ?? [])) {
          final tasks = await MySqlHelpers.performSelectQuery(
              connection: connection,
              tableName: 'internship_skill_evaluation_item_tasks',
              idName: 'evaluation_item_id',
              id: skill['id']);
          evaluation['skills'].add({
            'id': skill['id'],
            'job_id': skill['job_id'],
            'skill': skill['skill_name'],
            'appreciation': skill['appreciation'],
            'comments': skill['comments'],
            'tasks': [
              for (final task in (tasks as List? ?? []))
                {
                  'id': task['id'],
                  'title': task['title'],
                  'level': task['level']
                }
            ],
          });
        }

        evaluation['present'] = [
          for (final person in (evaluationSubquery['present'] as List? ?? []))
            person['person_name']
        ];
        skillEvaluations.add(evaluation);
      }
      internship['skill_evaluations'] = skillEvaluations;

      final attitudeEvaluations = [];
      for (final Map<String, dynamic> evaluation
          in (internship['attitude_evaluations'] as List? ?? [])) {
        final evaluationSubquery = (await MySqlHelpers.performSelectQuery(
                connection: connection,
                tableName: 'internship_attitude_evaluations',
                id: evaluation['id'],
                subqueries: [
              MySqlSelectSubQuery(
                dataTableName: 'internship_attitude_evaluation_persons',
                asName: 'present',
                fieldsToFetch: ['person_name'],
                idNameToDataTable: 'evaluation_id',
              ),
              MySqlSelectSubQuery(
                dataTableName: 'internship_attitude_evaluation_items',
                asName: 'attitude',
                fieldsToFetch: [
                  'id',
                  'evaluation_id',
                  'inattendance',
                  'ponctuality',
                  'sociability',
                  'politeness',
                  'motivation',
                  'dressCode',
                  'quality_of_work',
                  'productivity',
                  'autonomy',
                  'cautiousness',
                  'general_appreciation',
                ],
                idNameToDataTable: 'evaluation_id',
              ),
            ]))
            .first;

        evaluation['attitude'] = (evaluationSubquery['attitude'] as List).first;
        evaluation['present'] = [
          for (final person in (evaluationSubquery['present'] as List? ?? []))
            person['person_name']
        ];
        attitudeEvaluations.add(evaluation);
      }
      internship['attitude_evaluations'] = attitudeEvaluations;

      internship['enterprise_evaluation'] =
          (internship['enterprise_evaluation'] as List?)?.firstOrNull;
      if (internship['enterprise_evaluation'] != null) {
        final skills = await MySqlHelpers.performSelectQuery(
            connection: connection,
            tableName: 'post_internship_enterprise_evaluation_skills',
            idName: 'post_evaluation_id',
            id: internship['enterprise_evaluation']!['id']);
        internship['enterprise_evaluation']['skills_required'] = [
          for (final skill in (skills as List? ?? [])) skill['skill_name']
        ];
      }

      map[id] = Internship.fromSerialized(internship);
    }
    return map;
  }

  @override
  Future<Internship?> _getInternshipById({required String id}) async =>
      (await _getAllInternships(internshipId: id))[id];

  @override
  Future<void> _putInternship(
          {required Internship internship,
          required Internship? previous}) async =>
      previous == null
          ? await _putNewInternship(internship)
          : await _putExistingInternship(internship, previous);

  Future<void> _putNewInternship(Internship internship) async {
    try {
      final serialized = internship.serialize();

      // Insert the internship
      await MySqlHelpers.performInsertQuery(
          connection: connection,
          tableName: 'entities',
          data: {'shared_id': internship.id});
      await MySqlHelpers.performInsertQuery(
          connection: connection,
          tableName: 'internships',
          data: {
            'id': internship.id,
            'student_id': internship.studentId,
            'enterprise_id': internship.enterpriseId,
            'job_id': internship.jobId,
            'expected_duration': internship.expectedDuration,
            'achieved_duration': internship.achievedDuration,
            'visiting_priority': internship.visitingPriority.index,
            'teacher_notes': internship.teacherNotes,
            'end_date': serialized['end_date'],
          });

      // Insert the signatory teacher
      for (final teacherId in internship.supervisingTeacherIds) {
        await MySqlHelpers.performInsertQuery(
            connection: connection,
            tableName: 'internship_supervising_teachers',
            data: {
              'internship_id': internship.id,
              'teacher_id': teacherId,
              'is_signatory_teacher': teacherId == internship.signatoryTeacherId
            });
      }

      // Insert the extra specializations
      for (final specializationId in internship.extraSpecializationIds) {
        await MySqlHelpers.performInsertQuery(
            connection: connection,
            tableName: 'internship_extra_specializations',
            data: {
              'internship_id': internship.id,
              'specialization_id': specializationId
            });
      }

      // Insert the mutable data
      for (final mutable in serialized['mutables'] as List) {
        await MySqlHelpers.performInsertQuery(
            connection: connection,
            tableName: 'internship_mutable_data',
            data: {
              'id': mutable['id'],
              'internship_id': internship.id,
              'creation_date': mutable['creation_date'],
              'supervisor_id': mutable['supervisor_id'],
              'starting_date': mutable['starting_date'],
              'ending_date': mutable['ending_date'],
            });

        // Insert the weekly schedules
        for (final schedule in mutable['schedules'] as List) {
          await MySqlHelpers.performInsertQuery(
              connection: connection,
              tableName: 'internship_weekly_schedules',
              data: {
                'id': schedule['id'],
                'mutable_data_id': mutable['id'],
                'starting_date': schedule['start'],
                'ending_date': schedule['end'],
              });

          // Insert the daily schedules
          for (final day in schedule['days'] as List) {
            await MySqlHelpers.performInsertQuery(
                connection: connection,
                tableName: 'internship_daily_schedules',
                data: {
                  'id': day['id'],
                  'weekly_schedule_id': schedule['id'],
                  'day': day['day'],
                  'starting_hour': day['start'][0],
                  'starting_minute': day['start'][1],
                  'ending_hour': day['end'][0],
                  'ending_minute': day['end'][1],
                });
          }
        }
      }
      // Insert skill evaluations
      for (final evaluation in serialized['skill_evaluations'] as List) {
        await MySqlHelpers.performInsertQuery(
            connection: connection,
            tableName: 'internship_skill_evaluations',
            data: {
              'id': evaluation['id'],
              'internship_id': internship.id,
              'date': evaluation['date'],
              'skill_granularity': evaluation['skill_granularity'],
              'comments': evaluation['comments'],
              'form_version': evaluation['form_version'],
            });

        // Insert the persons present at the evaluation
        for (final name in evaluation['present'] as List) {
          await MySqlHelpers.performInsertQuery(
              connection: connection,
              tableName: 'internship_skill_evaluation_persons',
              data: {
                'evaluation_id': evaluation['id'],
                'person_name': name,
              });
        }

        // Insert the skills
        for (final skill in evaluation['skills'] as List) {
          await MySqlHelpers.performInsertQuery(
              connection: connection,
              tableName: 'internship_skill_evaluation_items',
              data: {
                'id': skill['id'],
                'evaluation_id': evaluation['id'],
                'job_id': skill['job_id'],
                'skill_name': skill['skill'],
                'appreciation': skill['appreciation'],
                'comments': skill['comments'],
              });

          // Insert the tasks
          for (final task in skill['tasks'] as List) {
            await MySqlHelpers.performInsertQuery(
                connection: connection,
                tableName: 'internship_skill_evaluation_item_tasks',
                data: {
                  'id': task['id'],
                  'evaluation_item_id': skill['id'],
                  'title': task['title'],
                  'level': task['level'],
                });
          }
        }
      }

      // Insert attitude evaluations
      for (final evaluation in serialized['attitude_evaluations'] as List) {
        await MySqlHelpers.performInsertQuery(
            connection: connection,
            tableName: 'internship_attitude_evaluations',
            data: {
              'id': evaluation['id'],
              'internship_id': internship.id,
              'date': evaluation['date'],
              'comments': evaluation['comments'],
              'form_version': evaluation['form_version'],
            });

        // Insert the persons present at the evaluation
        for (final name in evaluation['present'] as List) {
          await MySqlHelpers.performInsertQuery(
              connection: connection,
              tableName: 'internship_attitude_evaluation_persons',
              data: {
                'evaluation_id': evaluation['id'],
                'person_name': name,
              });
        }

        // Insert the attitude
        await MySqlHelpers.performInsertQuery(
            connection: connection,
            tableName: 'internship_attitude_evaluation_items',
            data: {
              'id': evaluation['attitude']['id'],
              'evaluation_id': evaluation['id'],
              'inattendance': evaluation['attitude']['inattendance'],
              'ponctuality': evaluation['attitude']['ponctuality'],
              'sociability': evaluation['attitude']['sociability'],
              'politeness': evaluation['attitude']['politeness'],
              'motivation': evaluation['attitude']['motivation'],
              'dressCode': evaluation['attitude']['dressCode'],
              'quality_of_work': evaluation['attitude']['quality_of_work'],
              'productivity': evaluation['attitude']['productivity'],
              'autonomy': evaluation['attitude']['autonomy'],
              'cautiousness': evaluation['attitude']['cautiousness'],
              'general_appreciation': evaluation['attitude']
                  ['general_appreciation']
            });
      }

      // Insert the post internship enterprise evaluations
      if (serialized['enterprise_evaluation'] != null &&
          serialized['enterprise_evaluation'] != -1) {
        final evaluation = serialized['enterprise_evaluation'];
        await MySqlHelpers.performInsertQuery(
            connection: connection,
            tableName: 'post_internship_enterprise_evaluations',
            data: {
              'id': evaluation['id'],
              'internship_id': internship.id,
              'task_variety': evaluation['task_variety'],
              'training_plan_respect': evaluation['training_plan_respect'],
              'autonomy_expected': evaluation['autonomy_expected'],
              'efficiency_expected': evaluation['efficiency_expected'],
              'supervision_style': evaluation['supervision_style'],
              'ease_of_communication': evaluation['ease_of_communication'],
              'absence_acceptance': evaluation['absence_acceptance'],
              'supervision_comments': evaluation['supervision_comments'],
              'acceptance_tsa': evaluation['acceptance_tsa'],
              'acceptance_language_disorder':
                  evaluation['acceptance_language_disorder'],
              'acceptance_intellectual_disability':
                  evaluation['acceptance_intellectual_disability'],
              'acceptance_physical_disability':
                  evaluation['acceptance_physical_disability'],
              'acceptance_mental_health_disorder':
                  evaluation['acceptance_mental_health_disorder'],
              'acceptance_behavior_difficulties':
                  evaluation['acceptance_behavior_difficulties'],
            });

        for (final skill in evaluation['skills_required'] as List) {
          await MySqlHelpers.performInsertQuery(
              connection: connection,
              tableName: 'post_internship_enterprise_evaluation_skills',
              data: {
                'post_evaluation_id': evaluation['id'],
                'skill_name': skill
              });
        }
      }
    } catch (e) {
      try {
        // Try to delete the inserted data in case of error (everything is ON CASCADE DELETE)
        await _deleteInternship(internship);
      } catch (e) {
        // Do nothing
      }
      rethrow;
    }
  }

  Future<void> _putExistingInternship(
      Internship internship, Internship previous) async {
    // TODO: Implement a better updating of the internships
    await _deleteInternship(previous);
    await _putNewInternship(internship);
  }

  Future<void> _deleteInternship(Internship internship) async {
    await MySqlHelpers.performDeleteQuery(
        connection: connection,
        tableName: 'entities',
        idName: 'shared_id',
        id: internship.id);
  }
}

class InternshipsRepositoryMock extends InternshipsRepository {
  // Simulate a database with a map
  final _dummyDatabase = {
    '0': Internship(
        id: '0',
        studentId: '12345',
        signatoryTeacherId: '67890',
        extraSupervisingTeacherIds: [],
        enterpriseId: '12345',
        jobId: '67890',
        extraSpecializationIds: ['12345'],
        dates: DateTimeRange(
            start: DateTime(1990, 1, 1), end: DateTime(1990, 1, 31)),
        supervisorId: '12345',
        creationDate: DateTime(2000, 1, 1),
        weeklySchedules: [
          WeeklySchedule(
              schedule: [
                DailySchedule(
                    dayOfWeek: Day.monday,
                    start: TimeOfDay(hour: 8, minute: 0),
                    end: TimeOfDay(hour: 16, minute: 0)),
                DailySchedule(
                    dayOfWeek: Day.wednesday,
                    start: TimeOfDay(hour: 8, minute: 0),
                    end: TimeOfDay(hour: 16, minute: 0)),
                DailySchedule(
                    dayOfWeek: Day.friday,
                    start: TimeOfDay(hour: 8, minute: 0),
                    end: TimeOfDay(hour: 12, minute: 0)),
              ],
              period: DateTimeRange(
                  start: DateTime(1990, 1, 1), end: DateTime(1990, 1, 31)))
        ],
        expectedDuration: 30,
        achievedDuration: -1,
        visitingPriority: VisitingPriority.low,
        endDate: null,
        teacherNotes: 'Nope'),
    '1': Internship(
        id: '1',
        studentId: '54321',
        signatoryTeacherId: '09876',
        extraSupervisingTeacherIds: ['54321'],
        enterpriseId: '54321',
        jobId: '09876',
        extraSpecializationIds: ['54321', '09876'],
        dates: DateTimeRange(
            start: DateTime(1990, 2, 1), end: DateTime(1990, 2, 28)),
        supervisorId: '54321',
        creationDate: DateTime(2000, 2, 1),
        weeklySchedules: [
          WeeklySchedule(
              schedule: [
                DailySchedule(
                    dayOfWeek: Day.tuesday,
                    start: TimeOfDay(hour: 9, minute: 0),
                    end: TimeOfDay(hour: 17, minute: 0)),
                DailySchedule(
                    dayOfWeek: Day.thursday,
                    start: TimeOfDay(hour: 9, minute: 0),
                    end: TimeOfDay(hour: 17, minute: 0)),
              ],
              period: DateTimeRange(
                  start: DateTime(1990, 2, 1), end: DateTime(1990, 2, 28)))
        ],
        expectedDuration: 20,
        achievedDuration: -1,
        visitingPriority: VisitingPriority.mid,
        endDate: null,
        teacherNotes: 'Yes'),
  };

  @override
  Future<Map<String, Internship>> _getAllInternships() async => _dummyDatabase;

  @override
  Future<Internship?> _getInternshipById({required String id}) async =>
      _dummyDatabase[id];

  @override
  Future<void> _putInternship(
          {required Internship internship,
          required Internship? previous}) async =>
      _dummyDatabase[internship.id] = internship;
}
