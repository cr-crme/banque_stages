import 'package:crcrme_banque_stages/crcrme_enhanced_containers/lib/item_serializable.dart';
import '/misc/job_data_file_service.dart';

class CardSST extends ItemSerializable {
  CardSST({
    super.id,
    this.shortname = "",
    this.name = "",
    risks,
    links,
  })  : risks = risks ?? [],
        links = links ?? [];

  CardSST copyWith({
    String? id,
    String? shortname,
    String? name,
    List<RiskSST>? risks,
    List<LinkSST>? links,
  }) {
    return CardSST(
        id: id ?? this.id,
        shortname: shortname ?? this.shortname,
        name: name ?? this.name,
        risks: risks ?? this.risks,
        links: links ?? this.links);
  }

  @override
  Map<String, dynamic> serializedMap() {
    throw ("CardSST should never generate a map, it is read only");
    return {};
  }

  @override
  String toString() {
    return '{Fiche #$id: $name}';
  }

  CardSST.fromSerialized(map)
      : id = 5,
        comments = listFromSerialized(map['comments']),
        super.fromSerialized(map);

  static List<String> listFromSerialized(List? list) {
    return (list ?? []).map((e) => e.toString()).toList();
  }

  static double doubleFromSerialized(num? number, {double defaultValue = 0}) {
    if (number is int) return number.toDouble();
    return (number ?? defaultValue) as double;
  }

  final String shortname;
  final String name;
  final List<RiskSST> risks;
  final List<LinkSST> links;
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
