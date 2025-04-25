import 'package:common/models/generic/address.dart';
import 'package:common/models/generic/phone_number.dart';
import 'package:common/models/internships/internship.dart';
import 'package:common/models/persons/person.dart';
import 'package:crcrme_banque_stages/common/models/job.dart';
import 'package:crcrme_banque_stages/common/models/job_list.dart';
import 'package:crcrme_banque_stages/common/providers/internships_provider.dart';
import 'package:enhanced_containers/enhanced_containers.dart';

class Enterprise extends ItemSerializable {
  final String name;
  final Set<String> activityTypes;
  final String recrutedBy;
  final String shareWith;

  final JobList jobs;

  final Person contact;
  final String contactFunction;

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
    String? name,
    Set<String>? activityTypes,
    String? recrutedBy,
    String? shareWith,
    JobList? jobs,
    Person? contact,
    String? contactFunction,
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
      contact: contact ?? this.contact,
      contactFunction: contactFunction ?? this.contactFunction,
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
      'contact': contact.serialize(),
      'contactFunction': contactFunction,
      'address': address?.serialize(),
      'phone': phone.toString(),
      'fax': fax.toString(),
      'website': website,
      'headquartersAddress': headquartersAddress?.serialize(),
      'neq': neq,
    };
  }

  @override
  Enterprise.fromSerialized(super.map)
      : name = map['name'] ?? 'Unnamed enterprise',
        activityTypes =
            (map['activityTypes'] as List? ?? []).map<String>((e) => e).toSet(),
        recrutedBy = map['recrutedBy'] ?? 'Unnamed recruiter',
        shareWith = map['shareWith'] ?? 'Unnamed sharing',
        jobs = JobList.fromSerialized(map['jobs'] ?? {}),
        contact = Person.fromSerialized(map['contact'] ?? {}),
        contactFunction = map['contactFunction'] ?? '',
        address = map['address'] == null
            ? null
            : Address.fromSerialized(map['address']),
        phone = PhoneNumber.fromString(map['phone'] ?? ''),
        fax = PhoneNumber.fromString(map['fax'] ?? ''),
        website = map['website'] ?? '',
        headquartersAddress = map['headquartersAddress'] == null
            ? null
            : Address.fromSerialized(map['headquartersAddress']),
        neq = map['neq'],
        super.fromSerialized();
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
