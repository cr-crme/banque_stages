// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';

import 'widgets/sst_card.dart';
import 'dart:convert';

class Risk {
  Risk({required this.card_id, required this.risk_title, this.risk_desc});
  final int card_id;
  final String risk_title;
  final String? risk_desc;

  factory Risk.fromJson(Map<String, dynamic> data) {
    final int id = data['fiche'] as int;
    final String title = data['name'] as String;
    final String desc = data['description'] as String;
    return Risk(card_id: id, risk_title: title, risk_desc: desc);
  }

  int get id => card_id;
  String get title => risk_title;
  String? get desc => risk_desc;
  @override
  String toString() {
    return '{ $card_id, $risk_title}';
  }
}

List<Risk> generateRisksList() {
  const String data =
      '{     "risks":[         {             "fiche": 1,             "name": "Risques Chimiques",             "description" : ""         },         {             "fiche": 2,             "name": "Risques Biologiques",             "description" : ""         },         {             "fiche": 3,             "name": "Risques liés aux machines et aux équipements",             "description" : ""         },         {             "fiche": 4,             "name": "Risques de chute de hauteur et de plain-pied",             "description" : ""         },         {             "fiche": 5,             "name": "Risques liés aux chutes d\'objets",             "description" : ""         },         {             "fiche": 6,             "name": "Risques liés aux déplacements",             "description" : ""         },         {             "fiche": 7,             "name": "Risques liés aux postures contraignantes",             "description" : ""         },         {             "fiche": 8,             "name": "Risques liés aux mouvements répétitifs, pressions de contact et chocs",             "description" : ""         },         {             "fiche": 9,             "name": "Risques liés à la manutention",             "description" : ""         },         {             "fiche": 10,             "name": "Risques psychosociaux et de violence",             "description" : ""         },         {             "fiche": 11,             "name": "Risques liés aux bruits",             "description" : ""         },         {             "fiche": 12,             "name": "Risques liés à l\'exposition au froid et à la chaleur",             "description" : ""         },         {             "fiche": 13,             "name": "Risques liés aux vibrations",             "description" : ""         },         {             "fiche": 14,             "name": "Autres risques à connaitre",             "description" : ""         }     ] }';
  var parsedRisks = jsonDecode(data)['risks'] as List;
  return parsedRisks.map((riskJson) => Risk.fromJson(riskJson)).toList();
}

List<Risk> risksList = generateRisksList();

/*Future<String> getJson() {
  return rootBundle.loadString('assets/data.json');
}*/

//String data = List<Risk> risksList = jsonDecode(data)['risks'] as List; //generateRisksList();

//----------------------------------------

class SSTCardsScreen extends StatefulWidget {
  const SSTCardsScreen({Key? key}) : super(key: key);

  static const route = "/sst-cards";

  @override
  State<SSTCardsScreen> createState() => _SSTCardsScreenState();
}

class _SSTCardsScreenState extends State<SSTCardsScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Fiches de risques"),
        ),
        body: ListView(
          padding: const EdgeInsets.all(8),
          children: [for (Risk risk in risksList) SSTCard(risk.id, risk.title)],
        ));
  }
}
