import 'package:crcrme_banque_stages/screens/ref_sst/common/job_sst.dart';
import 'package:crcrme_banque_stages/screens/ref_sst/common/risk_sst.dart';
import 'package:crcrme_banque_stages/screens/ref_sst/common/skill_sst.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/src/mock.dart';
import 'package:crcrme_banque_stages/screens/ref_sst/common/proxy_ref_sst.dart';

import 'proxy_ref_sst_test.mocks.dart';

@GenerateMocks([ProxySST])
void main() {
  late MockProxySST proxy;
  List<RiskSST> dummy_list_risk = <RiskSST>[];
  List<JobSST> dummy_list_job = <JobSST>[];
  List<SkillSST> dummy_list_skill = <SkillSST>[];
  setUpAll(() {
    proxy = MockProxySST();
    dummy_list_risk
        .add(new RiskSST(id: 0, shortname: 'Test IDK', title: 'TITLE'));
    dummy_list_skill.add(new SkillSST(
        name: 'skill name',
        code: 0,
        criterias: List<String>.filled(5, 'skill criteria'),
        tasks: List<String>.filled(5, 'skill Tasks'),
        risks: dummy_list_risk));
    dummy_list_job.add(new JobSST(
        code: 0001,
        name: 'Job name',
        skills: dummy_list_skill,
        questions: List<int>.filled(5, 0)));
    when(proxy.riskList()).thenReturn(dummy_list_risk);
    when(proxy.jobList()).thenReturn(dummy_list_job);
  });

  group("Proxy", () {
    test('Test get list risks : return type', () {
      when(proxy.riskList()).thenReturn(dummy_list_risk);
      expect(proxy.riskList(), isList);
    });

    test('Test get list risks : number object list', () {
      when(proxy.riskList()).thenReturn(dummy_list_risk);
      expect(proxy.riskList().length, 1);
    });

    test('Test get list jobs : return type', () {
      when(proxy.jobList()).thenReturn(dummy_list_job);
      expect(proxy.jobList(), isList);
    });

    test('Test get list jobs : number object list', () {
      when(proxy.jobList()).thenReturn(dummy_list_job);
      expect(proxy.riskList().length, 1);
    });
  });
}
