import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:enhanced_containers/enhanced_containers.dart';
import 'package:flutter/services.dart';

abstract class JobDataFileService {
  static Future<void> loadData() async {
    final file = await rootBundle.loadString('assets/jobs-data.json');
    final json = jsonDecode(file) as List;

    sectors = ActivitySectorList.fromSerialized(json);
  }

  static ActivitySectorList sectors = ActivitySectorList._();
  static ActivitySector? sectorFromId(String id) =>
      sectors.firstWhereOrNull((sector) => sector.id == id);

  // static List<Specialization> get specializations {
  //   List<Specialization> out = [];
  //   for (final sector in sectors) {
  //     for (final specialization in sector.specializations) {
  //       // If there is no risk, it does not mean this specialization
  //       // is risk-free, it means it was not evaluated
  //       var hasRisks = false;
  //       for (final skill in specialization.skills) {
  //         hasRisks = skill.risks.isNotEmpty;
  //         if (hasRisks) break;
  //       }
  //       if (hasRisks) out.add(specialization);
  //     }
  //   }
  //   return out;
  // }

  static Specialization? specializationFromId(String id) {
    for (final sector in JobDataFileService.sectors) {
      // for (final specialization in sector.specializations) {
      //   if (specialization.id == id) return specialization;
      // }
    }
    return null;
  }
}

abstract class _NamedItemSerializable extends ItemSerializable {
  final String name;

  _NamedItemSerializable.fromSerialized(map)
      : name = map['n'],
        super.fromSerialized(map);

  @override
  Map<String, dynamic> serializedMap() => {'id': id, 'n': name};

  String get idWithName => '${int.tryParse(id)} - $name';
}

abstract class _NamedItemSerializableList<T extends _NamedItemSerializable>
    extends ListSerializable<T> {
  Iterable<T> whereId({required String id}) => where(
        (e) => e.idWithName.contains(id),
      );
}

class ActivitySector extends _NamedItemSerializable {
  ActivitySector.fromSerialized(map)
      : specializations = SpecializationList.fromSerialized(map['s']),
        super.fromSerialized(map) {}

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

class Specialization extends _NamedItemSerializable {
  Specialization.fromSerialized(map)
      : skills = SkillList.fromSerialized(map['s']),
        questions = List.from(map['q']),
        super.fromSerialized(map);

  @override
  Map<String, dynamic> serializedMap() =>
      super.serializedMap()..addAll({'s': skills.serialize(), 'q': questions});

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

class Skill extends _NamedItemSerializable {
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
