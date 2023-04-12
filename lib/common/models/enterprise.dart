import 'package:enhanced_containers/enhanced_containers.dart';

import '/common/models/address.dart';
import '/common/models/internship.dart';
import '/common/models/job.dart';
import '/common/models/job_list.dart';
import '/common/models/phone_number.dart';
import '/common/providers/internships_provider.dart';

class Enterprise extends ItemSerializable {
  final String name;
  final Set<String> activityTypes;
  final String recrutedBy;
  final String shareWith;

  final JobList jobs;

  final String contactName;
  final String contactFunction;
  final PhoneNumber contactPhone;
  final String contactEmail;

  final Address? address;
  final PhoneNumber phone;
  final PhoneNumber fax;
  final String website;

  final Address? headquartersAddress;
  final String? neq;

  List<Internship> internships(context, {listen = true}) =>
      InternshipsProvider.of(context, listen: listen)
          .mapRemoveNull<Internship>(
              (Internship e) => e.enterpriseId == id ? e : null)
          .toList();

  Iterable<Job> availableJobs(context) {
    return jobs.where(
        (job) => job.positionsOffered - job.positionsOccupied(context) > 0);
  }

  Enterprise({
    super.id,
    required this.name,
    required this.activityTypes,
    required this.recrutedBy,
    required this.shareWith,
    required this.jobs,
    required this.contactName,
    this.contactFunction = '',
    required this.contactPhone,
    this.contactEmail = '',
    this.address,
    this.phone = const PhoneNumber(),
    this.fax = const PhoneNumber(),
    this.website = '',
    this.headquartersAddress,
    this.neq = '',
  });

  Enterprise copyWith({
    String? name,
    Set<String>? activityTypes,
    String? recrutedBy,
    String? shareWith,
    JobList? jobs,
    String? contactName,
    String? contactFunction,
    PhoneNumber? contactPhone,
    String? contactEmail,
    Address? address,
    PhoneNumber? phone,
    PhoneNumber? fax,
    String? website,
    Address? headquartersAddress,
    String? neq,
    String? id,
  }) {
    return Enterprise(
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
      'name': name,
      'activityTypes': activityTypes.toList(),
      'recrutedBy': recrutedBy,
      'shareWith': shareWith,
      'jobs': jobs.serialize(),
      'contactName': contactName,
      'contactFunction': contactFunction,
      'contactPhone': contactPhone.toString(),
      'contactEmail': contactEmail,
      'address': address?.serializedMap(),
      'phone': phone.toString(),
      'fax': fax.toString(),
      'website': website,
      'headquartersAddress': headquartersAddress?.serializedMap(),
      'neq': neq,
    };
  }

  @override
  Enterprise.fromSerialized(map)
      : name = map['name'],
        activityTypes =
            ItemSerializable.setFromSerialized(map['activityTypes']),
        recrutedBy = map['recrutedBy'],
        shareWith = map['shareWith'],
        jobs = JobList.fromSerialized(map['jobs']),
        contactName = map['contactName'],
        contactFunction = map['contactFunction'],
        contactPhone = PhoneNumber.fromString(map['contactPhone']),
        contactEmail = map['contactEmail'],
        address = Address.fromSerialized(map['address']),
        phone = PhoneNumber.fromString(map['phone']),
        fax = PhoneNumber.fromString(map['fax']),
        website = map['website'],
        headquartersAddress = map['headquartersAddress'] == null
            ? null
            : Address.fromSerialized(map['headquartersAddress']),
        neq = map['neq'],
        super.fromSerialized(map);
}

const List<String> activityTypes = [
  'Animalerie',
  'Barbier',
  'Boucherie',
  'Boulangerie',
  'Coiffeur',
  'Commerce',
  'CPE',
  'Cuisine',
  'Dépanneur',
  'Ébénisterie',
  'Épicerie',
  'Fleuriste',
  'Garage',
  'Garderie',
  'Industriel',
  'Magasin',
  'Magasin de vêtements',
  'Magasin entrepôt',
  'Mécanique',
  'Mensuiserie',
  'Pharmacie',
  'Préparation de commandes',
  'Quincaillerie',
  'Restaurant',
  'Restauration rapide',
  'Salon de coiffure',
  'Salon de toilettage',
  'Sandwicherie',
  'Station-service',
  'Supermarché',
  'Usine'
];
