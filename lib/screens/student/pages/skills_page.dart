import 'package:flutter/material.dart';

import '/common/models/student.dart';

class SkillsPage extends StatefulWidget {
  const SkillsPage({super.key, required this.student});

  final Student student;

  @override
  State<SkillsPage> createState() => SkillsPageState();
}

class SkillsPageState extends State<SkillsPage> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
