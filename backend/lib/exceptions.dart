import 'package:common/exceptions.dart';

class ConnexionRefusedException implements IntershipBankException {
  final String _message;

  ConnexionRefusedException(String message) : _message = message;

  @override
  String toString() => _message;
}

class InvalidRequestTypeException implements IntershipBankException {
  final String _message;

  InvalidRequestTypeException(String message) : _message = message;

  @override
  String toString() => _message;
}

class MissingFieldException implements IntershipBankException {
  final String _message;

  MissingFieldException(String message) : _message = message;

  @override
  String toString() => _message;
}

class MissingDataException implements IntershipBankException {
  final String _message;

  MissingDataException(String message) : _message = message;

  @override
  String toString() => _message;
}

class InvalidRequestException implements IntershipBankException {
  final String _message;

  InvalidRequestException(String message) : _message = message;

  @override
  String toString() => _message;
}
