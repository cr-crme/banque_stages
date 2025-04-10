import 'package:enhanced_containers_foundation/enhanced_containers_foundation.dart';

enum ProtectionsStatus {
  suppliedByEnterprise,
  suppliedBySchool,
  none;

  @override
  String toString() {
    switch (this) {
      case ProtectionsStatus.suppliedByEnterprise:
        return 'Oui et l\'entreprise les fournit';
      case ProtectionsStatus.suppliedBySchool:
        return 'Oui mais l\'entreprise ne les fournit pas';
      case ProtectionsStatus.none:
        return 'Non';
    }
  }
}

enum ProtectionsType {
  steelToeShoes,
  nonSlipSoleShoes,
  safetyGlasses,
  earProtection,
  mask,
  helmet,
  gloves;

  @override
  String toString() {
    switch (this) {
      case ProtectionsType.steelToeShoes:
        return 'Chaussures à cap d\'acier';
      case ProtectionsType.nonSlipSoleShoes:
        return 'Chaussures à semelles antidérapantes';
      case ProtectionsType.safetyGlasses:
        return 'Lunettes de sécurité';
      case ProtectionsType.earProtection:
        return 'Protections auditives';
      case ProtectionsType.mask:
        return 'Masque';
      case ProtectionsType.helmet:
        return 'Casque';
      case ProtectionsType.gloves:
        return 'Gants';
    }
  }
}

class Protections extends ItemSerializable {
  ProtectionsStatus status;
  List<String> protections;

  Protections({super.id, required this.status, List<String>? protections})
      : protections = protections ?? [];

  Protections.fromSerialized(super.map)
      : status = map['status'] == null
            ? ProtectionsStatus.none
            : ProtectionsStatus.values[map['status']],
        protections =
            (map['protections'] as List? ?? []).map<String>((e) => e).toList(),
        super.fromSerialized();

  @override
  Map<String, dynamic> serializedMap() => {
        'id': id,
        'status': status.index,
        'protections': protections,
      };
}
