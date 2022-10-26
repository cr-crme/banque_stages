import 'package:crcrme_banque_stages/screens/ref_sst/common/job_sst.dart';
import 'package:crcrme_banque_stages/screens/ref_sst/common/card_sst.dart';
import 'package:crcrme_banque_stages/screens/ref_sst/common/skill_sst.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/src/mock.dart';

import 'package:crcrme_banque_stages/screens/ref_sst/common/proxy_ref_sst.dart';

import 'jobProxy_test.mocks.dart';

@GenerateMocks([jobsProxy])
void main() {
  List<JobSST> createDummyData() {
    Map<String, bool> dummy_list_risk = {};
    List<SkillSST> dummy_list_skill = <SkillSST>[];
    List<JobSST> joblist_dummy = <JobSST>[];

    for (int i = 0; i < 10; i++) {
      dummy_list_risk['$i'] = true;
    }

    dummy_list_skill = List<SkillSST>.filled(
        10,
        new SkillSST(
            name: 'skill name',
            code: 0,
            criterias: List<String>.filled(5, 'skill criteria'),
            tasks: List<String>.filled(5, 'skill Tasks'),
            risks: dummy_list_risk));

    for (int i = 0; i < 10; i++) {
      joblist_dummy.add(new JobSST(
          code: i,
          name: 'Job name $i',
          skills: dummy_list_skill,
          questions: List<int>.filled(5, 0)));
    }
    return joblist_dummy;
  }

  late MockjobsProxy jobProxy;
  List<JobSST> dummy_list_job = <JobSST>[];

  setUpAll(() {
    jobProxy = MockjobsProxy();
    dummy_list_job = createDummyData();
    when(jobProxy.getList()).thenReturn(dummy_list_job);
  });

  group('jobProxy', () {
    test('Test get list risks : return type', () {
      when(jobProxy.getList()).thenReturn(dummy_list_job);
      expect(jobProxy.getList(), isList);
    });

    test('Test get list risks : number object list', () {
      when(jobProxy.getList()).thenReturn(dummy_list_job);
      expect(jobProxy.getList().length, 10);
    });
  });
}
