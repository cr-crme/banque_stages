import 'package:enhanced_containers/enhanced_containers.dart';

import '/common/models/address.dart';
import '/common/models/internship.dart';
import '/common/models/job.dart';
import '/common/models/job_list.dart';
import '/common/providers/internships_provider.dart';

class Enterprise extends ItemSerializable {
  final String? photoUrl;

  final String name;
  final Set<String> activityTypes;
  final String recrutedBy;
  final String shareWith;

  final JobList jobs;

  final String contactName;
  final String contactFunction;
  final String contactPhone;
  final String contactEmail;

  final Address? address;
  final String phone;
  final String fax;
  final String website;

  final Address? headquartersAddress;
  final String neq;

  List<Internship> internships(context, {listen = true}) =>
      InternshipsProvider.of(context, listen: listen)
          .mapRemoveNull<Internship>(
              (Internship e) => e.enterpriseId == id ? e : null)
          .toList();

  Iterable<Job> get availableJobs {
    return jobs
        .where((job) => job.positionsOffered - job.positionsOccupied > 0);
  }

  Enterprise({
    super.id,
    this.photoUrl,
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
    this.phone = '',
    this.fax = '',
    this.website = '',
    this.headquartersAddress,
    this.neq = '',
  });

  Enterprise copyWith({
    String? photoUrl,
    String? name,
    Set<String>? activityTypes,
    String? recrutedBy,
    String? shareWith,
    JobList? jobs,
    String? contactName,
    String? contactFunction,
    String? contactPhone,
    String? contactEmail,
    Address? address,
    String? phone,
    String? fax,
    String? website,
    Address? headquartersAddress,
    String? neq,
    String? id,
  }) {
    return Enterprise(
      photoUrl: photoUrl ?? this.photoUrl,
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
      'photoUrl': photoUrl,
      'name': name,
      'activityTypes': activityTypes.toList(),
      'recrutedBy': recrutedBy,
      'shareWith': shareWith,
      'jobs': jobs.serialize(),
      'contactName': contactName,
      'contactFunction': contactFunction,
      'contactPhone': contactPhone,
      'contactEmail': contactEmail,
      'address': address?.serializedMap(),
      'phone': phone,
      'fax': fax,
      'website': website,
      'headquartersAddress': headquartersAddress?.serializedMap(),
      'neq': neq,
    };
  }

  @override
  Enterprise.fromSerialized(map)
      : photoUrl = map['photoUrl'],
        name = map['name'],
        activityTypes =
            ItemSerializable.setFromSerialized(map['activityTypes']),
        recrutedBy = map['recrutedBy'],
        shareWith = map['shareWith'],
        jobs = JobList.fromSerialized(map['jobs']),
        contactName = map['contactName'],
        contactFunction = map['contactFunction'],
        contactPhone = map['contactPhone'],
        contactEmail = map['contactEmail'],
        address = Address.fromSerialized(map['address']),
        phone = map['phone'],
        fax = map['fax'],
        website = map['website'],
        headquartersAddress =
            Address.fromSerialized(map['headquartersAddress']),
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
