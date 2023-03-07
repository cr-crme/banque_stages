import '/screens/ref_sst/common/skill_sst.dart';

class JobSST {
  const JobSST({
    required this.code,
    required this.name,
    required this.skills,
    required this.questions,
    this.category, //Future proofing
  });

  final int code;
  final String name;
  final List<SkillSST> skills;
  final List<int> questions;
  final String? category;

  @override
  String toString() {
    return '{Job #$code: $name}';
  }
}
