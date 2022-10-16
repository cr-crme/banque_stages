// ignore_for_file: non_constant_identifier_names

import 'package:crcrme_banque_stages/screens/ref_sst/common/risk_sst.dart';

class SkillSST {
  SkillSST(
      {required this.skill_name,
      required this.skill_code,
      required this.skill_criterias,
      required this.skill_tasks,
      required this.skill_risks}); //There are sometimes no risks

  final String skill_name;
  final int skill_code;
  final List<String> skill_criterias;
  final List<String> skill_tasks;
  final List<RiskSST> skill_risks;

  get name => skill_name;
  get code => skill_code;
  get criterias => skill_criterias;
  get tasks => skill_tasks;
  get risks => skill_risks;

  @override
  String toString() {
    return '{Competence #$skill_code: $skill_name}';
  }
}
