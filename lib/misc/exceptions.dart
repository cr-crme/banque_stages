class TypeException implements Exception {
  const TypeException(this.message);

  final String message;
}

class ValueException implements Exception {
  const ValueException(this.message);

  final String message;
}

class ShouldNotCall implements Exception {
  const ShouldNotCall(this.message);

  final String message;
}
