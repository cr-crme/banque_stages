import 'package:backend/exceptions.dart';
import 'package:mysql1/mysql1.dart';

Future<Results> tryQuery(MySqlConnection connection, String query,
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
