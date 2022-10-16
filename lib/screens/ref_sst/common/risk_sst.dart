// ignore_for_file: non_constant_identifier_names

//Risk class converts dummy json risk data into risk objects
class RiskSST {
  RiskSST(
      {required this.card_id,
      required this.risk_shortname,
      required this.risk_title,
      this.risk_desc,
      this.risk_picture});

  final int card_id;
  final String risk_shortname;
  final String risk_title;
  final String? risk_desc;
  final String? risk_picture;

  //getters
  get id => card_id;
  get shortname => risk_shortname;
  get title => risk_title;
  get desc => risk_desc;
  get picture => risk_picture;

  //Tostring displays risk id and title
  @override
  String toString() {
    return '{Fiche #$card_id: $risk_title}';
  }
}
