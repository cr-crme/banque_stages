// ignore_for_file: non_constant_identifier_names

import 'package:crcrme_banque_stages/screens/ref_sst/common/risk_sst.dart';

class SkillSST {
  SkillSST(
      {required this.skillName,
      required this.skillCode,
      required this.skillCriterias,
      required this.skillTasks,
      required this.skillRisks}); //There are sometimes no risks

  final String skillName;
  final int skillCode;
  final List<String> skillCriterias;
  final List<String> skillTasks;
  final List<RiskSST> skillRisks;

  get name => skillName;
  get code => skillCode;
  get criterias => skillCriterias;
  get tasks => skillTasks;
  get risks => skillRisks;

  @override
  String toString() {
    return '{Competence #$skillCode: $skillName}';
  }
}
