import 'package:crcrme_banque_stages/crcrme_enhanced_containers/lib/item_serializable.dart';

class Student extends ItemSerializable {
  Student({
    super.id,
    this.name = "",
    DateTime? dateBirth,
    this.phone = "",
    this.email = "",
    this.address = "",
    this.program = "",
    this.group = "",
    this.contactName = "",
    this.contactRole = "",
    this.contactPhone = "",
    this.contactEmail = "",
  }) : dateBirth = dateBirth ?? DateTime(0);

  Student.fromSerialized(map)
      : name = map['n'],
        dateBirth = DateTime.parse(map['d']),
        phone = map['p'],
        email = map['e'],
        address = map['a'],
        program = map['pr'],
        group = map['gr'],
        contactName = map['cn'],
        contactRole = map['cr'],
        contactPhone = map['cp'],
        contactEmail = map['ce'],
        super.fromSerialized(map);

  @override
  Map<String, dynamic> serializedMap() {
    return {
      'n': name,
      'd': dateBirth.toString(),
      'p': phone,
      'e': email,
      'a': address,
      'pr': program,
      'gr': group,
      'cn': contactName,
      'cr': contactRole,
      'cp': contactPhone,
      'ce': contactEmail,
      'id': id,
    };
  }

  Student copyWith({
    String? name,
    String? email,
    String? id,
  }) =>
      Student(
        name: name ?? this.name,
        email: email ?? this.email,
        id: id ?? this.id,
      );

  final String name;
  final DateTime dateBirth;

  final String phone;
  final String email;
  final String address;

  final String program;
  final String group;

  final String contactName;
  final String contactRole;
  final String contactPhone;
  final String contactEmail;
}
