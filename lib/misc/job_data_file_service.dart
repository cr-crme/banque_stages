import 'dart:convert';

import 'package:enhanced_containers/enhanced_containers.dart';
import 'package:flutter/services.dart';

abstract class ActivitySectorsService {
  static Future<void> initializeActivitySectorSingleton() async {
    final file = await rootBundle.loadString('assets/jobs-data.json');
    final json = jsonDecode(file) as List;

    sectors = ActivitySectorList.fromSerialized(json);
  }

  static late ActivitySectorList sectors; // Holder of the singleton

  static Specialization specialization(String id) {
    for (final sector in sectors) {
      for (final specialization in sector.specializations) {
        if (specialization.id == id) return specialization;
      }
    }
    throw 'Specialization not found';
  }
}

class ActivitySector extends NamedItemSerializable {
  ActivitySector.fromSerialized(map)
      : specializations = SpecializationList.fromSerialized(map['s']),
        super.fromSerialized(map);

  @override
  Map<String, dynamic> serializedMap() =>
      super.serializedMap()..addAll({'s': specializations.serialize()});

  final SpecializationList specializations;
}

class ActivitySectorList extends _NamedItemSerializableList<ActivitySector> {
  ActivitySectorList._();

  factory ActivitySectorList.fromSerialized(map) {
    final out = ActivitySectorList._();
    for (final activity in map) {
      out.add(ActivitySector.fromSerialized(activity));
    }
    return out;
  }

  @override
  ActivitySector deserializeItem(data) => ActivitySector.fromSerialized(map);
}

class Specialization extends NamedItemSerializable {
  ActivitySector? _sector;
  ActivitySector get sector {
    _sector ??= _findSector(id);
    return _sector!;
  }

  Specialization.fromSerialized(map)
      : skills = SkillList.fromSerialized(map['s']),
        questions = List.from(map['q']),
        super.fromSerialized(map);

  @override
  Map<String, dynamic> serializedMap() =>
      super.serializedMap()..addAll({'s': skills.serialize(), 'q': questions});

  static ActivitySector _findSector(String id) {
    for (final sector in ActivitySectorsService.sectors) {
      for (final specialization in sector.specializations) {
        if (specialization.id == id) return sector;
      }
    }
    throw 'Sector could not be found for current specialization';
  }

  final SkillList skills;
  final List<String> questions;
}

class SpecializationList extends _NamedItemSerializableList<Specialization> {
  SpecializationList._();

  factory SpecializationList.fromSerialized(map) {
    final out = SpecializationList._();
    for (final specialization in map) {
      out.add(Specialization.fromSerialized(specialization));
    }
    return out;
  }

  @override
  Specialization deserializeItem(data) => Specialization.fromSerialized(map);
}

class Skill extends NamedItemSerializable {
  Skill.fromSerialized(map)
      : complexity = map['x'],
        criteria = List.from(map['c'], growable: false),
        tasks = List.from(map['t'], growable: false),
        risks = List.from(map['r'], growable: false),
        super.fromSerialized(map);

  @override
  Map<String, dynamic> serializedMap() => super.serializedMap()
    ..addAll({'x': complexity, 'c': criteria, 't': tasks, 'r': risks});

  final String complexity;
  final List<String> criteria;
  final List<String> tasks;
  final List<String> risks;
}

class SkillList extends _NamedItemSerializableList<Skill> {
  SkillList._();

  factory SkillList.fromSerialized(map) {
    final out = SkillList._();
    for (final skill in map) {
      out.add(Skill.fromSerialized(skill));
    }
    return out;
  }

  @override
  Skill deserializeItem(data) => Skill.fromSerialized(map);
}

abstract class NamedItemSerializable extends ItemSerializable {
  final String name;

  NamedItemSerializable.fromSerialized(map)
      : name = map['n'],
        super.fromSerialized(map);

  @override
  Map<String, dynamic> serializedMap() => {'id': id, 'n': name};

  String get idWithName => '${int.tryParse(id)} - $name';
}

abstract class _NamedItemSerializableList<T extends NamedItemSerializable>
    extends ListSerializable<T> {
  Iterable<T> whereId({required String id}) => where(
        (e) => e.idWithName.contains(id),
      );
}
