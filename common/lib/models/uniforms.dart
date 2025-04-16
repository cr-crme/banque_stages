import 'package:enhanced_containers_foundation/enhanced_containers_foundation.dart';

enum UniformStatus {
  suppliedByEnterprise,
  suppliedByStudent,
  none;

  static UniformStatus fromName(String name) {
    return UniformStatus.values.firstWhere(
      (element) => element.name == name,
      orElse: () => UniformStatus.none,
    );
  }

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

class Uniforms extends ItemSerializable {
  final UniformStatus status;
  final String _uniform;

  List<String> get uniforms => _uniform.isEmpty ? [] : _uniform.split('\n');

  Uniforms({super.id, required this.status, String? uniform = ''})
      : _uniform = uniform ?? '';

  Uniforms.fromSerialized(super.map)
      : status = map['status'] == null
            ? UniformStatus.none
            : UniformStatus.values[map['status']],
        _uniform = map['uniform'] ?? '',
        super.fromSerialized();

  @override
  Map<String, dynamic> serializedMap() => {
        'id': id,
        'status': status.index,
        'uniform': _uniform,
      };
}
