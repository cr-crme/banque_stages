import 'package:enhanced_containers/enhanced_containers.dart';

enum UniformStatus {
  suppliedByEnterprise,
  suppliedByStudent,
  none;
}

extension UniformStatusNamed on UniformStatus {
  String get name {
    switch (this) {
      case UniformStatus.suppliedByEnterprise:
        return 'Oui et l\'entreprise le fournis';
      case UniformStatus.suppliedByStudent:
        return 'Oui mais l\'élève doit se le procurer';
      case UniformStatus.none:
        return 'Non';
    }
  }
}

class Uniform extends ItemSerializable {
  UniformStatus status;
  String uniform;

  Uniform({
    required this.status,
    required this.uniform,
  });

  Uniform.fromSerialized(map)
      : status = UniformStatus.values[map['status']],
        uniform = map['uniform'];

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