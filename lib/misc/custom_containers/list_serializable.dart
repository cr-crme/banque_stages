import '../exceptions.dart';
import 'item_serializable.dart';

/// An iterable [List] that is made to handle [ItemSerializable].
///
/// It allows to serialize and deserialize the whole list easily with [serialize] and [ListSerializable.fromSerialized].
///
/// Written by: @pariterre and @Guibi1
abstract class ListSerializable<T> extends Iterable<T> {
  /// Creates an empty [ListSerializable].
  ListSerializable();

  /// Creates a [ListSerializable] from a map of serialized items.
  ListSerializable.fromSerialized(Map<String, dynamic> map) {
    deserialize(map);
  }

  /// Serializes all of its items into a single map, separted by their id.
  Map<String, dynamic> serialize() {
    final serializedItem = <String, dynamic>{};
    for (final element in _items as List<ItemSerializable>) {
      serializedItem[element.id] = element.serialize();
    }
    return serializedItem;
  }

  /// Returns a new [T] from the provided serialized data.
  T deserializeItem(data);

  /// Deserializes a map of items with the help of [deserializeItem].
  void deserialize(Map<String, dynamic> map) {
    _items.clear();
    for (var element in map.values) {
      _items.add(deserializeItem(element));
    }
  }

  /// Adds [item] to the end of this list, extending the length by one.
  void add(T item) {
    _items.add(item);
  }

  /// Updates the value of [item].
  ///
  /// This only works when the ids of the new and old value are identical.
  void replace(T item) {
    _items[_getIndex(item)] = item;
  }

  @override
  bool contains(Object? element) {
    if (element is String) {
      return _items.any((item) => (item as ItemSerializable).id == element);
    } else {
      return _items.contains(element);
    }
  }

  /// Sets the value of the item to [item] at the specified location.
  ///
  /// This method accepts an `int` as an index, an `String` as an id, and an [ItemSerializable] as the item to remove.
  operator []=(value, T item) {
    _items[_getIndex(value)] = item;
  }

  /// Returns the item at the location specified by [value].
  ///
  /// This method accepts an `int` as an index, an `String` as an id, and an [ItemSerializable] as the item to remove.
  T operator [](value) {
    return _items[_getIndex(value)];
  }

  /// Removes a single item from the list.
  ///
  /// This method accepts an `int` as an index, an `String` as an id, and an [ItemSerializable] as the item to remove.
  void remove(value) {
    _items.removeAt(_getIndex(value));
  }

  /// Removes all objects from this list; the length of the list becomes zero.
  void clear() {
    _items.clear();
  }

  /// The first index in the list that satisfies the provided [test].
  ///
  /// Searches the list from index [start] to the end of the list.
  /// The first time an object `o` is encountered so that `test(o)` is true,
  /// the index of `o` is returned.
  int indexWhere(bool Function(T element) test, [int start = 0]) {
    return _items.indexWhere(test, start);
  }

  /// Returns the index of [value] using different methods depending of its type.
  int _getIndex(value) {
    if (value is int) {
      return value;
    } else if (value is String) {
      return _items
          .indexWhere((element) => (element as ItemSerializable).id == value);
    } else if (value is ItemSerializable) {
      return _getIndex(value.id);
    } else {
      throw const TypeException(
          'Wrong type for getting an element of the list.');
    }
  }

  final List<T> _items = [];

  @override
  Iterator<T> get iterator => _items.iterator;
}
