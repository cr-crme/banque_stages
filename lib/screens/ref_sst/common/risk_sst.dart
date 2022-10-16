// ignore_for_file: non_constant_identifier_names

//Risk class converts dummy json risk data into risk objects
class RiskSST {
  RiskSST(
      {required this.cardID,
      required this.riskShortname,
      required this.riskTitle,
      this.riskDesc,
      this.riskPicture});

  final int cardID;
  final String riskShortname;
  final String riskTitle;
  final String? riskDesc;
  final String? riskPicture;

  //getters
  get id => cardID;
  get shortname => riskShortname;
  get title => riskTitle;
  get desc => riskDesc;
  get picture => riskPicture;

  //Tostring displays risk id and title
  @override
  String toString() {
    return '{Fiche #$cardID: $riskTitle}';
  }
}
