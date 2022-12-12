import 'package:flutter/material.dart';

import '/common/models/student.dart';

class InternshipPage extends StatefulWidget {
  const InternshipPage({
    super.key,
    required this.student,
  });

  final Student student;

  @override
  State<InternshipPage> createState() => _InternshipPageState();
}

class _InternshipPageState extends State<InternshipPage> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}