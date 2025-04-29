import 'package:common/exceptions.dart';
import 'package:common/models/enterprises/job_list.dart';
import 'package:common/models/generic/address.dart';
import 'package:common/models/generic/phone_number.dart';
import 'package:common/models/persons/person.dart';
import 'package:enhanced_containers_foundation/enhanced_containers_foundation.dart';

part 'package:common/models/enterprises/activity_types.dart';

class Enterprise extends ItemSerializable {
  static final String _currentVersion = '1.0.0';
  static String get currentVersion => _currentVersion;

  final String schoolBoardId;

  final String name;
  final Set<ActivityTypes> activityTypes;
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
      id: data['id']?.toString() ?? id,
      schoolBoardId: data['school_board_id'] ?? schoolBoardId,
      name: data['name'] ?? name,
      activityTypes: data['activity_types'] == null
          ? activityTypes
          : (data['activity_types'] as List)
              .map((e) => ActivityTypes._fromInt(e as int, version))
              .toSet(),
      recruiterId: data['recruiter_id'] ?? recruiterId,
      jobs: data['jobs'] ?? jobs,
      contact: data['contact'] ?? contact,
      contactFunction: data['contact_function'] ?? contactFunction,
      address: data['address'] ?? address,
      phone: data['phone'] ?? phone,
      fax: data['fax'] ?? fax,
      website: data['website'] ?? website,
      headquartersAddress: data['headquarters_address'] ?? headquartersAddress,
      neq: data['neq'] ?? neq,
    );
  }

  @override
  Map<String, dynamic> serializedMap() {
    return {
      'school_board_id': schoolBoardId,
      'name': name,
      'version': _currentVersion,
      'activity_types':
          activityTypes.map((e) => e._toInt(_currentVersion)).toList(),
      'recruiter_id': recruiterId,
      'jobs': jobs.serialize(),
      'contact': contact.serialize(),
      'contact_function': contactFunction,
      'address': address?.serialize(),
      'phone': phone.serialize(),
      'fax': fax.serialize(),
      'website': website,
      'headquarters_address': headquartersAddress?.serialize(),
      'neq': neq,
    };
  }

  @override
  Enterprise.fromSerialized(super.map)
      : schoolBoardId = map['school_board_id'] ?? '-1',
        name = map['name'] ?? 'Unnamed enterprise',
        activityTypes = (map['activity_types'] as List? ?? [])
            .map((e) => ActivityTypes._fromInt(e, map['version']))
            .toSet(),
        recruiterId = map['recruiter_id'] ?? 'UnknownId',
        jobs = JobList.fromSerialized(map['jobs'] ?? {}),
        contact = Person.fromSerialized(map['contact'] ?? {}),
        contactFunction = map['contact_function'] ?? '',
        address = map['address'] == null
            ? null
            : Address.fromSerialized(map['address']),
        phone = PhoneNumber.fromSerialized(map['phone'] ?? {}),
        fax = PhoneNumber.fromSerialized(map['fax'] ?? {}),
        website = map['website'] ?? '',
        headquartersAddress = map['headquarters_address'] == null
            ? null
            : Address.fromSerialized(map['headquarters_address']),
        neq = map['neq'] ?? '',
        super.fromSerialized();
}
