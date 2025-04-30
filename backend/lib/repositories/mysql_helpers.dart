import 'dart:convert';

import 'package:backend/utils/exceptions.dart';
import 'package:common/models/generic/address.dart';
import 'package:common/models/generic/phone_number.dart';
import 'package:common/models/persons/person.dart';
import 'package:mysql1/mysql1.dart';

final _protectedTables = [
  'students',
  'teachers',
  'enterprises',
  'internships',
];

class MySqlHelpers {
// coverage:ignore-start
  static Future<Results> tryQuery(MySqlConnection connection, String query,
      [List<Object?>? values]) async {
    try {
      return await connection.query(query, values);
    } on MySqlException catch (e) {
      throw DatabaseFailureException(
          'Database failure: ${e.message} (${e.errorNumber}). '
          'This should not happen, please contact the administrator of the database.');
    } catch (e) {
      throw DatabaseFailureException('Database failure: $e. '
          'This should not happen, please contact the administrator of the database.');
    }
  }
// coverage:ignore-end

// coverage:ignore-start
  static Future<List<Map<String, dynamic>>> performSelectQuery({
    required MySqlConnection connection,
    required String tableName,
    Map<String, String>? filters,
    List<MySqlTableAccessor>? subqueries,
  }) async {
    if (_protectedTables.contains(tableName) &&
        !(filters?.containsKey('school_board_id') ?? false)) {
      throw InvalidRequestException(
          'You cannot access a protected table $tableName without a school board id.');
    }

    final results = await tryQuery(
        connection,
        MySqlHelpers.craftSelectQuery(
            tableName: tableName, filters: filters, sublists: subqueries),
        [...filters?.values ?? []]);

    final List<Map<String, dynamic>> list = [];
    for (final row in results) {
      final Map<String, dynamic> map = row.fields;
      if (subqueries == null || subqueries.isEmpty) {
        list.add(map);
        continue;
      }
      for (final sublist in subqueries) {
        final tableRow = map[sublist.tableName];
        if (tableRow == null) continue;
        map[sublist.tableName] = jsonDecode(tableRow);
      }
      list.add(map);
    }

    return list;
  }
// coverage:ignore-end

  static String craftSelectQuery({
    required String tableName,
    Map<String, String>? filters,
    List<MySqlTableAccessor>? sublists,
  }) {
    final filtersAsString = (filters == null || filters.isEmpty)
        ? ''
        : 'WHERE ${filters.keys.map((e) => 't.$e = ?').join(' AND ')}';

    return '''SELECT t.*${sublists == null || sublists.isEmpty ? '' : ','} 
      ${sublists?.map((e) => e._craft(mainTableAlias: 't')).join(',') ?? ''}
    FROM $tableName t $filtersAsString
    ''';
  }

// coverage:ignore-start
  static Future<Results> performInsertQuery({
    required MySqlConnection connection,
    required String tableName,
    required Map<String, dynamic> data,
  }) async =>
      await tryQuery(connection,
          craftInsertQuery(tableName: tableName, data: data), [...data.values]);
// coverage:ignore-end

  static String craftInsertQuery({
    required String tableName,
    required Map<String, dynamic> data,
  }) =>
      '''INSERT INTO $tableName (${data.keys.join(', ')})
       VALUES (${data.keys.map((e) => '?').join(', ')})''';

// coverage:ignore-start
  static Future<Results> performUpdateQuery({
    required MySqlConnection connection,
    required String tableName,
    Map<String, String>? filters,
    required Map<String, dynamic> data,
  }) async =>
      await tryQuery(
          connection,
          craftUpdateQuery(tableName: tableName, filters: filters, data: data),
          [...data.values, ...filters?.values ?? []]);
// coverage:ignore-end

  static String craftUpdateQuery({
    required String tableName,
    required Map<String, String>? filters,
    required Map<String, dynamic> data,
  }) {
    final filtersAsString = filters == null
        ? ''
        : 'WHERE ${filters.keys.map((e) => '$e = ?').join(' AND ')}';

    return '''UPDATE $tableName SET ${data.keys.join(' = ?, ')} = ?
       $filtersAsString''';
  }

// coverage:ignore-start
  static Future<Results> performDeleteQuery({
    required MySqlConnection connection,
    required String tableName,
    Map<String, String>? filters,
  }) async =>
      await tryQuery(
          connection,
          craftDeleteQuery(tableName: tableName, filters: filters),
          filters?.values.toList() ?? []);
// coverage:ignore-end

  static String craftDeleteQuery({
    required String tableName,
    Map<String, String>? filters,
  }) {
    final filtersAsString = filters == null
        ? ''
        : 'WHERE ${filters.keys.map((e) => '$e = ?').join(' AND ')}';

    return '''DELETE FROM $tableName
       $filtersAsString''';
  }

// coverage:ignore-start
  ///
  /// Specific helpers
  static Future<void> performInsertPerson(
      {required MySqlConnection connection, required Person person}) async {
    await performInsertQuery(
        connection: connection,
        tableName: 'entities',
        data: {'shared_id': person.id});
    await performInsertQuery(
        connection: connection,
        tableName: 'persons',
        data: {
          'id': person.id,
          'first_name': person.firstName,
          'middle_name': person.middleName,
          'last_name': person.lastName,
          'date_birthday': person.dateBirth?.toIso8601String().substring(0, 10),
          'email': person.email,
        });
    await performInsertPhoneNumber(
        connection: connection, phoneNumber: person.phone, entityId: person.id);
    await performInsertAddress(
        connection: connection, address: person.address, entityId: person.id);
  }

  static Future<void> performUpdatePerson(
      {required MySqlConnection connection,
      required Person person,
      required Person previous}) async {
    // Update the person if needed
    final toUpdate = <String, dynamic>{};
    if (person.firstName != previous.firstName) {
      toUpdate['first_name'] = person.firstName;
    }
    if (person.middleName != previous.middleName) {
      toUpdate['middle_name'] = person.middleName;
    }
    if (person.lastName != previous.lastName) {
      toUpdate['last_name'] = person.lastName;
    }
    if (person.dateBirth != previous.dateBirth) {
      toUpdate['date_birthday'] =
          person.dateBirth?.toIso8601String().substring(0, 10);
    }
    if (person.email != previous.email) {
      toUpdate['email'] = person.email;
    }
    if (toUpdate.isNotEmpty) {
      await MySqlHelpers.performUpdateQuery(
          connection: connection,
          tableName: 'persons',
          filters: {'id': person.id},
          data: toUpdate);
    }

    // Update the phone number if needed
    if (person.phone != previous.phone) {
      // Update the phone number
      await MySqlHelpers.performUpdateQuery(
          connection: connection,
          tableName: 'phone_numbers',
          filters: {'id': person.phone.id},
          data: {'phone_number': person.phone.toString()});
    }

    // Update the address if needed
    if (person.address != previous.address) {
      // Update the address
      await MySqlHelpers.performUpdateQuery(
          connection: connection,
          tableName: 'addresses',
          filters: {
            'id': person.address.id
          },
          data: {
            'civic': person.address.civicNumber,
            'street': person.address.street,
            'apartment': person.address.apartment,
            'city': person.address.city,
            'postal_code': person.address.postalCode
          });
    }
  }

  static Future<void> performInsertPhoneNumber(
      {required MySqlConnection connection,
      required PhoneNumber phoneNumber,
      required String entityId}) async {
    await performInsertQuery(
        connection: connection,
        tableName: 'phone_numbers',
        data: {
          'id': phoneNumber.id,
          'entity_id': entityId,
          'phone_number': phoneNumber.toString()
        });
  }

  static Future<void> performInsertAddress(
      {required MySqlConnection connection,
      required Address address,
      required String entityId}) async {
    await performInsertQuery(
        connection: connection,
        tableName: 'addresses',
        data: {
          'id': address.id,
          'entity_id': entityId,
          'civic': address.civicNumber,
          'street': address.street,
          'apartment': address.apartment,
          'city': address.city,
          'postal_code': address.postalCode
        });
  }
// coverage:ignore-end
}

abstract class MySqlTableAccessor {
  String get tableName;
  String get tableIdName;

  String _craft({required String mainTableAlias});

  static String _dispatchFieldsToFetch(
      {required List<String> fieldsToFetch,
      required String tableElementAlias}) {
    if (fieldsToFetch.isEmpty) throw 'Fields cannot be empty';

    String fieldsInMainList = '';
    for (final field in fieldsToFetch) {
      fieldsInMainList += '\'$field\', $tableElementAlias.$field, ';
    }
    fieldsInMainList =
        fieldsInMainList.substring(0, fieldsInMainList.length - 2);

    return fieldsInMainList;
  }
}

class MySqlJoinSubQuery implements MySqlTableAccessor {
  // Data table
  final String dataTableName;
  final String asName;
  final String dataTableIdName;
  @override
  String get tableName => asName;
  @override
  String get tableIdName => dataTableIdName;

  // Relation table
  final String relationTableName;
  final String idNameToDataTable;
  final String idNameToMainTable;

  // Main table
  final String mainTableIdName;
  final List<String> fieldsToFetch;

  MySqlJoinSubQuery({
    required this.dataTableName,
    String? asName,
    this.dataTableIdName = 'id',
    required this.relationTableName,
    required this.idNameToDataTable,
    required this.idNameToMainTable,
    this.mainTableIdName = 'id',
    required this.fieldsToFetch,
  }) : asName = asName ?? dataTableName;

  @override
  String _craft({required String mainTableAlias}) {
    return '''IFNULL((
        SELECT JSON_ARRAYAGG(
            JSON_OBJECT(
              ${MySqlTableAccessor._dispatchFieldsToFetch(fieldsToFetch: fieldsToFetch, tableElementAlias: 'st')}
            )
        )
        FROM $relationTableName idt
        JOIN $dataTableName st ON idt.$idNameToDataTable = st.$dataTableIdName
        WHERE idt.$idNameToMainTable = $mainTableAlias.$mainTableIdName
      ), JSON_ARRAY()) AS $tableName''';
  }
}

class MySqlSelectSubQuery implements MySqlTableAccessor {
  final String dataTableName;
  final String asName;
  @override
  String get tableName => asName;

  final String idNameToDataTable;
  final String idNameToMainTable;
  @override
  String get tableIdName => idNameToDataTable;

  final List<String> fieldsToFetch;

  MySqlSelectSubQuery({
    required this.dataTableName,
    String? asName,
    this.idNameToDataTable = 'id',
    this.idNameToMainTable = 'id',
    required this.fieldsToFetch,
  }) : asName = asName ?? dataTableName;

  @override
  String _craft({required String mainTableAlias}) {
    return '''IFNULL((
        SELECT JSON_ARRAYAGG(
            JSON_OBJECT(
              ${MySqlTableAccessor._dispatchFieldsToFetch(fieldsToFetch: fieldsToFetch, tableElementAlias: 'st')}
            )
        )
        FROM $dataTableName st
        WHERE st.$idNameToDataTable = $mainTableAlias.$idNameToMainTable
      ), JSON_ARRAY()) AS $tableName''';
  }
}
