import 'package:common/exceptions.dart';
import 'package:common/models/enterprises/job_list.dart';
import 'package:common/models/generic/address.dart';
import 'package:common/models/generic/extended_item_serializable.dart';
import 'package:common/models/generic/phone_number.dart';
import 'package:common/models/generic/serializable_elements.dart';
import 'package:common/models/persons/person.dart';

part 'package:common/models/enterprises/activity_types.dart';

class Enterprise extends ExtendedItemSerializable {
  static final String _currentVersion = '1.0.0';
  static String get currentVersion => _currentVersion;

  final String schoolBoardId;

  final String name;
  final Set<ActivityTypes> activityTypes;
  List<int> get activityTypesSerialized =>
      activityTypes.map((e) => e._toInt(_currentVersion)).toList();
  final String recruiterId;

  final JobList jobs;

  final Person contact;
  final String contactFunction;

  final Address? address;
  final PhoneNumber phone;
  final PhoneNumber fax;
  final String website;

  final Address? headquartersAddress;
  final String? neq;

  Enterprise({
    super.id,
    required this.schoolBoardId,
    required this.name,
    required this.activityTypes,
    required this.recruiterId,
    required this.jobs,
    required this.contact,
    this.contactFunction = '',
    this.address,
    PhoneNumber? phone,
    PhoneNumber? fax,
    this.website = '',
    this.headquartersAddress,
    this.neq = '',
  })  : phone = phone ?? PhoneNumber.empty,
        fax = fax ?? PhoneNumber.empty;

  Enterprise copyWith({
    String? id,
    String? schoolBoardId,
    String? name,
    Set<ActivityTypes>? activityTypes,
    String? recruiterId,
    JobList? jobs,
    Person? contact,
    String? contactFunction,
    Address? address,
    PhoneNumber? phone,
    PhoneNumber? fax,
    String? website,
    Address? headquartersAddress,
    String? neq,
  }) {
    return Enterprise(
      id: id ?? this.id,
      schoolBoardId: schoolBoardId ?? this.schoolBoardId,
      name: name ?? this.name,
      activityTypes: activityTypes ?? this.activityTypes,
      recruiterId: recruiterId ?? this.recruiterId,
      jobs: jobs ?? this.jobs,
      contact: contact ?? this.contact,
      contactFunction: contactFunction ?? this.contactFunction,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      fax: fax ?? this.fax,
      website: website ?? this.website,
      headquartersAddress: headquartersAddress ?? this.headquartersAddress,
      neq: neq ?? this.neq,
    );
  }

  @override
  Enterprise copyWithData(Map<String, dynamic> data) {
    final availableFields = [
      'id',
      'school_board_id',
      'version',
      'name',
      'activity_types',
      'recruiter_id',
      'jobs',
      'contact',
      'contact_function',
      'address',
      'phone',
      'fax',
      'website',
      'headquarters_address',
      'neq',
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

    return Enterprise(
      id: StringExt.from(data['id']) ?? id,
      schoolBoardId: data['school_board_id'] ?? schoolBoardId,
      name: data['name'] ?? name,
      activityTypes: data['activity_types'] == null
          ? activityTypes
          : (data['activity_types'] as List)
              .map((e) => ActivityTypes._fromInt(e as int, version))
              .toSet(),
      recruiterId: StringExt.from(data['recruiter_id']) ?? recruiterId,
      jobs: JobList.from(data['jobs']) ?? jobs,
      contact: Person.from(data['contact']) ?? contact,
      contactFunction:
          StringExt.from(data['contact_function']) ?? contactFunction,
      address: Address.from(data['address']) ?? address,
      phone: PhoneNumber.from(data['phone']) ?? phone,
      fax: PhoneNumber.from(data['fax']) ?? fax,
      website: StringExt.from(data['website']) ?? website,
      headquartersAddress:
          Address.from(data['headquarters_address']) ?? headquartersAddress,
      neq: StringExt.from(data['neq']) ?? neq,
    );
  }

  @override
  Map<String, dynamic> serializedMap() {
    return {
      'school_board_id': schoolBoardId.serialize(),
      'name': name.serialize(),
      'version': _currentVersion.serialize(),
      'activity_types': activityTypesSerialized,
      'recruiter_id': recruiterId.serialize(),
      'jobs': jobs.serialize(),
      'contact': contact.serialize(),
      'contact_function': contactFunction.serialize(),
      'address': address?.serialize(),
      'phone': phone.serialize(),
      'fax': fax.serialize(),
      'website': website.serialize(),
      'headquarters_address': headquartersAddress?.serialize(),
      'neq': neq?.serialize(),
    };
  }

  @override
  Enterprise.fromSerialized(super.map)
      : schoolBoardId = StringExt.from(map['school_board_id']) ?? '-1',
        name = StringExt.from(map['name']) ?? 'Unnamed enterprise',
        activityTypes = (map['activity_types'] as List? ?? [])
            .map((e) => ActivityTypes._fromInt(e, map['version']))
            .toSet(),
        recruiterId = StringExt.from(map['recruiter_id']) ?? '-1',
        jobs = JobList.fromSerialized(map['jobs'] ?? {}),
        contact = Person.fromSerialized(map['contact'] ?? {}),
        contactFunction = StringExt.from(map['contact_function']) ?? '',
        address = Address.from(map['address']),
        phone = PhoneNumber.from(map['phone']) ?? PhoneNumber.empty,
        fax = PhoneNumber.from(map['fax']) ?? PhoneNumber.empty,
        website = StringExt.from(map['website']) ?? '',
        headquartersAddress = Address.from(map['headquarters_address']),
        neq = StringExt.from(map['neq']),
        super.fromSerialized();
}
