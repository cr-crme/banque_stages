import 'package:backend/utils/exceptions.dart';

abstract class RepositoryAbstract {
  ///
  /// Get all data from the repository related to the given field.
  Future<Map<String, dynamic>> getAll();

  ///
  /// Get data from the repository related to the given field and [id].
  /// If the data doesn't exist, a [MissingDataException] will be thrown.
  Future<Map<String, dynamic>> getById({required String id});

  ///
  /// Put all data into the repository related to the given field.
  /// If the request is invalid for the field, a [InvalidRequestException] will be thrown.
  Future<void> putAll({required Map<String, dynamic> data});

  ///
  /// Put data into the repository related to the given field and [id].
  /// If the data already exists, it will be updated. If it doesn't exist, it will be created.
  Future<void> putById(
      {required String id, required Map<String, dynamic> data});
}
