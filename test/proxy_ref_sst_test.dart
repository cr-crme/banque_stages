
import 'package:crcrme_banque_stages/screens/ref_sst/common/job_sst.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:crcrme_banque_stages/screens/ref_sst/common/proxy_ref_sst.dart';

import 'proxy_ref_sst_test.mocks.dart';

@GenerateMocks([ProxySST])

// Works without mocks for now
void main() {
  ProxySST proxy;
  setUp((){
    proxy = MockProxySST();
  });

    test('Test get list risks', () {
      when(MockProxySST().);
          expect(List.from(),  ProxySST.getJobList());
    });
    test('Test get list jobs', () {

      
    });

}
