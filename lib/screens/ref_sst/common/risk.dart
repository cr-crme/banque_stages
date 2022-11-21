import 'package:enhanced_containers/item_serializable.dart';
import 'package:crcrme_banque_stages/screens/ref_sst/risks_cards/widgets/link.dart';
import './risk_data_file_service.dart';

class Risk extends ItemSerializable {
  Risk({
    super.id,
    this.number = 0,
    this.shortname = "",
    this.name = "",
    risks,
    links,
  })  : risks = risks ?? [],
        links = links ?? [];

  Risk copyWith({
    String? id,
    String? shortname,
    String? name,
    List<SubRisk>? risks,
    List<RiskLink>? links,
  }) {
    return Risk(
        id: id ?? this.id,
        shortname: shortname ?? this.shortname,
        name: name ?? this.name,
        risks: risks ?? this.risks,
        links: links ?? this.links);
  }

  @override
  Map<String, dynamic> serializedMap() {
    throw ("Risk should never generate a map, it is read only");
    return {};
  }

  @override
  String toString() {
    return '{Fiche #$id: $name}';
  }

  Risk.fromSerialized(map)
      : number = map["number"],
        shortname = map["shortname"],
        name = map["name"],
        risks = RiskDataFileService.getSubRisks(
            map["subrisks"] as Map<String, dynamic>),
        links =
            RiskDataFileService.getLinks(map["links"] as Map<String, dynamic>),
        super.fromSerialized(map);

  final int number;
  final String shortname;
  final String name;
  final List<SubRisk> risks;
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
