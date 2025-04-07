abstract class DatabaseException implements Exception {}

class ConnexionRefusedException implements DatabaseException {
  final String message;

  ConnexionRefusedException(this.message);

  @override
  String toString() => message;
}

class InvalidRequestTypeException implements DatabaseException {
  final String message;

  InvalidRequestTypeException(this.message);

  @override
  String toString() => message;
}

class MissingFieldException implements DatabaseException {
  final String message;

  MissingFieldException(this.message);

  @override
  String toString() => message;
}

class MissingDataException implements DatabaseException {
  final String message;

  MissingDataException(this.message);

  @override
  String toString() => message;
}

class InvalidRequestException implements DatabaseException {
  final String message;

  InvalidRequestException(this.message);

  @override
  String toString() => message;
}
