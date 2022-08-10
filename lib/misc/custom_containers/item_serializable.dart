import 'package:nanoid/nanoid.dart';

abstract class ItemSerializable {
  final String id;

  ItemSerializable({String? id}) : id = id ?? nanoid();

  ItemSerializable.fromSerialized(Map map) : id = map['id'] ?? nanoid();

  Map<String, dynamic> serializedMap();
  Map<String, dynamic> serialize() {
    var out = serializedMap();
    out['id'] = id;
    return out;
  }

  ItemSerializable deserializeItem(Map<String, dynamic> map);
}
