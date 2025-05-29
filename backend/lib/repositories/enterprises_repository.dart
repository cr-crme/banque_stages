import 'package:backend/repositories/internships_repository.dart';
import 'package:backend/repositories/mysql_helpers.dart';
import 'package:backend/repositories/repository_abstract.dart';
import 'package:backend/utils/database_user.dart';
import 'package:backend/utils/exceptions.dart';
import 'package:common/models/enterprises/enterprise.dart';
import 'package:common/models/enterprises/job.dart';
import 'package:common/models/enterprises/job_list.dart';
import 'package:common/models/generic/address.dart';
import 'package:common/models/generic/phone_number.dart';
import 'package:common/models/internships/internship.dart';
import 'package:common/models/persons/person.dart';
import 'package:common/utils.dart';
import 'package:logging/logging.dart';
import 'package:mysql1/mysql1.dart';

final _logger = Logger('EnterprisesRepository');

// AccessLevel in this repository is discarded as all operations are currently
// available to all users

abstract class EnterprisesRepository implements RepositoryAbstract {
  @override
  Future<Map<String, dynamic>> getAll({
    List<String>? fields,
    required DatabaseUser user,
  }) async {
    final enterprises = await _getAllEnterprises(user: user);
    return enterprises
        .map((key, value) => MapEntry(key, value.serializeWithFields(fields)));
  }

  @override
  Future<Map<String, dynamic>> getById({
    required String id,
    List<String>? fields,
    required DatabaseUser user,
  }) async {
    final enterprise = await _getEnterpriseById(id: id, user: user);
    if (enterprise == null) throw MissingDataException('Enterprise not found');

    return enterprise.serializeWithFields(fields);
  }

  @override
  Future<void> putAll({
    required Map<String, dynamic> data,
    required DatabaseUser user,
  }) async =>
      throw InvalidRequestException('Enterprises must be created individually');

  @override
  Future<List<String>> putById({
    required String id,
    required Map<String, dynamic> data,
    required DatabaseUser user,
    InternshipsRepository? internshipsRepository,
  }) async {
    if (internshipsRepository == null) {
      throw InvalidRequestException(
          'Internships repository is required for this operation');
    }

    // Update if exists, insert if not
    final previous = await _getEnterpriseById(id: id, user: user);

    final newEnterprise = previous?.copyWithData(data) ??
        Enterprise.fromSerialized(<String, dynamic>{'id': id}..addAll(data));

    try {
      await _putEnterprise(
          enterprise: newEnterprise,
          previous: previous,
          user: user,
          internshipsRepository: internshipsRepository);
      return newEnterprise.getDifference(previous);
    } catch (e) {
      _logger.severe('Error while putting enterprise: $e');
      return [];
    }
  }

  @override
  Future<List<String>> deleteAll({
    required DatabaseUser user,
  }) async {
    throw InvalidRequestException('Enterprises must be deleted individually');
  }

  @override
  Future<String> deleteById({
    required String id,
    required DatabaseUser user,
    InternshipsRepository? internshipsRepository,
  }) async {
    final removedId = await _deleteEnterprise(
        id: id, user: user, internshipsRepository: internshipsRepository);
    if (removedId == null) throw MissingDataException('Enterprise not found');
    return removedId;
  }

  Future<Map<String, Enterprise>> _getAllEnterprises({
    required DatabaseUser user,
  });

  Future<Enterprise?> _getEnterpriseById({
    required String id,
    required DatabaseUser user,
  });

  Future<void> _putEnterprise({
    required Enterprise enterprise,
    required Enterprise? previous,
    required DatabaseUser user,
    required InternshipsRepository internshipsRepository,
  });

  Future<String?> _deleteEnterprise(
      {required String id,
      required DatabaseUser user,
      required InternshipsRepository? internshipsRepository});
}

class MySqlEnterprisesRepository extends EnterprisesRepository {
  // coverage:ignore-start
  final MySqlConnection connection;
  MySqlEnterprisesRepository({required this.connection});

  @override
  Future<Map<String, Enterprise>> _getAllEnterprises({
    String? enterpriseId,
    required DatabaseUser user,
  }) async {
    final enterprises = await MySqlHelpers.performSelectQuery(
      connection: connection,
      user: user,
      tableName: 'enterprises',
      filters: (enterpriseId == null ? {} : {'id': enterpriseId})
        ..addAll({'school_board_id': user.schoolBoardId ?? ''}),
      subqueries: [
        MySqlJoinSubQuery(
            dataTableName: 'persons',
            asName: 'contact',
            idNameToDataTable: 'contact_id',
            idNameToMainTable: 'enterprise_id',
            relationTableName: 'enterprise_contacts',
            fieldsToFetch: ['id']),
        MySqlJoinSubQuery(
            dataTableName: 'addresses',
            asName: 'address',
            idNameToDataTable: 'address_id',
            idNameToMainTable: 'enterprise_id',
            relationTableName: 'enterprise_addresses',
            fieldsToFetch: [
              'id',
              'civic',
              'street',
              'apartment',
              'city',
              'postal_code'
            ]),
        MySqlJoinSubQuery(
            dataTableName: 'addresses',
            asName: 'headquarters_address',
            idNameToDataTable: 'address_id',
            idNameToMainTable: 'enterprise_id',
            relationTableName: 'enterprise_headquarters_addresses',
            fieldsToFetch: [
              'id',
              'civic',
              'street',
              'apartment',
              'city',
              'postal_code'
            ]),
        MySqlJoinSubQuery(
            dataTableName: 'phone_numbers',
            asName: 'phone_number',
            idNameToDataTable: 'phone_number_id',
            idNameToMainTable: 'enterprise_id',
            relationTableName: 'enterprise_phone_numbers',
            fieldsToFetch: ['id', 'phone_number']),
        MySqlJoinSubQuery(
            dataTableName: 'phone_numbers',
            asName: 'fax_number',
            idNameToDataTable: 'fax_number_id',
            idNameToMainTable: 'enterprise_id',
            relationTableName: 'enterprise_fax_numbers',
            fieldsToFetch: ['id', 'phone_number']),
        MySqlSelectSubQuery(
            dataTableName: 'enterprise_activity_types',
            asName: 'activity_types',
            idNameToDataTable: 'enterprise_id',
            fieldsToFetch: ['activity_type']),
      ],
    );

    final map = <String, Enterprise>{};
    for (final enterprise in enterprises) {
      final contactId =
          (enterprise['contact'] as List?)?.map((e) => e['id']).firstOrNull;
      final contacts = contactId == null
          ? null
          : await MySqlHelpers.performSelectQuery(
              connection: connection,
              user: user,
              tableName: 'persons',
              filters: {
                  'id': contactId
                },
              subqueries: [
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
                  MySqlSelectSubQuery(
                      dataTableName: 'phone_numbers',
                      idNameToDataTable: 'entity_id',
                      fieldsToFetch: ['id', 'phone_number']),
                ]);
      enterprise['contact'] = contacts?.firstOrNull ?? {};
      enterprise['contact']['address'] =
          (enterprise['contact']['addresses'] as List?)?.firstOrNull ?? {};
      enterprise['contact']['phone'] =
          (enterprise['contact']['phone_numbers'] as List?)?.firstOrNull ?? {};
      enterprise['activity_types'] =
          (enterprise['activity_types'] as List? ?? [])
              .map((e) => e['activity_type'])
              .toList();
      enterprise['phone'] = (enterprise['phone_number'] as List?)?.firstOrNull;
      enterprise['fax'] = (enterprise['fax_number'] as List?)?.firstOrNull;
      enterprise['address'] =
          (enterprise['address'] as List?)?.firstOrNull ?? {};
      enterprise['headquarters_address'] =
          (enterprise['headquarters_address'] as List?)?.firstOrNull ?? {};

      final jobsTp = await MySqlHelpers.performSelectQuery(
        connection: connection,
        user: user,
        tableName: 'enterprise_jobs',
        filters: {'enterprise_id': enterprise['id']},
        subqueries: [
          MySqlSelectSubQuery(
              dataTableName: 'enterprise_job_photo_urls',
              asName: 'photo_url',
              idNameToDataTable: 'job_id',
              fieldsToFetch: ['photo_url']),
          MySqlSelectSubQuery(
              dataTableName: 'enterprise_job_comments',
              asName: 'comments',
              idNameToDataTable: 'job_id',
              fieldsToFetch: ['comment']),
          MySqlSelectSubQuery(
              dataTableName: 'enterprise_job_pre_internship_requests',
              asName: 'pre_internship_requests',
              idNameToDataTable: 'job_id',
              fieldsToFetch: ['id', 'other', 'is_applicable']),
          MySqlSelectSubQuery(
              dataTableName: 'enterprise_job_uniforms',
              asName: 'uniforms',
              idNameToDataTable: 'job_id',
              fieldsToFetch: ['status', 'uniform']),
          MySqlSelectSubQuery(
              dataTableName: 'enterprise_job_protections',
              asName: 'protections',
              idNameToDataTable: 'job_id',
              fieldsToFetch: ['status', 'protection']),
          MySqlSelectSubQuery(
              dataTableName: 'enterprise_job_incidents',
              asName: 'incidents',
              idNameToDataTable: 'job_id',
              fieldsToFetch: ['id', 'incident_type', 'incident', 'date']),
          MySqlSelectSubQuery(
              dataTableName: 'enterprise_job_sst_evaluation_questions',
              asName: 'sst_evaluations',
              idNameToDataTable: 'job_id',
              fieldsToFetch: ['question', 'answers', 'date']),
        ],
      );
      final jobs = <String, dynamic>{};
      for (final job in jobsTp) {
        jobs[job['id']] = job;
        jobs[job['id']]['photos_url'] =
            (job['photo_url'] as List?)?.map((e) => e['photo_url']).toList() ??
                [];
        jobs[job['id']]['comments'] =
            (job['comments'] as List?)?.map((e) => e['comment']).toList() ?? [];
        jobs[job['id']]['pre_internship_requests'] =
            ((job['pre_internship_requests'] as List?)?.first as Map?) ?? {};
        jobs[job['id']]['pre_internship_requests']['is_applicable'] =
            jobs[job['id']]['pre_internship_requests']['is_applicable'] == 1;
        jobs[job['id']]['pre_internship_requests']['requests'] =
            (await MySqlHelpers.performSelectQuery(
                  connection: connection,
                  user: user,
                  tableName: 'enterprise_job_pre_internship_request_items',
                  filters: {
                    'internship_request_id': job['pre_internship_requests']
                        ['id']
                  },
                ) as List?)
                    ?.map((e) => e['request'] as int)
                    .toList() ??
                [];
        final uniforms = job['uniforms'] as List? ?? [];
        jobs[job['id']]['uniforms'] = uniforms.isEmpty
            ? null
            : {
                'status': uniforms.first['status'],
                'uniforms': uniforms.map((e) => e['uniform']).toList()
              };
        final protections = job['protections'] as List? ?? [];
        jobs[job['id']]['protections'] = protections.isEmpty
            ? null
            : {
                'status': protections.first['status'],
                'protections': protections.map((e) => e['protection']).toList()
              };
        final incidents = job['incidents'] as List? ?? [];
        jobs[job['id']]['incidents'] = incidents.isEmpty
            ? null
            : {
                'severe_injuries': incidents
                    .where((e) => e['incident_type'] == 'severe_injuries')
                    .toList(),
                'verbal_abuses': incidents
                    .where((e) => e['incident_type'] == 'verbal_abuses')
                    .toList(),
                'minor_injuries': incidents
                    .where((e) => e['incident_type'] == 'minor_injuries')
                    .toList(),
              };
        final sstEvaluations = job['sst_evaluations'] as List? ?? [];
        jobs[job['id']]['sst_evaluations'] = sstEvaluations.isEmpty
            ? null
            : {
                'questions': {
                  for (final Map question in sstEvaluations)
                    question['question']:
                        (question['answers'] as String?)?.split('\n') ?? []
                },
                'date': sstEvaluations.first['date'] ?? 0
              };
      }
      enterprise['jobs'] = jobs;

      map[enterprise['id'].toString()] = Enterprise.fromSerialized(enterprise);
    }

    return map;
  }

  @override
  Future<Enterprise?> _getEnterpriseById({
    required String id,
    required DatabaseUser user,
  }) async =>
      (await _getAllEnterprises(enterpriseId: id, user: user))[id];

  Future<void> _insertToEnterprises(Enterprise enterprise) async {
    await MySqlHelpers.performInsertQuery(
        connection: connection,
        tableName: 'entities',
        data: {'shared_id': enterprise.id.serialize()});
    await MySqlHelpers.performInsertQuery(
      connection: connection,
      tableName: 'enterprises',
      data: {
        'id': enterprise.id.serialize(),
        'school_board_id': enterprise.schoolBoardId.serialize(),
        'version': Enterprise.currentVersion.serialize(),
        'name': enterprise.name.serialize(),
        'recruiter_id': enterprise.recruiterId.serialize(),
        'contact_function': enterprise.contactFunction.serialize(),
        'website': enterprise.website?.serialize(),
        'neq': enterprise.neq?.serialize(),
      },
    );
  }

  Future<void> _updateToEnterprises(
      Enterprise enterprise, Enterprise previous) async {
    final differences = enterprise.getDifference(previous);

    if (differences.contains('id')) {
      _logger.severe('Cannot update the id of an enterprise');
      throw InvalidRequestException('Cannot update the id of an enterprise');
    }
    if (differences.contains('school_board_id')) {
      _logger.severe(
          'Cannot update the school board id of an enterprise. Please delete and re-create the enterprise');
      throw InvalidRequestException(
          'Cannot update the school board id of an enterprise. Please delete and re-create the enterprise');
    }

    final toUpdate = <String, dynamic>{};
    if (differences.contains('name')) {
      toUpdate['name'] = enterprise.name.serialize();
    }
    if (differences.contains('recruiter_id')) {
      toUpdate['recruiter_id'] = enterprise.recruiterId.serialize();
    }
    if (differences.contains('contact_function')) {
      toUpdate['contact_function'] = enterprise.contactFunction.serialize();
    }
    if (differences.contains('website')) {
      toUpdate['website'] = enterprise.website?.serialize();
    }
    if (differences.contains('neq')) {
      toUpdate['neq'] = enterprise.neq?.serialize();
    }

    if (toUpdate.isNotEmpty) {
      await MySqlHelpers.performUpdateQuery(
        connection: connection,
        tableName: 'enterprises',
        filters: {'id': previous.id},
        data: toUpdate,
      );
    }
  }

  Future<void> _insertToEnterprisesActivityTypes(Enterprise enterprise) async {
    for (final activityType in enterprise.activityTypesSerialized) {
      await MySqlHelpers.performInsertQuery(
          connection: connection,
          tableName: 'enterprise_activity_types',
          data: {
            'enterprise_id': enterprise.id.serialize(),
            'activity_type': activityType,
          });
    }
  }

  Future<void> _updateToEnterprisesActivityTypes(
      Enterprise enterprise, Enterprise previous) async {
    final toUpdate = enterprise.getDifference(previous);
    if (!toUpdate.contains('activity_types')) return;

    // This is a bit tricky to simply update, so we delete and reinsert
    await MySqlHelpers.performDeleteQuery(
        connection: connection,
        tableName: 'enterprise_activity_types',
        filters: {'enterprise_id': previous.id});
    await _insertToEnterprisesActivityTypes(enterprise);
  }

  Future<void> _insertJobPhotoUrls(List<String> urls, String jobId) async {
    final toWait = <Future>[];
    for (final url in urls) {
      toWait.add(MySqlHelpers.performInsertQuery(
          connection: connection,
          tableName: 'enterprise_job_photo_urls',
          data: {
            'job_id': jobId.serialize(),
            'photo_url': url.serialize(),
          }));
    }
    await Future.wait(toWait);
  }

  Future<void> _insertJobComments(List<String> comments, String jobId) async {
    final toWait = <Future>[];
    for (final comment in comments) {
      toWait.add(MySqlHelpers.performInsertQuery(
          connection: connection,
          tableName: 'enterprise_job_comments',
          data: {
            'job_id': jobId.serialize(),
            'comment': comment.serialize(),
          }));
    }
    await Future.wait(toWait);
  }

  Future<void> _insertJobPreintershipRequests(
      PreInternshipRequests requests, String jobId) async {
    // Insert pre-internship requests for the job
    final preInternshipRequests = requests.serialize();
    await MySqlHelpers.performInsertQuery(
        connection: connection,
        tableName: 'enterprise_job_pre_internship_requests',
        data: {
          'id': preInternshipRequests['id'],
          'job_id': jobId.serialize(),
          'other': preInternshipRequests['other'],
          'is_applicable': preInternshipRequests['is_applicable'],
        });

    final toWait = <Future>[];
    for (final request in (preInternshipRequests['requests'] as List)) {
      toWait.add(MySqlHelpers.performInsertQuery(
          connection: connection,
          tableName: 'enterprise_job_pre_internship_request_items',
          data: {
            'internship_request_id': preInternshipRequests['id'],
            'request': request,
          }));
    }
    await Future.wait(toWait);
  }

  Future<void> _insertJobUniforms(Uniforms uniforms, String jobId) async {
    final status = uniforms.serialize()['status'];
    final toWait = <Future>[];
    for (final uniform in uniforms.uniforms) {
      toWait.add(MySqlHelpers.performInsertQuery(
          connection: connection,
          tableName: 'enterprise_job_uniforms',
          data: {
            'job_id': jobId.serialize(),
            'status': status,
            'uniform': uniform.serialize(),
          }));
    }
    await Future.wait(toWait);
  }

  Future<void> _insertJobProtections(
      Protections protections, String jobId) async {
    final status = protections.serialize()['status'];
    final toWait = <Future>[];
    for (final protection in protections.protections) {
      toWait.add(MySqlHelpers.performInsertQuery(
          connection: connection,
          tableName: 'enterprise_job_protections',
          data: {
            'job_id': jobId.serialize(),
            'status': status,
            'protection': protection.serialize(),
          }));
    }
    await Future.wait(toWait);
  }

  Future<void> _insertJobIncidents(Incidents incidents, String jobId) async {
    final serialized = incidents.serialize();
    final toWait = <Future>[];
    for (final incidentType in serialized.keys) {
      if (incidentType == 'id') continue;
      for (final incident in serialized[incidentType]) {
        toWait.add(MySqlHelpers.performInsertQuery(
            connection: connection,
            tableName: 'enterprise_job_incidents',
            data: {
              'id': incident['id'],
              'job_id': jobId.serialize(),
              'incident_type': incidentType.serialize(),
              'incident': incident['incident'],
              'date': incident['date'],
            }));
      }
    }
    await Future.wait(toWait);
  }

  Future<void> _insertJobSstEvaluation(
      JobSstEvaluation sstEvaluation, String jobId) async {
    final serialized =
        sstEvaluation.serialize()['questions'] as Map<String, dynamic>;
    final toWait = <Future>[];
    for (final question in serialized.keys) {
      toWait.add(MySqlHelpers.performInsertQuery(
          connection: connection,
          tableName: 'enterprise_job_sst_evaluation_questions',
          data: {
            'job_id': jobId.serialize(),
            'date': sstEvaluation.date.serialize(),
            'question': question,
            'answers': (serialized[question] as List?)?.join('\n'),
          }));
    }
    await Future.wait(toWait);
  }

  Future<void> _insertToEnterprisesJob(String enterpriseId, Job job) async {
    await MySqlHelpers.performInsertQuery(
        connection: connection,
        tableName: 'enterprise_jobs',
        data: {
          'id': job.id.serialize(),
          'version': Job.currentVersion.serialize(),
          'enterprise_id': enterpriseId.serialize(),
          'specialization_id': job.specialization.id.serialize(),
          'positions_offered': job.positionsOffered.serialize(),
          'minimum_age': job.minimumAge.serialize(),
        });

    final toWait = <Future>[];
    toWait.add(_insertJobPhotoUrls(job.photosUrl, job.id.serialize()));
    toWait.add(_insertJobComments(job.comments, job.id.serialize()));
    toWait.add(_insertJobPreintershipRequests(
        job.preInternshipRequests, job.id.serialize()));
    toWait.add(_insertJobUniforms(job.uniforms, job.id.serialize()));
    toWait.add(_insertJobProtections(job.protections, job.id.serialize()));
    toWait.add(_insertJobIncidents(job.incidents, job.id.serialize()));
    toWait.add(_insertJobSstEvaluation(job.sstEvaluation, job.id.serialize()));

    await Future.wait(toWait);
  }

  Future<void> _insertToEnterprisesJobs(Enterprise enterprise) async {
    final toWait = <Future>[];
    for (final job in enterprise.jobs) {
      toWait.add(_insertToEnterprisesJob(enterprise.id, job));
    }
    await Future.wait(toWait);
  }

  Future<void> _updateToEnterprisesJobs(
    Enterprise enterprise,
    Enterprise previous, {
    required DatabaseUser user,
    required InternshipsRepository internshipsRepository,
  }) async {
    final toUpdate = enterprise.getDifference(previous);
    if (!toUpdate.contains('jobs')) return;

    // Prevent from removing a job from an enterprise
    for (final job in previous.jobs) {
      if (!enterprise.jobs.map((e) => e.id).contains(job.id)) {
        _logger.warning(
            'It is not possible to remove a job from an enterprise, but will do anyway');
        await _deleteInternshipsFromJob(job.id,
            user: user, internshipsRepository: internshipsRepository);
        await MySqlHelpers.performDeleteQuery(
            connection: connection,
            tableName: 'enterprise_jobs',
            filters: {'id': job.id});
      }
    }

    // Add the new jobs
    final toWait = <Future>[];
    for (final job in enterprise.jobs) {
      if (!previous.jobs.map((e) => e.id).contains(job.id)) {
        toWait.add(_insertToEnterprisesJob(enterprise.id, job));
      }
    }
    await Future.wait(toWait);

    for (final job in enterprise.jobs) {
      final previousJob = previous.jobs.firstWhereOrNull((e) => e.id == job.id);
      if (previousJob == null) continue; // Dealt with above

      final differences = job.getDifference(previousJob);
      if (differences.isEmpty) continue;

      if (differences.contains('id')) {
        _logger.severe('Cannot update the id of a job');
        throw InvalidRequestException('Cannot update the id of a job');
      }
      if (differences.contains('enterprise_id')) {
        _logger.severe('Cannot update the enterprise id of a job');
        throw InvalidRequestException(
            'Cannot update the enterprise id of a job');
      }

      final toUpdate = <String, dynamic>{};
      if (differences.contains('specialization_id')) {
        _logger.warning(
            'Cannot update the specialization id of a job, but will do anyway');
        toUpdate['specialization_id'] = job.specialization.id.serialize();
      }

      if (differences.contains('positions_offered')) {
        toUpdate['positions_offered'] = job.positionsOffered.serialize();
      }
      if (differences.contains('minimum_age')) {
        toUpdate['minimum_age'] = job.minimumAge.serialize();
      }
      if (toUpdate.isNotEmpty) {
        await MySqlHelpers.performUpdateQuery(
          connection: connection,
          tableName: 'enterprise_jobs',
          filters: {'id': job.id},
          data: toUpdate,
        );
      }

      // PhotoUrls, Comments, Uniforms, protections and incidents are
      // tricky to update, so we delete and reinsert all of them.
      final toWaitDeleted = <Future>[];
      toWait.clear();
      if (differences.contains('photos_url')) {
        // This is a bit tricky to simply update, so we delete and reinsert
        toWaitDeleted.add(MySqlHelpers.performDeleteQuery(
            connection: connection,
            tableName: 'enterprise_job_photo_urls',
            filters: {'job_id': job.id}));
        toWait.add(_insertJobPhotoUrls(job.photosUrl, job.id.serialize()));
      }

      if (differences.contains('comments')) {
        toWaitDeleted.add(MySqlHelpers.performDeleteQuery(
            connection: connection,
            tableName: 'enterprise_job_comments',
            filters: {'job_id': job.id}));
        toWait.add(_insertJobComments(job.comments, job.id.serialize()));
      }

      // Pre-internship requests would not be that hard to actually update, but
      // is not so important, so we use the same trick of deleting and reinserting.
      // It helps to keep the code simple and consistent and also helps for the items.
      if (differences.contains('pre_internship_requests')) {
        toWaitDeleted.add(MySqlHelpers.performDeleteQuery(
            connection: connection,
            tableName: 'enterprise_job_pre_internship_requests',
            filters: {'job_id': job.id}));
        toWait.add(_insertJobPreintershipRequests(
            job.preInternshipRequests, job.id.serialize()));
      }

      if (differences.contains('uniforms')) {
        toWaitDeleted.add(MySqlHelpers.performDeleteQuery(
            connection: connection,
            tableName: 'enterprise_job_uniforms',
            filters: {'job_id': job.id}));
        toWait.add(_insertJobUniforms(job.uniforms, job.id.serialize()));
      }

      if (differences.contains('protections')) {
        toWaitDeleted.add(MySqlHelpers.performDeleteQuery(
            connection: connection,
            tableName: 'enterprise_job_protections',
            filters: {'job_id': job.id}));
        toWait.add(_insertJobProtections(job.protections, job.id.serialize()));
      }

      if (differences.contains('incidents')) {
        toWaitDeleted.add(MySqlHelpers.performDeleteQuery(
            connection: connection,
            tableName: 'enterprise_job_incidents',
            filters: {'job_id': job.id}));
        toWait.add(_insertJobIncidents(job.incidents, job.id.serialize()));
      }

      // It would be possible to update properly the sst evaluation, but
      // it is not so important, so we use the same trick of deleting and
      // reinserting.
      if (differences.contains('sst_evaluations')) {
        toWaitDeleted.add(MySqlHelpers.performDeleteQuery(
            connection: connection,
            tableName: 'enterprise_job_sst_evaluation_questions',
            filters: {'job_id': job.id}));
        toWait.add(
            _insertJobSstEvaluation(job.sstEvaluation, job.id.serialize()));
      }

      // Wait for all the deletions and insertions to finish
      await Future.wait(toWaitDeleted);
      await Future.wait(toWait);
    }
  }

  Future<void> _insertToContact(Enterprise enterprise) async {
    // Insert the contact
    await MySqlHelpers.performInsertPerson(
        connection: connection, person: enterprise.contact);
    await MySqlHelpers.performInsertQuery(
        connection: connection,
        tableName: 'enterprise_contacts',
        data: {
          'enterprise_id': enterprise.id,
          'contact_id': enterprise.contact.id
        });
  }

  Future<void> _updateToContact(
      Enterprise enterprise, Enterprise previous) async {
    final toUpdate = enterprise.getDifference(previous);
    if (!toUpdate.contains('contact')) return;

    if (enterprise.contact.id != previous.contact.id) {
      _logger.severe('Cannot update the contact id of an enterprise');
      throw InvalidRequestException(
          'Cannot update the contact id of an enterprise');
    }

    await MySqlHelpers.performUpdatePerson(
        connection: connection,
        person: enterprise.contact,
        previous: previous.contact);
  }

  Future<void> _insertToEnterpriseAddress(Enterprise enterprise) async {
    if (enterprise.address == null) return;
    await MySqlHelpers.performInsertAddress(
        connection: connection,
        address: enterprise.address!,
        entityId: enterprise.id);
    await MySqlHelpers.performInsertQuery(
        connection: connection,
        tableName: 'enterprise_addresses',
        data: {
          'enterprise_id': enterprise.id,
          'address_id': enterprise.address!.id
        });
  }

  Future<void> _updateToEnterpriseAddress(
      Enterprise enterprise, Enterprise previous) async {
    final toUpdate = enterprise.getDifference(previous);
    if (!toUpdate.contains('address')) return;

    if (previous.address == null) {
      await _insertToEnterpriseAddress(enterprise);
    } else if (enterprise.address == null) {
      await MySqlHelpers.performDeleteAddress(
          connection: connection, address: previous.address!);
    } else {
      await MySqlHelpers.performUpdateAddress(
          connection: connection,
          address: enterprise.address!,
          previous: previous.address!);
    }
  }

  Future<void> _insertToEnterpriseHeadquartersAddress(
      Enterprise enterprise) async {
    if (enterprise.headquartersAddress == null) return;

    await MySqlHelpers.performInsertAddress(
        connection: connection,
        address: enterprise.headquartersAddress!,
        entityId: enterprise.id);
    await MySqlHelpers.performInsertQuery(
        connection: connection,
        tableName: 'enterprise_headquarters_addresses',
        data: {
          'enterprise_id': enterprise.id,
          'address_id': enterprise.headquartersAddress!.id
        });
  }

  Future<void> _updateToEnterpriseHeadquartersAddress(
      Enterprise enterprise, Enterprise previous) async {
    final toUpdate = enterprise.getDifference(previous);
    if (!toUpdate.contains('headquarters_address')) return;

    if (previous.headquartersAddress == null) {
      await _insertToEnterpriseHeadquartersAddress(enterprise);
    } else if (enterprise.headquartersAddress == null) {
      await MySqlHelpers.performDeleteAddress(
          connection: connection, address: previous.headquartersAddress!);
    } else {
      await MySqlHelpers.performUpdateAddress(
          connection: connection,
          address: enterprise.headquartersAddress!,
          previous: previous.headquartersAddress!);
    }
  }

  Future<void> _insertToEnterprisePhoneNumber(Enterprise enterprise) async {
    if (enterprise.phone == null) return;

    await MySqlHelpers.performInsertPhoneNumber(
        connection: connection,
        phoneNumber: enterprise.phone!,
        entityId: enterprise.id);
    await MySqlHelpers.performInsertQuery(
        connection: connection,
        tableName: 'enterprise_phone_numbers',
        data: {
          'enterprise_id': enterprise.id,
          'phone_number_id': enterprise.phone!.id
        });
  }

  Future<void> _updateToEnterprisePhoneNumber(
      Enterprise enterprise, Enterprise previous) async {
    final toUpdate = enterprise.getDifference(previous);
    if (!toUpdate.contains('phone')) return;

    if (previous.phone == null) {
      await _insertToEnterprisePhoneNumber(enterprise);
    } else if (enterprise.phone == null) {
      await MySqlHelpers.performDeletePhoneNumber(
          connection: connection, phoneNumber: previous.phone!);
    } else {
      await MySqlHelpers.performUpdatePhoneNumber(
          connection: connection,
          phoneNumber: enterprise.phone!,
          previous: previous.phone!);
    }
  }

  Future<void> _insertToEnterpriseFax(Enterprise enterprise) async {
    if (enterprise.fax == null) return;

    await MySqlHelpers.performInsertPhoneNumber(
        connection: connection,
        phoneNumber: enterprise.fax!,
        entityId: enterprise.id);
    await MySqlHelpers.performInsertQuery(
        connection: connection,
        tableName: 'enterprise_fax_numbers',
        data: {
          'enterprise_id': enterprise.id,
          'fax_number_id': enterprise.fax!.id
        });
  }

  Future<void> _updateToEnterpriseFax(
      Enterprise enterprise, Enterprise previous) async {
    final toUpdate = enterprise.getDifference(previous);
    if (!toUpdate.contains('fax')) return;

    if (previous.fax == null) {
      await _insertToEnterpriseFax(enterprise);
    } else if (enterprise.fax == null) {
      await MySqlHelpers.performDeletePhoneNumber(
          connection: connection, phoneNumber: previous.fax!);
    } else {
      await MySqlHelpers.performUpdatePhoneNumber(
          connection: connection,
          phoneNumber: enterprise.fax!,
          previous: previous.fax!);
    }
  }

  @override
  Future<void> _putEnterprise({
    required Enterprise enterprise,
    required Enterprise? previous,
    required DatabaseUser user,
    required InternshipsRepository internshipsRepository,
  }) async {
    if (previous == null) {
      await _insertToEnterprises(enterprise);
    } else {
      await _updateToEnterprises(enterprise, previous);
    }

    final toWait = <Future>[];
    if (previous == null) {
      toWait.add(_insertToEnterprisesActivityTypes(enterprise));
      toWait.add(_insertToEnterprisesJobs(enterprise));
      toWait.add(_insertToContact(enterprise));
      toWait.add(_insertToEnterpriseAddress(enterprise));
      toWait.add(_insertToEnterpriseHeadquartersAddress(enterprise));
      toWait.add(_insertToEnterprisePhoneNumber(enterprise));
      toWait.add(_insertToEnterpriseFax(enterprise));
    } else {
      toWait.add(_updateToEnterprisesActivityTypes(enterprise, previous));
      toWait.add(_updateToEnterprisesJobs(enterprise, previous,
          user: user, internshipsRepository: internshipsRepository));
      toWait.add(_updateToContact(enterprise, previous));
      toWait.add(_updateToEnterpriseAddress(enterprise, previous));
      toWait.add(_updateToEnterpriseHeadquartersAddress(enterprise, previous));
      toWait.add(_updateToEnterprisePhoneNumber(enterprise, previous));
      toWait.add(_updateToEnterpriseFax(enterprise, previous));
    }
    await Future.wait(toWait);
  }

  Future<void> _deleteInternshipsFromJob(
    String jobId, {
    required DatabaseUser user,
    required InternshipsRepository internshipsRepository,
  }) async {
    final internships = await MySqlHelpers.performSelectQuery(
        connection: connection,
        user: user,
        tableName: 'internships',
        filters: {'job_id': jobId.serialize()}..addAll({
            'school_board_id': user.schoolBoardId ?? '',
          }));

    final toWait = <Future>[];
    for (final internship in internships) {
      toWait.add(
          internshipsRepository.deleteById(id: internship['id'], user: user));
    }
    await Future.wait(toWait);
  }

  @override
  Future<String?> _deleteEnterprise({
    required String id,
    required DatabaseUser user,
    required InternshipsRepository? internshipsRepository,
  }) async {
    try {
      final enterprise = await _getEnterpriseById(id: id, user: user);

      if (enterprise?.jobs != null) {
        if (internshipsRepository == null) {
          _logger.severe(
              'Cannot delete an enterprise with jobs without an internships repository');
          throw InvalidRequestException(
              'Cannot delete an enterprise with jobs without an internships repository');
        }
        for (final job in enterprise!.jobs) {
          await _deleteInternshipsFromJob(job.id,
              user: user, internshipsRepository: internshipsRepository);
        }
      }

      await MySqlHelpers.performDeleteQuery(
        connection: connection,
        tableName: 'enterprise_addresses',
        filters: {'enterprise_id': id},
      );
      await MySqlHelpers.performDeleteQuery(
        connection: connection,
        tableName: 'enterprise_headquarters_addresses',
        filters: {'enterprise_id': id},
      );
      await MySqlHelpers.performDeleteQuery(
        connection: connection,
        tableName: 'entities',
        filters: {'shared_id': id},
      );

      if (enterprise?.address?.id != null) {
        await MySqlHelpers.performDeleteQuery(
          connection: connection,
          tableName: 'addresses',
          filters: {'entity_id': enterprise!.address!.id},
        );
      }
      if (enterprise?.headquartersAddress?.id != null) {
        await MySqlHelpers.performDeleteQuery(
          connection: connection,
          tableName: 'addresses',
          filters: {'entity_id': enterprise!.headquartersAddress!.id},
        );
      }
      if (enterprise?.phone?.id != null) {
        await MySqlHelpers.performDeleteQuery(
          connection: connection,
          tableName: 'phone_numbers',
          filters: {'entity_id': enterprise!.phone!.id},
        );
      }
      if (enterprise?.fax?.id != null) {
        await MySqlHelpers.performDeleteQuery(
          connection: connection,
          tableName: 'phone_numbers',
          filters: {'entity_id': enterprise!.fax!.id},
        );
      }

      if (enterprise?.contact.id != null) {
        await MySqlHelpers.performDeleteQuery(
          connection: connection,
          tableName: 'entities',
          filters: {'shared_id': enterprise!.contact.id},
        );
      }

      return id;
    } catch (e) {
      throw InvalidRequestException(
          'Unable to delete the enterprise with id $id. Is there any internships associted with this enterprise? $e');
    }
  }
  // coverage:ignore-end
}

class EnterprisesRepositoryMock extends EnterprisesRepository {
  // Simulate a database with a map
  final _dummyDatabase = {
    '0': Enterprise(
      id: '0',
      schoolBoardId: '0',
      name: 'My First Enterprise',
      jobs: JobList(),
      activityTypes: {ActivityTypes.magasin, ActivityTypes.entreposage},
      recruiterId: 'Recruiter 1',
      contact: Person.empty,
      address: Address.empty,
      phone: PhoneNumber.fromString('123-456-7890'),
      fax: PhoneNumber.fromString('098-765-4321'),
    ),
    '1': Enterprise(
      id: '1',
      schoolBoardId: '0',
      name: 'My Second Enterprise',
      jobs: JobList(),
      activityTypes: {
        ActivityTypes.magasin,
        ActivityTypes.entreposage,
        ActivityTypes.ebenisterie
      },
      recruiterId: 'Recruiter 2',
      contact: Person.empty,
      address: Address.empty,
      phone: PhoneNumber.fromString('123-456-7890'),
      fax: PhoneNumber.fromString('098-765-4321'),
    )
  };

  @override
  Future<Map<String, Enterprise>> _getAllEnterprises({
    required DatabaseUser user,
  }) async =>
      _dummyDatabase;

  @override
  Future<Enterprise?> _getEnterpriseById({
    required String id,
    required DatabaseUser user,
  }) async =>
      _dummyDatabase[id];

  @override
  Future<void> _putEnterprise({
    required Enterprise enterprise,
    required Enterprise? previous,
    required DatabaseUser user,
    required InternshipsRepository internshipsRepository,
  }) async =>
      _dummyDatabase[enterprise.id] = enterprise;

  @override
  Future<String?> _deleteEnterprise(
      {required String id,
      required DatabaseUser user,
      required InternshipsRepository? internshipsRepository}) async {
    if (_dummyDatabase.containsKey(id)) {
      _dummyDatabase.remove(id);
      return id;
    }
    return null;
  }
}
