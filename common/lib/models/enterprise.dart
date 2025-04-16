import 'package:common/exceptions.dart';
import 'package:common/models/address.dart';
import 'package:common/models/job_list.dart';
import 'package:common/models/person.dart';
import 'package:common/models/phone_number.dart';
import 'package:enhanced_containers_foundation/enhanced_containers_foundation.dart';

class Enterprise extends ItemSerializable {
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
    return Enterprise(
      id: data['id']?.toString() ?? id,
      name: data['name'] ?? name,
      activityTypes: (data['activity_types'] as List? ?? [])
          .map((e) => ActivityTypes.fromName(e as String))
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
      'name': name,
      'activity_types': activityTypes.map((e) => e.name).toList(),
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
      : name = map['name'] ?? 'Unnamed enterprise',
        activityTypes = (map['activity_types'] as List? ?? [])
            .map((e) => ActivityTypes.fromName(e as String))
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

enum ActivityTypes {
  agricole,
  animalerie,
  barbier,
  batiment,
  boucherie,
  boulangerie,
  coiffeur,
  commerce,
  cpe,
  cuisine,
  depanneur,
  ebenisterie,
  ecole,
  entreposage,
  entretien,
  epicerie,
  esthetique,
  ferme,
  fleuriste,
  garage,
  garderie,
  industrie,
  loisirs,
  magasin,
  magasinDeVetements,
  magasinEntrepot,
  maisonDeRetraite,
  mecanique,
  menuiserie,
  pharmacie,
  preparationDeCommandes,
  quincaillerie,
  recyclage,
  reparation,
  restaurant,
  restaurationRapide,
  salonDeCoiffure,
  salonDeToilettage,
  sandwicherie,
  soins,
  stationService,
  supermarche,
  transformationAlimentaire,
  travauxPublics,
  usine,
  autre;

  static ActivityTypes fromName(String name) {
    return ActivityTypes.values.firstWhere((element) => element.name == name);
  }

  @override
  String toString() {
    switch (this) {
      case ActivityTypes.agricole:
        return 'Agricole';
      case ActivityTypes.animalerie:
        return 'Animalerie';
      case ActivityTypes.barbier:
        return 'Barbier';
      case ActivityTypes.batiment:
        return 'Bâtiment';
      case ActivityTypes.boucherie:
        return 'Boucherie';
      case ActivityTypes.boulangerie:
        return 'Boulangerie';
      case ActivityTypes.coiffeur:
        return 'Coiffeur';
      case ActivityTypes.commerce:
        return 'Commerce';
      case ActivityTypes.cpe:
        return 'CPE';
      case ActivityTypes.cuisine:
        return 'Cuisine';
      case ActivityTypes.depanneur:
        return 'Dépanneur';
      case ActivityTypes.ebenisterie:
        return 'Ébénisterie';
      case ActivityTypes.ecole:
        return 'École';
      case ActivityTypes.entreposage:
        return 'Entreposage';
      case ActivityTypes.entretien:
        return 'Entretien';
      case ActivityTypes.epicerie:
        return 'Épicerie';
      case ActivityTypes.esthetique:
        return 'Esthétique';
      case ActivityTypes.ferme:
        return 'Ferme';
      case ActivityTypes.fleuriste:
        return 'Fleuriste';
      case ActivityTypes.garage:
        return 'Garage';
      case ActivityTypes.garderie:
        return 'Garderie';
      case ActivityTypes.industrie:
        return 'Industrie';
      case ActivityTypes.loisirs:
        return 'Loisirs';
      case ActivityTypes.magasin:
        return 'Magasin';
      case ActivityTypes.magasinDeVetements:
        return 'Magasin de vêtements';
      case ActivityTypes.magasinEntrepot:
        return 'Magasin entrepôt';
      case ActivityTypes.maisonDeRetraite:
        return 'Maison de retraite';
      case ActivityTypes.mecanique:
        return 'Mécanique';
      case ActivityTypes.menuiserie:
        return 'Menuiserie';
      case ActivityTypes.pharmacie:
        return 'Pharmacie';
      case ActivityTypes.preparationDeCommandes:
        return 'Préparation de commandes';
      case ActivityTypes.quincaillerie:
        return 'Quincaillerie';
      case ActivityTypes.recyclage:
        return 'Recyclage';
      case ActivityTypes.reparation:
        return 'Réparation';
      case ActivityTypes.restaurant:
        return 'Restaurant';
      case ActivityTypes.restaurationRapide:
        return 'Restauration rapide';
      case ActivityTypes.salonDeCoiffure:
        return 'Salon de coiffure';
      case ActivityTypes.salonDeToilettage:
        return 'Salon de toilettage';
      case ActivityTypes.sandwicherie:
        return 'Sandwicherie';
      case ActivityTypes.soins:
        return 'Soins';
      case ActivityTypes.stationService:
        return 'Station-service';
      case ActivityTypes.supermarche:
        return 'Supermarché';
      case ActivityTypes.transformationAlimentaire:
        return 'Transformation alimentaire';
      case ActivityTypes.travauxPublics:
        return 'Travaux publics';
      case ActivityTypes.usine:
        return 'Usine';
      case ActivityTypes.autre:
        return 'Autre';
    }
  }
}
