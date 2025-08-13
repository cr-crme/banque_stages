import 'package:stagess_backend/utils/database_user.dart';
import 'package:stagess_backend/utils/exceptions.dart';
import 'package:stagess_common/communication_protocol.dart';

class RepositoryResponse {
  Map<String, dynamic>? data;
  Map<RequestFields, Map<String, List<String>>>? updatedData;
  Map<RequestFields, List<String>>? deletedData;

  RepositoryResponse({
    this.data,
    this.updatedData,
    this.deletedData,
  });
}

abstract class RepositoryAbstract {
  ///
  /// Get all data from the repository related to the given field.
  Future<RepositoryResponse> getAll({
    List<String>? fields,
    required DatabaseUser user,
  });

  ///
  /// Get data from the repository related to the given field and [id].
  /// If the data doesn't exist, a [MissingDataException] will be thrown.
  Future<RepositoryResponse> getById({
    required String id,
    List<String>? fields,
    required DatabaseUser user,
  });

  ///
  /// Put data into the repository related to the given field and [id].
  /// If the data already exists, it will be updated. If it doesn't exist, it will be created.
  /// Returns the fields that were modified (if there were an existing entry).
  /// Returns all the fields if the entry was created (no fields were existing).
  Future<RepositoryResponse> putById({
    required String id,
    required Map<String, dynamic> data,
    required DatabaseUser user,
  });

  ///
  /// Delete data from the repository related to the given field and [id].
  /// If something goes wrong, a [DatabaseFailureException] will be thrown.
  Future<RepositoryResponse> deleteById({
    required String id,
    required DatabaseUser user,
  });
}
