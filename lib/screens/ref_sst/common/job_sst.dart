// ignore_for_file: non_constant_identifier_names

import 'dart:ffi';
import 'package:crcrme_banque_stages/screens/ref_sst/common/skill_sst.dart';

class JobSST {
  JobSST(
      {required this.job_code,
      required this.job_name,
      required this.job_skills,
      required this.job_questions,
      this.job_category}); //Future proofing

  final int job_code;
  final String job_name;
  final List<SkillSST> job_skills;
  final List<Bool> job_questions;
  final String? job_category;

  get name => job_name;
  get code => job_code;
  get skills => job_skills;
  get questions => job_questions;

  @override
  String toString() {
    return '{Job #$job_code: $job_name}';
  }
}
