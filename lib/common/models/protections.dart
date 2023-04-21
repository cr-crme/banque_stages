import 'package:enhanced_containers/enhanced_containers.dart';

enum ProtectionsStatus {
  suppliedByEnterprise,
  suppliedBySchool,
  none;
}

extension ProtectionStatusNamed on ProtectionsStatus {
  String get name {
    switch (this) {
      case ProtectionsStatus.suppliedByEnterprise:
        return 'Oui et l\'entreprise les fournis';
      case ProtectionsStatus.suppliedBySchool:
        return 'Oui mais l\'école doit les acheter';
      case ProtectionsStatus.none:
        return 'Non';
    }
  }
}

class Protections extends ItemSerializable {
  ProtectionsStatus status;
  List<String> protections;

  Protections({
    required this.status,
    required this.protections,
  });

  Protections.fromSerialized(map)
      : status = ProtectionsStatus.values[map['status']],
        protections = ItemSerializable.listFromSerialized(map['protections']);

  @override
  Map<String, dynamic> serializedMap() => {
        'id': id,
        'status': status.index,
        'protections': protections,
      };

  Protections deepCopy() {
    return Protections(
        status: status, protections: protections.map((e) => e).toList());
  }
}
