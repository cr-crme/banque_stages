import 'dart:convert';

import 'package:crcrme_banque_stages/screens/ref_sst/common/Risk.dart';
import 'package:flutter/services.dart';

abstract class RiskDataFileService {
  static List<Risk> _risks = [];
  static List<Risk> get risks => _risks;

  static Future<void> loadData() async {
    final file = await rootBundle.loadString("assets/risk-data.json");
    final json = jsonDecode(file) as List;

    _risks = List.from(
      json.map((e) => Risk.fromSerialized(e)),
      growable: false,
    );
  }

  static Risk fromId(String id) {
    return _risks.firstWhere((risk) => risk.id == id);
  }
}
