import 'package:enhanced_containers/enhanced_containers.dart';

class Student extends ItemSerializable {
  Student({
    super.id,
    this.name = '',
    DateTime? dateBirth,
    this.photo = '',
    this.phone = '',
    this.email = '',
    this.address = '',
    this.program = '',
    this.group = '',
    this.contactName = '',
    this.contactLink = '',
    this.contactPhone = '',
    this.contactEmail = '',
    List<String>? internships,
  })  : dateBirth = dateBirth ?? DateTime(0),
        internships = internships ?? [];

  Student.fromSerialized(map)
      : name = map['n'],
        dateBirth = DateTime.parse(map['d']),
        photo = map['i'],
        phone = map['p'],
        email = map['e'],
        address = map['a'],
        program = map['pr'],
        group = map['gr'],
        contactName = map['cn'],
        contactLink = map['cl'],
        contactPhone = map['cp'],
        contactEmail = map['ce'],
        internships = map['internships'] as List<String>? ?? [],
        super.fromSerialized(map);

  @override
  Map<String, dynamic> serializedMap() {
    return {
      'n': name,
      'd': dateBirth.toString(),
      'i': photo,
      'p': phone,
      'e': email,
      'a': address,
      'pr': program,
      'gr': group,
      'cn': contactName,
      'cl': contactLink,
      'cp': contactPhone,
      'ce': contactEmail,
      'internships': internships,
      'id': id,
    };
  }

  Student copyWith({
    String? name,
    DateTime? dateBirth,
    String? phone,
    String? email,
    String? address,
    String? program,
    String? group,
    String? contactName,
    String? contactLink,
    String? contactPhone,
    String? contactEmail,
    List<String>? internships,
    String? id,
  }) =>
      Student(
        name: name ?? this.name,
        dateBirth: dateBirth ?? this.dateBirth,
        phone: phone ?? this.phone,
        email: email ?? this.email,
        address: address ?? this.address,
        program: program ?? this.program,
        group: group ?? this.group,
        contactName: contactName ?? this.contactName,
        contactLink: contactLink ?? this.contactLink,
        contactPhone: contactPhone ?? this.contactPhone,
        contactEmail: contactEmail ?? this.contactEmail,
        internships: internships ?? this.internships,
        id: id ?? this.id,
      );

  final String name;
  final DateTime dateBirth;
  final String photo;

  final String phone;
  final String email;
  final String address;

  final String program;
  final String group;

  final String contactName;
  final String contactLink;
  final String contactPhone;
  final String contactEmail;

  final List<String> internships;
}
