class WrongVersionException implements Exception {
  final String? version;
  final String expectedVersion;

  WrongVersionException(this.version, this.expectedVersion);

  @override
  String toString() {
    return 'Wrong version: ${version ?? 'null'}, expected: $expectedVersion';
  }
}
