import 'dart:io';

import 'package:crcrme_banque_stages/screens/ref_sst/common/card_sst.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/src/mock.dart';

import 'package:crcrme_banque_stages/screens/ref_sst/common/proxy_ref_sst.dart';

import 'risk_proxy_test.mocks.dart';

@GenerateMocks([CardsProxy])
void main() {
  Map<String, List<String>> filledMap(String name, int items) {
    Map<String, List<String>> list_map = {};

    for (int i = 0; i < items; i++) {
      list_map["$name $i"] = List<String>.filled(3, "lorem ipsum");
    }

    return list_map;
  }

  List<Risk> createDummyData() {
    List<Risk> list_dummy = <Risk>[];
    List<SubRisk> list_risk = <SubRisk>[];
    List<RiskLink> list_link = <RiskLink>[];

    list_link = List<RiskLink>.filled(
        3, new RiskLink(source: "Source", title: "Title", url: "url"));

    Map<String, List<String>> list_situation = filledMap("Situation", 4);
    Map<String, List<String>> list_factor = filledMap("Factor", 3);
    Map<String, List<String>> list_symptoms = filledMap("Symptom", 4);

    for (int i = 0; i < 10; i++) {
      list_risk.add(new SubRisk(
          id: i,
          title: "title $i",
          intro: "intro $i",
          situations: list_situation,
          factors: list_factor,
          symptoms: list_symptoms,
          images: List<String>.filled(2, "images")));
    }

    for (int i = 0; i < 10; i++) {
      list_dummy.add(new Risk(
          id: i,
          shortname: "num $i",
          name: "TITLE $i",
          links: list_link,
          risks: list_risk));
    }
    return list_dummy;
  }

  late MockrisksProxy riskProxy;

  List<Risk> dummy_list_risk = <Risk>[];

  setUpAll(() {
    riskProxy = MockrisksProxy();
    dummy_list_risk = createDummyData();

    when(riskProxy.getList()).thenReturn(dummy_list_risk);
  });

  group('risksProxy', () {
    test('Test get list risks : return type', () {
      when(riskProxy.getList()).thenReturn(dummy_list_risk);
      expect(riskProxy.getList(), isList);
    });

    test('Test get list risks : number object list', () {
      when(riskProxy.getList()).thenReturn(dummy_list_risk);
      expect(riskProxy.getList().length, 10);
    });

    test('Test non-null values', () {
      when(riskProxy.getList()).thenReturn(dummy_list_risk);
      String error = "";
      if (dummy_list_risk[0] == null) {
        error += "Id is null\n";
      }
      if (dummy_list_risk[1] == null) {
        error += "Shortname is null\n";
      }
      if (dummy_list_risk[2] == null) {
        error += "Name is null\n";
      }
      if (dummy_list_risk[4] == null) {
        error += "Links is null\n";
      }
      if (dummy_list_risk[5] == null) {
        error += "Risks is null\n";
      }
      expect("", error);
    });
  });
}
