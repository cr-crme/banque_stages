import 'package:stagess/screens/ref_sst/common/skill_sst.dart';

class JobSst {
  const JobSst({
    required this.code,
    required this.name,
    required this.skills,
    required this.questions,
    this.category, //Future proofing
  });

  final int code;
  final String name;
  final List<SkillSst> skills;
  final List<int> questions;
  final String? category;

  @override
  String toString() {
    return '{Job #$code: $name}';
  }
}
