import 'package:crcrme_banque_stages/screens/ref_sst/common/risk_sst.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/src/mock.dart';

import 'package:crcrme_banque_stages/screens/ref_sst/common/proxy_ref_sst.dart';

import 'riskProxy_test.mocks.dart';

@GenerateMocks([risksProxy])
void main() {
  List<CardSST> createDummyData() {
    List<CardSST> list_dummy = <CardSST>[];
    for (int i = 0; i < 10; i++) {
      list_dummy
          .add(new CardSST(id: i, shortname: "num $i", title: "TITLE $i"));
    }
    return list_dummy;
  }

  late MockrisksProxy riskProxy;

  List<CardSST> dummy_list_risk = <CardSST>[];

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
  });
}
