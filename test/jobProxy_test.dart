import 'package:crcrme_banque_stages/screens/ref_sst/common/job_sst.dart';
import 'package:crcrme_banque_stages/screens/ref_sst/common/risk_sst.dart';
import 'package:crcrme_banque_stages/screens/ref_sst/common/skill_sst.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/src/mock.dart';

import 'package:crcrme_banque_stages/screens/ref_sst/common/proxy_ref_sst.dart';

import 'jobProxy_test.mocks.dart';

@GenerateMocks([jobsProxy])

void main() {
  late MockjobsProxy jobProxy;
  Map<String,bool> dummy_list_risk = {};
  List<JobSST> dummy_list_job = <JobSST>[];
  List<SkillSST> dummy_list_skill = <SkillSST>[];



  setUpAll(() {
    jobProxy = MockjobsProxy();

    dummy_list_risk['key'] = true;
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

    when(jobProxy.getList()).thenReturn(dummy_list_job);


  });

  group('jobProxy', ()
  {
    test('Test get list risks : return type', () {
      when(jobProxy.getList()).thenReturn(dummy_list_job);
      expect(jobProxy.getList(), isList);
    });

    test('Test get list risks : number object list', () {
      when(jobProxy.getList()).thenReturn(dummy_list_job);
      expect(jobProxy.getList().length, 1);
    });
  });
}