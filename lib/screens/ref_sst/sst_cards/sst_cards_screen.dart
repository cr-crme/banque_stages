// ignore_for_file: non_constant_identifier_names
//import 'dart:js_util';

import 'package:flutter/material.dart';

import 'widgets/sst_card.dart';
import 'dart:convert';
import '../common/risk_sst.dart';

//Risk list generator
List<RiskSST> generateRisksList() {
  //Hardcoded json, ideally should be read from file, or better, fetched from DB
  const String data =
      '{     "risks":[         {             "fiche": 1,             "name": "Risques Chimiques",             "description" : ""         },         {             "fiche": 2,             "name": "Risques Biologiques",             "description" : ""         },         {             "fiche": 3,             "name": "Risques liés aux machines et aux équipements",             "description" : ""         },         {             "fiche": 4,             "name": "Risques de chute de hauteur et de plain-pied",             "description" : ""         },         {             "fiche": 5,             "name": "Risques liés aux chutes d\'objets",             "description" : ""         },         {             "fiche": 6,             "name": "Risques liés aux déplacements",             "description" : ""         },         {             "fiche": 7,             "name": "Risques liés aux postures contraignantes",             "description" : ""         },         {             "fiche": 8,             "name": "Risques liés aux mouvements répétitifs, pressions de contact et chocs",             "description" : ""         },         {             "fiche": 9,             "name": "Risques liés à la manutention",             "description" : ""         },         {             "fiche": 10,             "name": "Risques psychosociaux et de violence",             "description" : ""         },         {             "fiche": 11,             "name": "Risques liés aux bruits",             "description" : ""         },         {             "fiche": 12,             "name": "Risques liés à l\'exposition au froid et à la chaleur",             "description" : ""         },         {             "fiche": 13,             "name": "Risques liés aux vibrations",             "description" : ""         },         {             "fiche": 14,             "name": "Autres risques à connaitre",             "description" : ""         }     ] }';

  //convert json string into list of json objects
  var parsedRisks = jsonDecode(data)['risks'] as List;

  //convert json objects into risk objects
  return parsedRisks.map((riskJson) => RiskSST.fromJson(riskJson)).toList();
}

//Generation of the risk list
List<RiskSST> risksList = generateRisksList();

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
          padding: const EdgeInsets.all(6),
          children: [
            //Generating risk widgets from risk objects list
            for (RiskSST risk in risksList) SSTCard(risk.id, risk.title)
          ],
        ));
  }
}
