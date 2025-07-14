import 'package:common/exceptions.dart';
import 'package:common/models/generic/extended_item_serializable.dart';
import 'package:common/models/generic/serializable_elements.dart';
import 'package:common/models/school_boards/school.dart';

class SchoolBoard extends ExtendedItemSerializable {
  static final String _currentVersion = '1.0.0';
  final String name;
  final List<School> schools;
  final String cnesstNumber;

  SchoolBoard({
    super.id,
    required this.name,
    required this.schools,
    required this.cnesstNumber,
  });

  static SchoolBoard get empty =>
      SchoolBoard(name: '', schools: [], cnesstNumber: '');

  SchoolBoard.fromSerialized(super.map)
      : name = StringExt.from(map['name']) ?? 'Unnamed',
        schools = ListExt.from(
              map['schools'],
              deserializer: (e) => School.fromSerialized(e),
            ) ??
            [],
        cnesstNumber = StringExt.from(map['cnesst_number']) ?? '',
        super.fromSerialized();

  @override
  Map<String, dynamic> serializedMap() => {
        'name': name.serialize(),
        'schools': schools.serialize(),
        'cnesst_number': cnesstNumber.serialize(),
      };

  SchoolBoard copyWith({
    String? id,
    String? name,
    List<School>? schools,
    String? cnesstNumber,
  }) =>
      SchoolBoard(
        id: id ?? this.id,
        name: name ?? this.name,
        schools: schools ?? this.schools,
        cnesstNumber: cnesstNumber ?? this.cnesstNumber,
      );

  @override
  SchoolBoard copyWithData(Map<String, dynamic> data) {
    final availableFields = [
      'id',
      'name',
      'version',
      'schools',
      'cnesst_number',
    ];
    // Make sure data does not contain unrecognized fields
    if (data.keys.any((key) => !availableFields.contains(key))) {
      throw InvalidFieldException('Invalid field data detected');
    }

    final version = data['version'] ?? _currentVersion;
    if (version == null) {
      throw InvalidFieldException('Version field is required');
    } else if (version != '1.0.0') {
      throw WrongVersionException(version, _currentVersion);
    }

    return SchoolBoard(
      id: StringExt.from(data['id']) ?? id,
      name: data['name'] ?? name,
      schools: ListExt.from(
            data['schools'],
            deserializer: (e) => School.fromSerialized(e),
          ) ??
          schools,
      cnesstNumber: StringExt.from(data['cnesst_number']) ?? cnesstNumber,
    );
  }

  @override
  String toString() => name;
}
