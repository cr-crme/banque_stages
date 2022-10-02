// ignore_for_file: non_constant_identifier_names

//Risk class converts dummy json risk data into risk objects
class Risk {
  Risk({required this.card_id, required this.risk_title, this.risk_desc});
  final int card_id;

  final String risk_title;
  final String? risk_desc;

  //fromJson factory constructor converts json object in variables immediatly
  factory Risk.fromJson(Map<String, dynamic> data) {
    final int id = data['fiche'] as int;
    final String title = data['name'] as String;
    final String desc = data['description'] as String;
    return Risk(card_id: id, risk_title: title, risk_desc: desc);
  }

  //getters
  int get id => card_id;
  String get title => risk_title;
  String? get desc => risk_desc;

  //Tostring displays risk id and title
  @override
  String toString() {
    return '{ $card_id, $risk_title}';
  }
}
