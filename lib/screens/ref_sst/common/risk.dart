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
        links = getLinks(map["links"] as Map<String, dynamic>),
        subrisks = getSubRisks(map["subrisks"] as Map<String, dynamic>),
        super.fromSerialized(map);

  static List<RiskLink> getLinks(Map<String, dynamic> links) {
    List<RiskLink> cardLinks = [];
    for (Map<String, dynamic> link in links.values) {
      final String linkSource = link['source'] as String;
      final String linkTitle = link['title'] as String;
      final String linkURL = link['url'] as String;
      //Save link infos into link object, add to link list
      cardLinks
          .add(RiskLink(source: linkSource, title: linkTitle, url: linkURL));
    }
    return cardLinks;
  }

  static List<SubRisk> getSubRisks(Map<String, dynamic> map) {
    List<SubRisk> subRisksList = [];

    final List<Map<String, dynamic>> subrisks =
        List.from((map['subrisks']) as List);

    for (Map<String, dynamic> subrisk in subrisks) {
      final int subriskID = int.parse(subrisk["number"]);
      final String subriskTitle = subrisk["title"];
      final String subriskIntro = subrisk["intro"];

      Map<String, List<String>> subriskSituations = {};

      final List<Map<String, List<String>>> situations =
          List.from((map['situations']) as List);

      for (Map<String, dynamic> situation in situations) {
        final String line = situation["line"];
        List<String> sublines = List.from((map['sublines']) as List);

        if (sublines[0].isEmpty) {
          sublines = [];
        }
        subriskSituations[line] = sublines;
      }

      Map<String, List<String>> subriskFactors = {};

      final List<Map<String, List<String>>> factors =
          List.from((map['factors']) as List);

      for (Map<String, dynamic> factor in factors) {
        final String lineFactor = factor["line"];
        List<String> sublinesFactor = List.from((map['sublines']) as List);
        subriskFactors[lineFactor] = sublinesFactor;
      }

      Map<String, List<String>> subriskSymptoms = {};
      final List<Map<String, List<String>>> symptoms =
          List.from((map['symptoms']) as List);

      for (Map<String, dynamic> symptom in symptoms) {
        final String lineSymptom = symptom["line"];
        List<String> sublinesSymptoms = List.from((map["sublines"]) as List);
        subriskSymptoms[lineSymptom] = sublinesSymptoms;
      }

      final List<String> images = List.from((map['images']) as List);

      subRisksList.add(SubRisk(
          id: subriskID,
          title: subriskTitle,
          intro: subriskIntro,
          situations: subriskSituations,
          factors: subriskFactors,
          symptoms: subriskSymptoms,
          images: images));
    }

    /* for (MapEntry<String, dynamic> subRisk in map.entries) {
      final int riskID = int.parse(subRisk.key); //Save key as ID
      final String riskTitle = subRisk.value['title'] as String;
      final String riskIntro = subRisk.value['intro'] as String;
      //Save list of images as list of strings
      final List<String> images = (subRisk.value['images'] as List)
          .map((item) => item as String)
          .toList();
      //For each situation
      Map<String, List<String>> riskSituations = {};
      final Map<String, dynamic> situations =
          subRisk.value['situations'] as Map<String, dynamic>;
      for (MapEntry<String, dynamic> situation in situations.entries) {
        //Save key as the line
        final String situationLine = situation.key;
        //Save corresponding string list as the sublines (will often be emtpy)
        final List<String> situationSublines =
            (situation.value as List).map((item) => item as String).toList();
        riskSituations[situationLine] = situationSublines;
      }
      //For each factor, do the same
      Map<String, List<String>> riskFactors = {};
      final Map<String, dynamic> factors =
          subRisk.value['factors'] as Map<String, dynamic>;
      for (MapEntry<String, dynamic> factor in factors.entries) {
        final String factorLine = factor.key;
        final List<String> factorSublines =
            (factor.value as List).map((item) => item as String).toList();
        riskFactors[factorLine] = factorSublines;
      }
      //For each symptom, do the same
      Map<String, List<String>> riskSymptoms = {};
      final Map<String, dynamic> symptoms =
          subRisk.value['symptoms'] as Map<String, dynamic>;
      for (MapEntry<String, dynamic> symptom in symptoms.entries) {
        final String symptomLine = symptom.key;
        final List<String> symptomSublines =
            (symptom.value as List).map((item) => item as String).toList();
        riskSymptoms[symptomLine] = symptomSublines;
      }
      //Put everything in a risk object and add to the list of risks
      subRisksList.add(SubRisk(
          id: riskID,
          title: riskTitle,
          intro: riskIntro,
          situations: riskSituations,
          factors: riskFactors,
          symptoms: riskSymptoms,
          images: images));
    }*/
    return subRisksList;
  }

  final int number;
  final String shortname;
  final String name;
  final List<SubRisk> subrisks;
  final List<RiskLink> links;
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
