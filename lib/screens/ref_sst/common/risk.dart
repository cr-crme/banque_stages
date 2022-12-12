import 'package:enhanced_containers/item_serializable.dart';

class Risk extends ItemSerializable {
  Risk({
    super.id,
    this.number = 0,
    this.shortname = "",
    this.name = "",
    subrisks,
    links,
  })  : subrisks = subrisks ?? [],
        links = links ?? [];

  Risk copyWith({
    String? id,
    String? shortname,
    String? name,
    List<SubRisk>? subrisks,
    List<RiskLink>? links,
  }) {
    return Risk(
        id: id ?? this.id,
        shortname: shortname ?? this.shortname,
        name: name ?? this.name,
        subrisks: subrisks ?? this.subrisks,
        links: links ?? this.links);
  }

  @override
  Map<String, dynamic> serializedMap() {
    throw ("Risk should never generate a map, it is read only");
    return {};
  }

  @override
  String toString() {
    return '{Fiche #$number: $name}';
  }

  Risk.fromSerialized(map)
      : number = int.parse(map["number"]),
        shortname = map["shortname"],
        name = map["name"],
        links = getLinks(map["links"] as List<dynamic>),
        subrisks = getSubRisks(map["subrisks"] as List<dynamic>),
        super.fromSerialized(map);

  static List<RiskLink> getLinks(List<dynamic> links) {
    List<RiskLink> cardLinks = [];
    for (Map<String, dynamic> link in links) {
      final String linkSource = link['source'] as String;
      final String linkTitle = link['title'] as String;
      final String linkURL = link['url'] as String;
      //Save link infos into link object, add to link list
      cardLinks
          .add(RiskLink(source: linkSource, title: linkTitle, url: linkURL));
    }
    return cardLinks;
  }

  static List<SubRisk> getSubRisks(List<dynamic> risks) {
    List<SubRisk> subRisksList = [];

    for (Map<String, dynamic> subrisk in risks) {
      final int subriskID = int.parse(subrisk["number"]);
      final String subriskTitle = subrisk["title"];
      final String subriskIntro = subrisk["intro"];

      Map<String, List<String>> subriskSituations =
          readParagraph("situations", subrisk);

      Map<String, List<String>> subriskFactors =
          readParagraph("factors", subrisk);

      Map<String, List<String>> subriskSymptoms =
          readParagraph("symptoms", subrisk);

      final List<String> images = List.from((subrisk['images']) as List);

      subRisksList.add(SubRisk(
          id: subriskID,
          title: subriskTitle,
          intro: subriskIntro,
          situations: subriskSituations,
          factors: subriskFactors,
          symptoms: subriskSymptoms,
          images: images));
    }
    return subRisksList;
  }

  final int number;
  final String shortname;
  final String name;
  final List<SubRisk> subrisks;
  final List<RiskLink> links;

  static Map<String, List<String>> readParagraph(
      String key, Map<String, dynamic> map) {
    Map<String, List<String>> paragraphMap = {};
    final List<Map<String, dynamic>> pargraph = List.from((map[key]) as List);

    for (Map<String, dynamic> point in pargraph) {
      final String line = point["line"];
      List<String> sublines = List.from((point['sublines']) as List);

      if (sublines[0].isEmpty) {
        sublines = [];
      }
      paragraphMap[line] = sublines;
    }

    return paragraphMap;
  }
}

//Object to save link information
class RiskLink {
  const RiskLink({
    required this.source,
    required this.title,
    required this.url,
  });

  final String source;
  final String title;
  final String url;
}

//Class SubRisk keeps individual risk data, including each paragraph in a map
//(for each line), with a string array (for sublines)
class SubRisk {
  const SubRisk({
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
