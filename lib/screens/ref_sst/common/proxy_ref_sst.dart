// ignore_for_file: non_constant_identifier_names
import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'dart:ffi';
import 'package:crcrme_banque_stages/screens/ref_sst/common/job_sst.dart';
import 'package:crcrme_banque_stages/screens/ref_sst/common/risk_sst.dart';
import 'package:crcrme_banque_stages/screens/ref_sst/common/skill_sst.dart';

class ProxySST {

  /*ProxySST({
    required 
  })*/

  //fromJson factory constructor converts json object in variables immediatly
  /*factory ProxySST.fromJson(Map<String, dynamic> data) {
    final int id = data['fiche'] as int;
    final String title = data['name'] as String;
    final String desc = data['description'] as String;

    return ProxySST(card_id: id, risk_title: title, risk_desc: desc);
  }*/

  static List<RiskSST> riskList{
    String risk_data = readJson('assets/dummy_sst_risks.json').toString();


    return null;
  }
  static List<JobSST> jobList{
    String jobs_data = readJson('assets/jobs-data.json').toString();

    
    return null;
  }

}

Future<String> readJson(path) async {
  final String response = await rootBundle.loadString(path);
  final data = await json.decode(response);

  return data;
}

/*/Risk list generator
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
List<RiskSST> risksList = generateRisksList();*/
