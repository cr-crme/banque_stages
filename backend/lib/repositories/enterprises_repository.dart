import 'package:backend/repositories/mysql_repository_helpers.dart';
import 'package:backend/repositories/repository_abstract.dart';
import 'package:backend/utils/exceptions.dart';
import 'package:common/models/enterprise.dart';
import 'package:common/models/person.dart';
import 'package:mysql1/mysql1.dart';

abstract class EnterprisesRepository implements RepositoryAbstract {
  @override
  Future<Map<String, dynamic>> getAll() async {
    final enterprises = await _getAllEnterprises();
    return enterprises.map((key, value) => MapEntry(key, value.serialize()));
  }

  @override
  Future<Map<String, dynamic>> getById({required String id}) async {
    final enterprise = await _getEnterpriseById(id: id);
    if (enterprise == null) throw MissingDataException('Enterprise not found');

    return enterprise.serialize();
  }

  @override
  Future<void> putAll({required Map<String, dynamic> data}) async =>
      throw InvalidRequestException('Enterprises must be created individually');

  @override
  Future<void> putById(
      {required String id, required Map<String, dynamic> data}) async {
    // Update if exists, insert if not
    final previous = await _getEnterpriseById(id: id);

    final newEnterprise = previous?.copyWithData(data) ??
        Enterprise.fromSerialized(<String, dynamic>{'id': id}..addAll(data));

    await _putEnterprise(enterprise: newEnterprise, previous: previous);
  }

  Future<Map<String, Enterprise>> _getAllEnterprises();

  Future<Enterprise?> _getEnterpriseById({required String id});

  Future<void> _putEnterprise(
      {required Enterprise enterprise, required Enterprise? previous});
}

class MySqlEnterprisesRepository extends EnterprisesRepository {
  // coverage:ignore-start
  final MySqlConnection connection;
  MySqlEnterprisesRepository({required this.connection});

  @override
  Future<Map<String, Enterprise>> _getAllEnterprises(
      {String? enterpriseId}) async {
    final results = await performSelectQuery(
      connection: connection,
      tableName: 'enterprises',
      id: enterpriseId,
    );

    return {
      for (final enterprise in results)
        enterprise['id'].toString(): Enterprise(
          id: enterprise['id'].toString(),
          name: enterprise['name'],
          recruiterId: enterprise['recruiter_id'],
          contact: Person.fromSerialized(enterprise['contact'] ?? {}),
        )
    };
  }

  @override
  Future<Enterprise?> _getEnterpriseById({required String id}) async =>
      (await _getAllEnterprises(enterpriseId: id))[id];

  @override
  Future<void> _putEnterprise(
          {required Enterprise enterprise,
          required Enterprise? previous}) async =>
      previous == null
          ? await _putNewEnterprise(enterprise)
          : await _putExistingEnterprise(enterprise, previous);

  Future<void> _putNewEnterprise(Enterprise enterprise) async {
    try {
      // Insert the enterprise
      await performInsertQuery(
          connection: connection,
          tableName: 'entities',
          data: {'shared_id': enterprise.id});
      await performInsertQuery(
          connection: connection,
          tableName: 'enterprises',
          data: {
            'id': enterprise.id,
            'name': enterprise.name,
            'recruiter_id': enterprise.recruiterId,
          });
      await performInsertPerson(
          connection: connection, person: enterprise.contact);
      await performInsertQuery(
          connection: connection,
          tableName: 'enterprise_contacts',
          data: {
            'enterprise_id': enterprise.id,
            'contact_id': enterprise.contact.id
          });
    } catch (e) {
      try {
        await performDeleteQuery(
            connection: connection, tableName: 'entities', id: enterprise.id);
      } catch (e) {
        // Do nothing
      }

      rethrow;
    }
  }

  Future<void> _putExistingEnterprise(
      Enterprise enterprise, Enterprise previous) async {
    final Map<String, dynamic> toUpdate = {};
    if (enterprise.name != previous.name) toUpdate['name'] = enterprise.name;

    // Update if required
    if (toUpdate.isNotEmpty) {
      await performUpdateQuery(
          connection: connection,
          tableName: 'enterprises',
          id: enterprise.id,
          data: toUpdate);
    }
  }
  // coverage:ignore-end
}

class EnterprisesRepositoryMock extends EnterprisesRepository {
  // Simulate a database with a map
  final _dummyDatabase = {
    '0': Enterprise(
      id: '0',
      name: 'My First Enterprise',
      recruiterId: 'Recruiter 1',
      contact: Person.empty,
    ),
    '1': Enterprise(
      id: '1',
      name: 'My Second Enterprise',
      recruiterId: 'Recruiter 2',
      contact: Person.empty,
    )
  };

  @override
  Future<Map<String, Enterprise>> _getAllEnterprises() async => _dummyDatabase;

  @override
  Future<Enterprise?> _getEnterpriseById({required String id}) async =>
      _dummyDatabase[id];

  @override
  Future<void> _putEnterprise(
          {required Enterprise enterprise,
          required Enterprise? previous}) async =>
      _dummyDatabase[enterprise.id] = enterprise;
}
