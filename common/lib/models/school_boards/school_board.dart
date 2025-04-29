import 'package:common/exceptions.dart';
import 'package:common/models/school_boards/school.dart';
import 'package:enhanced_containers_foundation/enhanced_containers_foundation.dart';

class SchoolBoard extends ItemSerializable {
  static final String _currentVersion = '1.0.0';
  final String name;
  final List<School> _schools;
  List<School> get schools => _schools.toList(growable: false);

  SchoolBoard({
    super.id,
    required this.name,
    required List<School> schools,
  }) : _schools = schools;

  static SchoolBoard get empty =>
      SchoolBoard(name: 'Unnamed', id: null, schools: []);

  void addSchool(School school) {
    // TODO: Add a call to database
    if (_schools.any((s) => s.id == school.id)) {
      throw InvalidFieldException('School with this ID already exists');
    }
    _schools.add(school);
  }

  SchoolBoard.fromSerialized(super.map)
      : name = map['name'] ?? 'Unnamed',
        _schools = (map['schools'] as List<dynamic>?)
                ?.map((e) => School.fromSerialized(e))
                .toList() ??
            [],
        super.fromSerialized();

  @override
  Map<String, dynamic> serializedMap() =>
      {'name': name, 'schools': _schools.map((e) => e.serialize()).toList()};

  SchoolBoard copyWith({
    String? id,
    String? name,
    List<School>? schools,
  }) =>
      SchoolBoard(
        id: id ?? this.id,
        name: name ?? this.name,
        schools: schools ?? _schools,
      );

  SchoolBoard copyWithData(Map<String, dynamic> data) {
    final availableFields = [
      'id',
      'name',
      'version',
      'schools',
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
      id: data['id']?.toString() ?? id,
      name: data['name'] ?? name,
      schools: (data['schools'] as List<dynamic>?)
              ?.map((e) => School.fromSerialized(e))
              .toList() ??
          _schools,
    );
  }

  @override
  String toString() => name;
}
