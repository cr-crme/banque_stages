import 'package:crcrme_banque_stages/common/models/student.dart';
import 'package:crcrme_banque_stages/common/providers/students_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StudentScreen extends StatefulWidget {
  const StudentScreen({super.key});

  static const route = "/student-details";

  @override
  State<StudentScreen> createState() => _StudentScreenState();
}

class _StudentScreenState extends State<StudentScreen> {
  late final _studentId = ModalRoute.of(context)!.settings.arguments as String;

  @override
  Widget build(BuildContext context) {
    return Selector<StudentsProvider, Student>(
      builder: (context, student, _) => Scaffold(
        appBar: AppBar(
          title: Text(student.name),
        ),
      ),
      selector: (context, students) => students[_studentId],
    );
  }
}
