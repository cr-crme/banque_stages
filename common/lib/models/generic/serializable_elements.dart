import 'package:enhanced_containers_foundation/enhanced_containers_foundation.dart';

extension ListExt<T> on List<T> {
  List serialize() {
    return map((e) {
      if (e is String) {
        return e.serialize();
      } else if (e is int) {
        return e.serialize();
      } else if (e is DateTime) {
        return e.serialize();
      } else if (e is ItemSerializable) {
        return e.serialize();
      }
    }).toList();
  }

  static List<S>? from<S>(List? elements,
      {required S Function(dynamic) deserializer}) {
    if (elements == null) return [];
    return elements.map((e) => deserializer(e)).toList();
  }
}

extension StringExt on String {
  String serialize() => this;

  static String? from(element) => element?.toString();
}

extension IntExt on int {
  int serialize() => this;

  static int? from(element) => int.tryParse(element);
}

extension DateTimeExt on DateTime {
  int serialize() => millisecondsSinceEpoch;

  static DateTime? from(element) {
    if (element == null) return null;
    try {
      return DateTime.fromMillisecondsSinceEpoch(element as int);
    } catch (e) {
      return null;
    }
  }
}
