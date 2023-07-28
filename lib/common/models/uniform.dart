import 'package:enhanced_containers/enhanced_containers.dart';

enum UniformStatus {
  suppliedByEnterprise,
  suppliedByStudent,
  none;

  @override
  String toString() {
    switch (this) {
      case UniformStatus.suppliedByEnterprise:
        return 'Oui et l\'entreprise la fournit';
      case UniformStatus.suppliedByStudent:
        return 'Oui mais l\'entreprise ne la fournit pas';
      case UniformStatus.none:
        return 'Non';
    }
  }
}

class Uniform extends ItemSerializable {
  UniformStatus status;
  String uniform;

  Uniform({required this.status, String? uniform = ''})
      : uniform = uniform ?? '';

  Uniform.fromSerialized(map)
      : status = UniformStatus.values[map['status']],
        uniform = map['uniform'],
        super.fromSerialized(map);

  @override
  Map<String, dynamic> serializedMap() => {
        'id': id,
        'status': status.index,
        'uniform': uniform,
      };

  Uniform deepCopy() {
    return Uniform(status: status, uniform: uniform);
  }
}
