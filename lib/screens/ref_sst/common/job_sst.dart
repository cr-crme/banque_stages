// ignore_for_file: non_constant_identifier_names

import 'dart:ffi';
import 'package:crcrme_banque_stages/screens/ref_sst/common/skill_sst.dart';

class JobSST {
  JobSST(
      {required this.jobCode,
      required this.jobName,
      required this.jobSkills,
      required this.jobQuestions,
      this.jobCategory}); //Future proofing

  final int jobCode;
  final String jobName;
  final List<SkillSST> jobSkills;
  final List<int> jobQuestions;
  final String? jobCategory;

  get name => jobName;
  get code => jobCode;
  get skills => jobSkills;
  get questions => jobQuestions;
  get category => jobCategory;

  @override
  String toString() {
    return '{Job #$jobCode: $jobName}';
  }
}
