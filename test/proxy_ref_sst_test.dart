

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
  setUpAll((){
    proxy = MockProxySST();
    dummy_list_risk.add(new RiskSST(cardID: 0, riskShortname: 'Test IDK', riskTitle: 'TITLE'));
    dummy_list_skill.add(new SkillSST(skillName: 'skill name', skillCode: 0, skillCriterias: List<String>.filled(5, 'skill criteria'), skillTasks: List<String>.filled(5, 'skill Tasks'), skillRisks: dummy_list_risk));
    dummy_list_job.add(new JobSST(jobCode: 0001, jobName: 'Job name', jobSkills: dummy_list_skill, jobQuestions: List<int>.filled(5, 0)));
    when(proxy.getRiskList()).thenReturn(dummy_list_risk);
    when(proxy.getJobList()).thenReturn(dummy_list_job);

  });

    group("Proxy", () {

      test('Test get list risks : retrun type', () {
      expect(proxy.getRiskList(),isList);
      });

      test('Test get list risks : number object list', () {
        expect(proxy.getRiskList().length, 4);
      });

      test('Test get list jobs : retrun type', () {
      expect(proxy.getJobList(),isList);
      });

      test('Test get list jobs : number object list', () {

        expect(proxy.getRiskList().length, 4);
      });

    });


}
