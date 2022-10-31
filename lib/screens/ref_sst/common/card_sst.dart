// ignore_for_file: non_constant_identifier_names

//Card class contains the cards info and a list of more precise risks
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

//Object to save link information
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

//Class RiskSST keeps individual risk data, including each paragraph in a map
//(for each line), with a string array (for sublines)
class RiskSST {
  const RiskSST({
    required this.id,
    required this.title,
    required this.intro,
    required this.situations,
    required this.factors,
    required this.symptoms,
    required this.images,
  });
  final int id;
  final String title;
  final String intro;
  final Map<String, List<String>> situations;
  final Map<String, List<String>> factors;
  final Map<String, List<String>> symptoms;
  final List<String> images;
}
