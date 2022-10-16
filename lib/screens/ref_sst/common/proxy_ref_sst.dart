// ignore_for_file: non_constant_identifier_names
import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'dart:ffi';
import 'package:crcrme_banque_stages/screens/ref_sst/common/job_sst.dart';
import 'package:crcrme_banque_stages/screens/ref_sst/common/risk_sst.dart';
import 'package:crcrme_banque_stages/screens/ref_sst/common/skill_sst.dart';

class ProxySST {
  String data = readJson('assets/dummy_sst_risks.json').toString();

  /*/fromJson factory constructor converts json object in variables immediatly
  factory RiskSST.fromJson(Map<String, dynamic> data) {
    final int id = data['fiche'] as int;
    final String title = data['name'] as String;
    final String desc = data['description'] as String;

    return RiskSST(card_id: id, risk_title: title, risk_desc: desc);
  }*/

}

Future<String> readJson(path) async {
  final String response = await rootBundle.loadString(path);
  final data = await json.decode(response);

  return data;
}
