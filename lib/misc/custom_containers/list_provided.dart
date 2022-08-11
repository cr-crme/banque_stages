import 'package:flutter/foundation.dart';

import 'list_serializable.dart';

/// A [ListSerializable] that implements [ChangeNotifier] to notify every modifications made to its content.
///
/// Written by: @pariterre and @Guibi1
abstract class ListProvided<T> extends ListSerializable<T> with ChangeNotifier {
  /// Creates an empty [ListProvided].
  ListProvided() : super();

  /// Creates a [ListProvided] from a map of serialized items.
  ListProvided.fromSerialized(Map<String, dynamic> map)
      : super.fromSerialized(map);

  @override
  void add(T item, {bool notify = true}) {
    super.add(item);
    if (notify) notifyListeners();
  }

  @override
  void replace(T item, {bool notify = true}) {
    super.replace(item);
    if (notify) notifyListeners();
  }

  @override
  operator []=(value, T item) {
    super[value] = item;
    notifyListeners();
  }

  @override
  void remove(value, {bool notify = true}) {
    super.remove(value);
    if (notify) notifyListeners();
  }

  @override
  void clear({bool notify = true}) {
    super.clear();
    if (notify) notifyListeners();
  }
}
