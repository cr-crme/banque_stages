

import 'package:crcrme_banque_stages/screens/ref_sst/common/risk_sst.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:crcrme_banque_stages/screens/ref_sst/common/proxy_ref_sst.dart';

import 'proxy_ref_sst_test.mocks.dart';

@GenerateMocks([ProxySST])


void main() {
 late ProxySST proxy;
  setUp((){
    proxy = MockProxySST();
  });
    group("Proxy", () {

      test('Test get list risks : retrun type', () {
      expect(ProxySST.getRiskList(),isList);
      });

      test('Test get list risks : number object list', () {

        expect(ProxySST.getRiskList().length, 4);
      });

      test('Test get list jobs : retrun type', () {
      expect(ProxySST.getJobList(),isList);
      });

      test('Test get list jobs : number object list', () {

        expect(ProxySST.getRiskList().length, 4);
      });

    });


}
