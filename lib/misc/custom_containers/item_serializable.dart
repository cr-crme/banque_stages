import 'package:flutter/foundation.dart';
import 'package:nanoid/nanoid.dart';

abstract class ItemSerializable {
  /// Creates an [ItemSerializable] with the provided [id], or a randomly generated one.
  ItemSerializable({String? id}) : id = id ?? nanoid();

  /// Creates an [ItemSerializable] from a map of serialized items.
  ItemSerializable.fromSerialized(Map<String, dynamic> map)
      : id = map['id'] ?? nanoid();

  /// Must be overriten to serialise additionnal information.
  Map<String, dynamic> serializedMap();

  /// Serializes the current object.
  @nonVirtual
  Map<String, dynamic> serialize() {
    var out = serializedMap();
    out['id'] = id;
    return out;
  }

  /// Deserializes the current object
  ItemSerializable deserializeItem(Map<String, dynamic> map);

  /// The global id of each instances.
  final String id;
}
