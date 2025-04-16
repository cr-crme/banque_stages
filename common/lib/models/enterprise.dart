import 'package:common/exceptions.dart';
import 'package:common/models/address.dart';
import 'package:common/models/job_list.dart';
import 'package:common/models/person.dart';
import 'package:common/models/phone_number.dart';
import 'package:enhanced_containers_foundation/enhanced_containers_foundation.dart';

class Enterprise extends ItemSerializable {
  final String name;
  final Set<String> activityTypes;
  final String recruiterId;

  // final JobList jobs;

  final Person contact;
  final String contactFunction;

  final Address? address;
  final PhoneNumber phone;
  final PhoneNumber fax;
  final String website;

  final Address? headquartersAddress;
  final String? neq;

  // // TODO: Implement this on app side with an extension on
  // // List<Internship> internships(context, {listen = true}) =>
  // //     InternshipsProvider.of(context, listen: listen)
  // //         .mapRemoveNull<Internship>(
  // //             (Internship e) => e.enterpriseId == id ? e : null)
  // //         .toList();

  // // TODO Implement this on app side with an extension on
  // // Iterable<Job> availableJobs(context) {
  // //   return jobs.where(
  // //       (job) => job.positionsOffered - job.positionsOccupied(context) > 0);
  // // }

  Enterprise({
    super.id,
    required this.name,
    required this.activityTypes,
    required this.recruiterId,
    // required this.jobs,
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
    String? name,
    Set<String>? activityTypes,
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
      name: name ?? this.name,
      activityTypes: activityTypes ?? this.activityTypes,
      recruiterId: recruiterId ?? this.recruiterId,
      // jobs: jobs ?? this.jobs,
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
      'name',
      'activity_types',
      'recruiter_id',
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
    return Enterprise(
      id: data['id']?.toString() ?? id,
      name: data['name'] ?? name,
      activityTypes: (data['activity_types'] as List? ?? [])
          .map<String>((e) => e.toString())
          .toSet(),
      recruiterId: data['recruiter_id'] ?? recruiterId,
      // jobs: jobs ?? this.jobs,
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
      'name': name,
      'activity_types': activityTypes.toList(),
      'recruiter_id': recruiterId,
      // 'jobs': jobs.serialize(),
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
      : name = map['name'] ?? 'Unnamed enterprise',
        activityTypes = (map['activity_types'] as List? ?? [])
            .map<String>((e) => e.toString())
            .toSet(),
        recruiterId = map['recruiter_id'] ?? 'UnknownId',
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
  // jobs = JobList.fromSerialized(map['jobs'] ?? {}),
}

const List<String> activityTypes = [
  'Agricole',
  'Animalerie',
  'Barbier',
  'Bâtiment',
  'Boucherie',
  'Boulangerie',
  'Coiffeur',
  'Commerce',
  'CPE',
  'Cuisine',
  'Dépanneur',
  'Ébénisterie',
  'École',
  'Entreposage',
  'Entretien',
  'Épicerie',
  'Esthétique',
  'Ferme',
  'Fleuriste',
  'Garage',
  'Garderie',
  'Industrie',
  'Loisirs',
  'Magasin',
  'Magasin de vêtements',
  'Magasin entrepôt',
  'Maison de retraite',
  'Mécanique',
  'Menuiserie',
  'Pharmacie',
  'Préparation de commandes',
  'Quincaillerie',
  'Recyclage',
  'Réparation',
  'Restaurant',
  'Restauration rapide',
  'Salon de coiffure',
  'Salon de toilettage',
  'Sandwicherie',
  'Soins',
  'Station-service',
  'Supermarché',
  'Transformation alimentaire',
  'Travaux publics',
  'Usine',
  'Autre'
];
