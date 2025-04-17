part of 'package:common/models/enterprises/enterprise.dart';

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

  int _toInt(String version) {
    if (version == '1.0.0') {
      return index;
    }
    throw WrongVersionException(version, '1.0.0');
  }

  static ActivityTypes _fromInt(int index, String version) {
    if (version == '1.0.0') {
      return ActivityTypes.values[index];
    }
    throw WrongVersionException(version, '1.0.0');
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
