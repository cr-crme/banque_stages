// ignore_for_file: non_constant_identifier_names

//Risk class converts dummy json risk data into risk objects
class RiskSST {
  const RiskSST({
    required this.id,
    required this.shortname,
    required this.title,
    this.desc,
    this.image, //There are sometimes no risks
  });

  final int id;
  final String shortname;
  final String title;
  final String? desc;
  final String? image;

  //Tostring displays risk id and title
  @override
  String toString() {
    return '{Fiche #$id: $title}';
  }
}
