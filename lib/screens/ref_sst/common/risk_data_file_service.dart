import 'package:collection/collection.dart';
import 'package:crcrme_banque_stages/screens/ref_sst/common/risk.dart';
import 'dart:convert';

//import 'package:crcrme_banque_stages/crcrme_enhanced_containers/lib/item_serializable.dart';
import 'package:flutter/services.dart';

class RiskDataFileService {
  static List<RiskLink> getLinks(Map<String, dynamic> map) {
    List<RiskLink> cardLinks = [];
    for (Map<String, dynamic> link in map.values) {
      final String linkSource = link['source'] as String;
      final String linkTitle = link['title'] as String;
      final String linkURL = link['url'] as String;
      //Save link infos into link object, add to link list
      cardLinks
          .add(RiskLink(source: linkSource, title: linkTitle, url: linkURL));
    }
    return cardLinks;
  }

  static List<SubRisk> getSubRisks(Map<String, dynamic> map) {
    List<SubRisk> subRisksList = [];
    for (MapEntry<String, dynamic> subRisk in map.entries) {
      final int riskID = int.parse(subRisk.key); //Save key as ID
      final String riskTitle = subRisk.value['title'] as String;
      final String riskIntro = subRisk.value['intro'] as String;
      //Save list of images as list of strings
      final List<String> images = (subRisk.value['images'] as List)
          .map((item) => item as String)
          .toList();
      //For each situation
      Map<String, List<String>> riskSituations = {};
      final Map<String, dynamic> situations =
          subRisk.value['situations'] as Map<String, dynamic>;
      for (MapEntry<String, dynamic> situation in situations.entries) {
        //Save key as the line
        final String situationLine = situation.key;
        //Save corresponding string list as the sublines (will often be emtpy)
        final List<String> situationSublines =
            (situation.value as List).map((item) => item as String).toList();
        riskSituations[situationLine] = situationSublines;
      }
      //For each factor, do the same
      Map<String, List<String>> riskFactors = {};
      final Map<String, dynamic> factors =
          subRisk.value['factors'] as Map<String, dynamic>;
      for (MapEntry<String, dynamic> factor in factors.entries) {
        final String factorLine = factor.key;
        final List<String> factorSublines =
            (factor.value as List).map((item) => item as String).toList();
        riskFactors[factorLine] = factorSublines;
      }
      //For each symptom, do the same
      Map<String, List<String>> riskSymptoms = {};
      final Map<String, dynamic> symptoms =
          subRisk.value['symptoms'] as Map<String, dynamic>;
      for (MapEntry<String, dynamic> symptom in symptoms.entries) {
        final String symptomLine = symptom.key;
        final List<String> symptomSublines =
            (symptom.value as List).map((item) => item as String).toList();
        riskSymptoms[symptomLine] = symptomSublines;
      }
      //Put everything in a risk object and add to the list of risks
      subRisksList.add(SubRisk(
          id: riskID,
          title: riskTitle,
          intro: riskIntro,
          situations: riskSituations,
          factors: riskFactors,
          symptoms: riskSymptoms,
          images: images));
    }
    return subRisksList;
  }
}
