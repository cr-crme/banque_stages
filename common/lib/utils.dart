import 'package:enhanced_containers_foundation/enhanced_containers_foundation.dart';

bool areListsEqual<T>(List<T> list1, List<T> list2) {
  if (list1.length != list2.length) return false;

  for (int i = 0; i < list1.length; i++) {
    if (list1[i] is List) {
      if (areListsNotEqual(list1[i] as List, list2[i] as List)) return false;
    } else if (list1[i] is Map) {
      if (areMapsNotEqual(list1[i] as Map, list2[i] as Map)) return false;
    } else {
      if (list1[i] != list2[i]) return false;
    }
  }

  return true;
}

bool areListsNotEqual<T>(List<T> list1, List<T> list2) {
  return !areListsEqual(list1, list2);
}

bool areSetsEqual<T>(Set<T>? a, Set<T>? b) {
  if (a == null) {
    return b == null;
  }
  if (b == null || a.length != b.length) {
    return false;
  }
  if (identical(a, b)) {
    return true;
  }
  for (final T element in a) {
    if (!b.contains(element)) return false;
  }
  return true;
}

bool areSetsNotEqual<T>(Set<T>? a, Set<T>? b) {
  return !areSetsEqual(a, b);
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
    if (!b.containsKey(key)) return false;
    if (a[key] is List) {
      if (areListsNotEqual(a[key] as List, b[key] as List? ?? [])) return false;
    } else if (a[key] is Map) {
      if (areMapsNotEqual(a[key] as Map, b[key] as Map? ?? {})) return false;
    } else if (a[key] != b[key]) {
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

    final serializedThis = serializedMap();
    final serializedOther = other.serializedMap();

    final diff = <String>[];
    for (var key in serializedThis.keys) {
      if (serializedThis[key] is List) {
        if (areListsNotEqual(serializedThis[key], serializedOther[key])) {
          diff.add(key);
        }
      } else if (serializedThis[key] is Map) {
        if (areMapsNotEqual(serializedThis[key], serializedOther[key])) {
          diff.add(key);
        }
      } else {
        if (serializedThis[key] != serializedOther[key]) {
          diff.add(key);
        }
      }
    }
    return diff;
  }

  Map<String, dynamic> serializeWithFields(List<String>? fields) {
    final serialized = serialize();
    if (fields != null) {
      serialized.removeWhere((key, value) =>
          key != 'id' && key != 'version' && !fields.contains(key));
    }

    return serialized;
  }
}
