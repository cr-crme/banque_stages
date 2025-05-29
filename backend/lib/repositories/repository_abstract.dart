import 'package:backend/utils/database_user.dart';
import 'package:backend/utils/exceptions.dart';

abstract class RepositoryAbstract {
  ///
  /// Get all data from the repository related to the given field.
  Future<Map<String, dynamic>> getAll({
    List<String>? fields,
    required DatabaseUser user,
  });

  ///
  /// Get data from the repository related to the given field and [id].
  /// If the data doesn't exist, a [MissingDataException] will be thrown.
  Future<Map<String, dynamic>> getById({
    required String id,
    List<String>? fields,
    required DatabaseUser user,
  });

  ///
  /// Put all data into the repository related to the given field.
  /// If the request is invalid for the field, a [InvalidRequestException] will be thrown.
  Future<void> putAll({
    required Map<String, dynamic> data,
    required DatabaseUser user,
  });

  ///
  /// Put data into the repository related to the given field and [id].
  /// If the data already exists, it will be updated. If it doesn't exist, it will be created.
  /// Returns the fields that were actually updated (if there were an existing entry).
  /// Returns all the fields if the entry was created (no fields were existing).
  Future<List<String>> putById({
    required String id,
    required Map<String, dynamic> data,
    required DatabaseUser user,
  });

  ///
  /// Delete all data from the repository related to the given field.
  Future<List<String>> deleteAll({
    required DatabaseUser user,
  });

  ///
  /// Delete data from the repository related to the given field and [id].
  /// If the data doesn't exist, a [MissingDataException] will be thrown.
  Future<String> deleteById({
    required String id,
    required DatabaseUser user,
  });
}
