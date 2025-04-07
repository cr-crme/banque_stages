import 'package:common/exceptions.dart';

class ConnexionRefusedException implements IntershipBankException {
  final String message;

  ConnexionRefusedException(this.message);

  @override
  String toString() => message;
}

class InvalidRequestTypeException implements IntershipBankException {
  final String message;

  InvalidRequestTypeException(this.message);

  @override
  String toString() => message;
}

class MissingFieldException implements IntershipBankException {
  final String message;

  MissingFieldException(this.message);

  @override
  String toString() => message;
}

class MissingDataException implements IntershipBankException {
  final String message;

  MissingDataException(this.message);

  @override
  String toString() => message;
}

class InvalidRequestException implements IntershipBankException {
  final String message;

  InvalidRequestException(this.message);

  @override
  String toString() => message;
}
