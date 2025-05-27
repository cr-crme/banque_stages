import 'package:backend/repositories/mysql_helpers.dart';
import 'package:backend/repositories/repository_abstract.dart';
import 'package:backend/utils/exceptions.dart';
import 'package:common/models/generic/address.dart';
import 'package:common/models/generic/phone_number.dart';
import 'package:common/models/internships/internship.dart';
import 'package:common/models/internships/schedule.dart';
import 'package:common/models/internships/time_utils.dart';
import 'package:common/models/itineraries/visiting_priority.dart';
import 'package:common/models/persons/person.dart';
import 'package:common/utils.dart';
import 'package:logging/logging.dart';
import 'package:mysql1/mysql1.dart';

final _logger = Logger('Connexions');

abstract class InternshipsRepository implements RepositoryAbstract {
  @override
  Future<Map<String, dynamic>> getAll({
    List<String>? fields,
    required String schoolBoardId,
  }) async {
    final internships = await _getAllInternships(schoolBoardId: schoolBoardId);
    return internships
        .map((key, value) => MapEntry(key, value.serializeWithFields(fields)));
  }

  @override
  Future<Map<String, dynamic>> getById({
    required String id,
    List<String>? fields,
    required String schoolBoardId,
  }) async {
    final internship =
        await _getInternshipById(id: id, schoolBoardId: schoolBoardId);
    if (internship == null) throw MissingDataException('Internship not found');

    return internship.serializeWithFields(fields);
  }

  @override
  Future<void> putAll({
    required Map<String, dynamic> data,
    required String schoolBoardId,
  }) async =>
      throw InvalidRequestException('Internships must be created individually');

  @override
  Future<List<String>> putById({
    required String id,
    required Map<String, dynamic> data,
    required String schoolBoardId,
  }) async {
    // Update if exists, insert if not
    final previous =
        await _getInternshipById(id: id, schoolBoardId: schoolBoardId);

    final newInternship = previous?.copyWithData(data) ??
        Internship.fromSerialized(<String, dynamic>{'id': id}..addAll(data));

    try {
      await _putInternship(internship: newInternship, previous: previous);
      return newInternship.getDifference(previous);
    } catch (e) {
      _logger.severe('Error while putting internship: $e');
      return [];
    }
  }

  @override
  Future<List<String>> deleteAll({
    required String schoolBoardId,
  }) async {
    throw InvalidRequestException('Internships must be deleted individually');
  }

  @override
  Future<String> deleteById({
    required String id,
    required String schoolBoardId,
  }) async {
    final removedId = await _deleteInternship(id: id);
    if (removedId == null) throw MissingDataException('Internship not found');
    return removedId;
  }

  Future<Map<String, Internship>> _getAllInternships(
      {required String schoolBoardId});

  Future<Internship?> _getInternshipById(
      {required String id, required String schoolBoardId});

  Future<void> _putInternship(
      {required Internship internship, required Internship? previous});

  Future<String?> _deleteInternship({required String id});
}

class MySqlInternshipsRepository extends InternshipsRepository {
  // coverage:ignore-start
  final MySqlConnection connection;
  MySqlInternshipsRepository({required this.connection});

  @override
  Future<Map<String, Internship>> _getAllInternships(
      {String? internshipId, required String schoolBoardId}) async {
    final internships = await MySqlHelpers.performSelectQuery(
        connection: connection,
        tableName: 'internships',
        filters: (internshipId == null ? {} : {'id': internshipId})
          ..addAll({
            'school_board_id': schoolBoardId,
          }),
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
        mutable['supervisor'] = (await MySqlHelpers.performSelectQuery(
                    connection: connection,
                    tableName: 'persons',
                    filters: {
                  'id': mutable['supervisor_id']
                },
                    subqueries: [
                  MySqlSelectSubQuery(
                      dataTableName: 'phone_numbers',
                      idNameToDataTable: 'entity_id',
                      fieldsToFetch: ['id', 'phone_number']),
                  MySqlSelectSubQuery(
                      dataTableName: 'addresses',
                      idNameToDataTable: 'entity_id',
                      fieldsToFetch: [
                        'id',
                        'civic',
                        'street',
                        'apartment',
                        'city',
                        'postal_code'
                      ]),
                ]) as List?)
                ?.first ??
            {};
        mutable['supervisor']['phone'] =
            (mutable['supervisor']['phone_numbers'] as List?)?.firstOrNull;
        mutable['supervisor']['address'] =
            (mutable['supervisor']['addresses'] as List?)?.firstOrNull;

        final schedules = await MySqlHelpers.performSelectQuery(
            connection: connection,
            tableName: 'internship_weekly_schedules',
            filters: {
              'mutable_data_id': mutable['id']
            },
            subqueries: [
              MySqlSelectSubQuery(
                dataTableName: 'internship_daily_schedules',
                asName: 'daily_schedules',
                fieldsToFetch: [
                  'id',
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
                filters: {
              'id': evaluation['id']
            },
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
            filters: {'evaluation_item_id': skill['id']},
          );
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
                filters: {
              'id': evaluation['id']
            },
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
            filters: {
              'post_evaluation_id': internship['enterprise_evaluation']['id']
            });
        internship['enterprise_evaluation']['skills_required'] = [
          for (final skill in (skills as List? ?? [])) skill['skill_name']
        ];
      }

      map[id] = Internship.fromSerialized(internship);
    }
    return map;
  }

  @override
  Future<Internship?> _getInternshipById(
          {required String id, required String schoolBoardId}) async =>
      (await _getAllInternships(
          internshipId: id, schoolBoardId: schoolBoardId))[id];

  Future<void> _insertToInternships(Internship internship) async {
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
          'school_board_id': internship.schoolBoardId.serialize(),
          'student_id': internship.studentId.serialize(),
          'enterprise_id': internship.enterpriseId.serialize(),
          'job_id': internship.jobId.serialize(),
          'expected_duration': internship.expectedDuration.serialize(),
          'achieved_duration': internship.achievedDuration.serialize(),
          'visiting_priority': internship.visitingPriority.serialize(),
          'teacher_notes': internship.teacherNotes.serialize(),
          'end_date': internship.endDate?.serialize(),
        });
  }

  Future<void> _updateToInternships(
      Internship internship, Internship previous) async {
    // Update the internship
    final differences = internship.getDifference(previous);
    if (differences.contains('school_board_id')) {
      _logger.severe('School board id cannot be changed');
      throw InvalidRequestException('School board id cannot be changed');
    }
    if (differences.contains('student_id')) {
      _logger.severe('Student id cannot be changed');
      throw InvalidRequestException('Student id cannot be changed');
    }
    if (differences.contains('enterprise_id')) {
      _logger.severe('Enterprise id cannot be changed');
      throw InvalidRequestException('Enterprise id cannot be changed');
    }
    if (differences.contains('job_id')) {
      _logger.severe('Job id cannot be changed');
      throw InvalidRequestException('Job id cannot be changed');
    }

    final toUpdate = <String, dynamic>{};
    if (differences.contains('expected_duration')) {
      toUpdate['expected_duration'] = internship.expectedDuration.serialize();
    }
    if (differences.contains('achieved_duration')) {
      toUpdate['achieved_duration'] = internship.achievedDuration.serialize();
    }
    if (differences.contains('visiting_priority')) {
      toUpdate['visiting_priority'] = internship.visitingPriority.serialize();
    }
    if (differences.contains('teacher_notes')) {
      toUpdate['teacher_notes'] = internship.teacherNotes.serialize();
    }
    if (differences.contains('end_date')) {
      toUpdate['end_date'] = internship.endDate?.serialize();
    }
    if (toUpdate.isNotEmpty) {
      await MySqlHelpers.performUpdateQuery(
          connection: connection,
          tableName: 'internships',
          filters: {'id': internship.id},
          data: toUpdate);
    }
  }

  Future<void> _insertToSupervisingTeachers(Internship internship) async {
    final toWait = <Future>[];
    for (final teacherId in internship.supervisingTeacherIds) {
      toWait.add(MySqlHelpers.performInsertQuery(
          connection: connection,
          tableName: 'internship_supervising_teachers',
          data: {
            'internship_id': internship.id,
            'teacher_id': teacherId,
            'is_signatory_teacher': teacherId == internship.signatoryTeacherId
          }));
    }
    await Future.wait(toWait);
  }

  Future<void> _updateToSupervisingTeachers(
      Internship internship, Internship previous) async {
    final toUpdate = internship.getDifference(previous);
    if (toUpdate.contains('signatory_teacher_id') ||
        toUpdate.contains('extra_supervising_teacher_ids')) {
      // This is a bit tricky to simply update, so we delete and reinsert
      await MySqlHelpers.performDeleteQuery(
          connection: connection,
          tableName: 'internship_supervising_teachers',
          filters: {'internship_id': internship.id});

      await _insertToSupervisingTeachers(internship);
    }
  }

  Future<void> _insertExtraSpecializations(Internship internship) async {
    for (final specializationId in internship.extraSpecializationIds) {
      await MySqlHelpers.performInsertQuery(
          connection: connection,
          tableName: 'internship_extra_specializations',
          data: {
            'internship_id': internship.id,
            'specialization_id': specializationId
          });
    }
  }

  Future<void> _updateToExtraSpecializations(
      Internship internship, Internship previous) async {
    final toUpdate = internship.getDifference(previous);
    if (toUpdate.contains('extra_specialization_ids')) {
      // This is a bit tricky to simply update, so we delete and reinsert
      await MySqlHelpers.performDeleteQuery(
          connection: connection,
          tableName: 'internship_extra_specializations',
          filters: {'internship_id': internship.id});

      await _insertExtraSpecializations(internship);
    }
  }

  Future<void> _insertToMutables(Internship internship,
      [Internship? previous]) async {
    final previousSerialized = previous?.serializedMutables ?? [];
    bool supervisorIsUpdated = false;
    for (final mutable in internship.serializedMutables) {
      if (previousSerialized.any((e) => e['id'] == mutable['id'])) {
        // Skip if the mutable already exists
        continue;
      }
      if (!supervisorIsUpdated) {
        final previousSupervisor = (await MySqlHelpers.performSelectQuery(
                    connection: connection,
                    tableName: 'persons',
                    filters: {
                  'id': mutable['supervisor']['id']
                },
                    subqueries: [
                  MySqlSelectSubQuery(
                      dataTableName: 'phone_numbers',
                      idNameToDataTable: 'entity_id',
                      fieldsToFetch: ['id', 'phone_number']),
                  MySqlSelectSubQuery(
                      dataTableName: 'addresses',
                      idNameToDataTable: 'entity_id',
                      fieldsToFetch: [
                        'id',
                        'civic',
                        'street',
                        'apartment',
                        'city',
                        'postal_code'
                      ]),
                ]) as List?)
                ?.firstOrNull as Map<String, dynamic>? ??
            {};
        previousSupervisor['phone'] =
            (previousSupervisor['phone_numbers'] as List?)?[0] ?? [];
        previousSupervisor['address'] =
            (previousSupervisor['addresses'] as List?)?[0] ?? [];

        if (previousSupervisor.isEmpty) {
          await MySqlHelpers.performInsertPerson(
              connection: connection, person: internship.supervisor);
        } else {
          // Update the person (without the phone numbers and addresses of previous as they were removed)
          await MySqlHelpers.performUpdatePerson(
              connection: connection,
              person: internship.supervisor,
              previous: Person.fromSerialized(previousSupervisor));
        }
        supervisorIsUpdated = true;
      }

      await MySqlHelpers.performInsertQuery(
          connection: connection,
          tableName: 'internship_mutable_data',
          data: {
            'id': mutable['id'],
            'internship_id': internship.id,
            'creation_date': mutable['creation_date'],
            'supervisor_id': internship.supervisor.id,
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
  }

  Future<void> _updateToMutables(
      Internship internship, Internship previous) async {
    // We don't update the mutable data, but stack them
    await _insertToMutables(internship, previous);
  }

  Future<void> _insertToSkillEvaluations(Internship internship,
      [Internship? previous]) async {
    for (final evaluation in internship.skillEvaluations.serialize()) {
      if (previous?.skillEvaluations.any((e) => e.id == evaluation['id']) ??
          false) {
        // Skip if the evaluation already exists
        continue;
      }

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
  }

  Future<void> _updateToSkillEvaluations(
      Internship internship, Internship previous) async {
    // Skill evaluations are not updated, but stacked
    _insertToSkillEvaluations(internship, previous);
  }

  Future<void> _insertToAttitudeEvaluations(Internship internship,
      [Internship? previous]) async {
    for (final evaluation in internship.attitudeEvaluations.serialize()) {
      if (previous?.attitudeEvaluations.any((e) => e.id == evaluation['id']) ??
          false) {
        // Skip if the evaluation already exists
        continue;
      }

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
  }

  Future<void> _updateToAttitudeEvaluations(
      Internship internship, Internship previous) async {
    // Attitude evaluations are not updated, but stacked
    _insertToAttitudeEvaluations(internship, previous);
  }

  Future<void> _insertToEnterpriseEvaluation(Internship internship) async {
    if (internship.enterpriseEvaluation != null) {
      final evaluation = internship.enterpriseEvaluation!.serialize();
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
  }

  Future<void> _updateToEnterpriseEvaluation(
      Internship internship, Internship previous) async {
    final toUpdate = internship.getDifference(previous);
    if (toUpdate.contains('enterprise_evaluation')) {
      _logger.severe('Enterprise evaluation cannot be changed');
      throw InvalidRequestException('Enterprise evaluation cannot be changed');
    }
  }

  @override
  Future<void> _putInternship(
      {required Internship internship, required Internship? previous}) async {
    if (previous == null) {
      await _insertToInternships(internship);
    } else {
      await _updateToInternships(internship, previous);
    }

    // Insert simultaneously elements
    final toWait = <Future>[];
    if (previous == null) {
      toWait.add(_insertToSupervisingTeachers(internship));
      toWait.add(_insertExtraSpecializations(internship));
      toWait.add(_insertToMutables(internship));
      toWait.add(_insertToSkillEvaluations(internship));
      toWait.add(_insertToAttitudeEvaluations(internship));
      toWait.add(_insertToEnterpriseEvaluation(internship));
    } else {
      toWait.add(_updateToSupervisingTeachers(internship, previous));
      toWait.add(_updateToExtraSpecializations(internship, previous));
      toWait.add(_updateToMutables(internship, previous));
      toWait.add(_updateToSkillEvaluations(internship, previous));
      toWait.add(_updateToAttitudeEvaluations(internship, previous));
      toWait.add(_updateToEnterpriseEvaluation(internship, previous));
    }
    await Future.wait(toWait);
  }

  @override
  Future<String?> _deleteInternship({required String id}) async {
    try {
      final mutable = (await MySqlHelpers.performSelectQuery(
        connection: connection,
        tableName: 'internship_mutable_data',
        filters: {'internship_id': id},
      ))
          .lastOrNull;

      await MySqlHelpers.performDeleteQuery(
        connection: connection,
        tableName: 'entities',
        filters: {'shared_id': id},
      );
      if (mutable != null) {
        await MySqlHelpers.performDeleteQuery(
          connection: connection,
          tableName: 'entities',
          filters: {'shared_id': mutable['supervisor_id']},
        );
      }

      return id;
    } catch (e) {
      return null;
    }
  }
}

class InternshipsRepositoryMock extends InternshipsRepository {
  // Simulate a database with a map
  final _dummyDatabase = {
    '0': Internship(
        id: '0',
        schoolBoardId: '0',
        studentId: '12345',
        signatoryTeacherId: '67890',
        extraSupervisingTeacherIds: [],
        enterpriseId: '12345',
        jobId: '67890',
        extraSpecializationIds: ['12345'],
        dates: DateTimeRange(
            start: DateTime(1990, 1, 1), end: DateTime(1990, 1, 31)),
        supervisor: Person(
            firstName: 'Mine',
            middleName: null,
            lastName: 'Yours',
            dateBirth: null,
            address: Address.empty,
            phone: PhoneNumber.empty,
            email: null),
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
        schoolBoardId: '0',
        studentId: '54321',
        signatoryTeacherId: '09876',
        extraSupervisingTeacherIds: ['54321'],
        enterpriseId: '54321',
        jobId: '09876',
        extraSpecializationIds: ['54321', '09876'],
        dates: DateTimeRange(
            start: DateTime(1990, 2, 1), end: DateTime(1990, 2, 28)),
        supervisor: Person(
            firstName: 'Mine',
            middleName: null,
            lastName: 'Yours',
            dateBirth: null,
            address: Address.empty,
            phone: PhoneNumber.empty,
            email: null),
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
  Future<Map<String, Internship>> _getAllInternships(
          {required String schoolBoardId}) async =>
      _dummyDatabase;

  @override
  Future<Internship?> _getInternshipById(
          {required String id, required String schoolBoardId}) async =>
      _dummyDatabase[id];

  @override
  Future<void> _putInternship(
          {required Internship internship,
          required Internship? previous}) async =>
      _dummyDatabase[internship.id] = internship;

  @override
  Future<String?> _deleteInternship({required String id}) async {
    if (_dummyDatabase.containsKey(id)) {
      _dummyDatabase.remove(id);
      return id;
    }
    return null;
  }
}
