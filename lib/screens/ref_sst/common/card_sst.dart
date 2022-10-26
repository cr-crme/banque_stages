// ignore_for_file: non_constant_identifier_names

//Risk class converts dummy json risk data into risk objects
class CardSST {
  const CardSST({
    required this.id,
    required this.shortname,
    required this.name,
    required this.risks,
    required this.links,
  });

  final int id;
  final String shortname;
  final String name;
  final List<RiskSST> risks;
  final List<LinkSST> links;

  //Tostring displays risk id and title
  @override
  String toString() {
    return '{Fiche #$id: $name}';
  }
}

class LinkSST {
  const LinkSST({
    required this.source,
    required this.title,
    required this.url,
  });

  final String source;
  final String title;
  final String url;
}

class RiskSST {
  const RiskSST({
    required this.id,
    required this.title,
    required this.situations,
    required this.factors,
    required this.symptoms,
    required this.images,
  });
  final int id;
  final String title;
  final Map<String, List<String>> situations;
  final Map<String, List<String>> factors;
  final Map<String, List<String>> symptoms;
  final List<String> images;
}
