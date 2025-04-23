import 'package:enhanced_containers_foundation/enhanced_containers_foundation.dart';

bool areListsEqual<T>(List<T> list1, List<T> list2) {
  if (list1.length != list2.length) return false;

  for (int i = 0; i < list1.length; i++) {
    if (list1[i] != list2[i]) return false;
  }

  return true;
}

bool areListsNotEqual<T>(List<T> list1, List<T> list2) {
  return !areListsEqual(list1, list2);
}

bool areMapsEqual<T, U>(Map<T, U>? a, Map<T, U>? b) {
  if (a == null) {
    return b == null;
  }
  if (b == null || a.length != b.length) {
    return false;
  }
  if (identical(a, b)) {
    return true;
  }
  for (final T key in a.keys) {
    if (!b.containsKey(key) || b[key] != a[key]) {
      return false;
    }
  }
  return true;
}

bool areMapsNotEqual<T, U>(Map<T, U>? a, Map<T, U>? b) {
  return !areMapsEqual(a, b);
}

extension IterableExtensions<T> on Iterable<T> {
  T? get firstOrNull {
    var iterator = this.iterator;
    if (iterator.moveNext()) return iterator.current;
    return null;
  }

  T? firstWhereOrNull(bool Function(T element) test) {
    for (var element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}

extension ItemSerializableExtension on ItemSerializable {
  /// Returns all the fields that contains a difference between the two objects.
  /// If the two objects are equal, an empty list is returned.
  List<String> getDifference([ItemSerializable? other]) {
    final keys = serializedMap().keys;

    // If there is no other object, all the keys are necessarily different
    if (other == null) return keys.toList();

    final diff = <String>[];
    for (var key in serializedMap().keys) {
      if (serializedMap()[key] is List) {
        if (areListsNotEqual(
            serializedMap()[key], other.serializedMap()[key])) {
          diff.add(key);
        }
      } else if (serializedMap()[key] is Map) {
        if (areMapsNotEqual(serializedMap()[key], other.serializedMap()[key])) {
          diff.add(key);
        }
      } else {
        if (serializedMap()[key] != other.serializedMap()[key]) {
          diff.add(key);
        }
      }
    }
    return diff;
  }

  Map<String, dynamic> serializeWithFields(List<String>? fields) {
    final serialized = serialize();
    if (fields != null) {
      serialized
          .removeWhere((key, value) => key != 'id' && !fields.contains(key));
    }

    return serialized;
  }
}
