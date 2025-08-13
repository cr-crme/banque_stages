abstract class InternshipBankException implements Exception {}

class WrongVersionException implements InternshipBankException {
  final String? version;
  final String expectedVersion;

  WrongVersionException(this.version, this.expectedVersion);

  @override
  String toString() {
    return 'Wrong version: ${version ?? 'null'}, expected: $expectedVersion';
  }
}

class InvalidFieldException implements InternshipBankException {
  final String message;

  InvalidFieldException(this.message);

  @override
  String toString() => message;
}
