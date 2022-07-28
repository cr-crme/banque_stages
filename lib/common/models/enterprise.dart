import '/common/models/job_list.dart';
import '/misc/custom_containers/item_serializable.dart';
import 'activity_type.dart';

class Enterprise extends ItemSerializable {
  Enterprise(
      {required this.name,
      this.neq = "",
      required this.activityTypes,
      this.recrutedBy = "",
      required this.shareWith,
      required this.jobs,
      required this.contactName,
      this.contactFunction = "",
      required this.contactPhone,
      this.contactEmail = "",
      this.address = "",
      id})
      : super(id: id);

  Enterprise copyWith(
      {String? name,
      String? neq,
      Set<ActivityType>? activityTypes,
      String? recrutedBy,
      String? shareWith,
      JobList? jobs,
      String? contactName,
      String? contactFunction,
      String? contactPhone,
      String? contactEmail,
      String? address,
      String? id}) {
    return Enterprise(
        name: name ?? this.name,
        neq: neq ?? this.neq,
        activityTypes: activityTypes ?? this.activityTypes,
        recrutedBy: recrutedBy ?? this.recrutedBy,
        shareWith: shareWith ?? this.shareWith,
        jobs: jobs ?? this.jobs,
        contactName: contactName ?? this.contactName,
        contactFunction: contactFunction ?? this.contactFunction,
        contactPhone: contactPhone ?? this.contactPhone,
        contactEmail: contactEmail ?? this.contactEmail,
        address: address ?? this.address,
        id: id ?? this.id);
  }

  @override
  Map<String, dynamic> serializedMap() {
    return {
      "name": name,
      "neq": neq,
      "activityTypes": activityTypes,
      "recrutedBy": recrutedBy,
      "shareWith": shareWith,
      "jobs": jobs,
      "contactName": contactName,
      "contactFunction": contactFunction,
      "contactPhone": contactPhone,
      "contactEmail": contactEmail,
      "address": address,
    };
  }

  @override
  Enterprise.fromSerialized(Map<String, dynamic> map)
      : name = map['name'],
        neq = map['neq'],
        activityTypes = map['activityTypes'],
        recrutedBy = map['recrutedBy'],
        shareWith = map['shareWith'],
        jobs = map['jobs'],
        contactName = map['contactName'],
        contactFunction = map['contactFunction'],
        contactPhone = map['contactPhone'],
        contactEmail = map['contactEmail'],
        address = map['address'],
        super.fromSerialized(map);

  @override
  ItemSerializable deserializeItem(Map<String, dynamic> map) {
    return Enterprise.fromSerialized(map);
  }

  final String name;
  final String neq;
  final Set<ActivityType> activityTypes;
  final String recrutedBy;
  final String shareWith;

  final JobList jobs;

  final String contactName;
  final String contactFunction;
  final String contactPhone;
  final String contactEmail;

  final String address;
}
