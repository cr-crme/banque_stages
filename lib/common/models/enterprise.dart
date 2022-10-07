import 'package:crcrme_banque_stages/crcrme_enhanced_containers/lib/item_serializable.dart';

import '/common/models/job_list.dart';

class Enterprise extends ItemSerializable {
  Enterprise({
    this.photo = "",
    required this.name,
    required this.activityTypes,
    this.recrutedBy = "",
    required this.shareWith,
    required this.jobs,
    required this.contactName,
    this.contactFunction = "",
    required this.contactPhone,
    this.contactEmail = "",
    this.address = "",
    this.phone = "",
    this.fax = "",
    this.website = "",
    this.headquartersAddress = "",
    this.neq = "",
    id,
  }) : super(id: id);

  Enterprise copyWith({
    String? photo,
    String? name,
    Set<String>? activityTypes,
    String? recrutedBy,
    String? shareWith,
    JobList? jobs,
    String? contactName,
    String? contactFunction,
    String? contactPhone,
    String? contactEmail,
    String? address,
    String? phone,
    String? fax,
    String? website,
    String? headquartersAddress,
    String? neq,
    String? id,
  }) {
    return Enterprise(
      photo: photo ?? this.photo,
      name: name ?? this.name,
      activityTypes: activityTypes ?? this.activityTypes,
      recrutedBy: recrutedBy ?? this.recrutedBy,
      shareWith: shareWith ?? this.shareWith,
      jobs: jobs ?? this.jobs,
      contactName: contactName ?? this.contactName,
      contactFunction: contactFunction ?? this.contactFunction,
      contactPhone: contactPhone ?? this.contactPhone,
      contactEmail: contactEmail ?? this.contactEmail,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      fax: fax ?? this.fax,
      website: website ?? this.website,
      headquartersAddress: headquartersAddress ?? this.headquartersAddress,
      neq: neq ?? this.neq,
      id: id ?? this.id,
    );
  }

  @override
  Map<String, dynamic> serializedMap() {
    return {
      "photo": photo,
      "name": name,
      "activityTypes": activityTypes.toList(),
      "recrutedBy": recrutedBy,
      "shareWith": shareWith,
      "jobs": jobs.serialize(),
      "contactName": contactName,
      "contactFunction": contactFunction,
      "contactPhone": contactPhone,
      "contactEmail": contactEmail,
      "address": address,
      "phone": phone,
      "fax": fax,
      "website": website,
      "headquartersAddress": headquartersAddress,
      "neq": neq,
    };
  }

  @override
  Enterprise.fromSerialized(map)
      : photo = map['photo'],
        name = map['name'],
        activityTypes =
            (map['activityTypes'] as List).map((e) => e.toString()).toSet(),
        recrutedBy = map['recrutedBy'],
        shareWith = map['shareWith'],
        jobs = JobList.fromSerialized((map['jobs'] as Map)
            .map((key, value) => MapEntry(key.toString(), value))),
        contactName = map['contactName'],
        contactFunction = map['contactFunction'],
        contactPhone = map['contactPhone'],
        contactEmail = map['contactEmail'],
        address = map['address'],
        phone = map['phone'],
        fax = map['fax'],
        website = map['website'],
        headquartersAddress = map['headquartersAddress'],
        neq = map['neq'],
        super.fromSerialized(map);

  @override
  ItemSerializable deserializeItem(map) {
    return Enterprise.fromSerialized(map);
  }

  final String photo;

  final String name;
  final Set<String> activityTypes;
  final String recrutedBy;
  final String shareWith;

  final JobList jobs;

  final String contactName;
  final String contactFunction;
  final String contactPhone;
  final String contactEmail;

  final String address;
  final String phone;
  final String fax;
  final String website;

  final String headquartersAddress;
  final String neq;
}

// TODO: Replace with adequate data
const List<String> activityTypes = [
  "Activity Type 1",
  "Activity Type 2",
  "Activity Type 3",
  "Activity Type 4",
  "Activity Type 5",
  "Test",
  "A Test",
  "B Test",
  "C Test"
];
