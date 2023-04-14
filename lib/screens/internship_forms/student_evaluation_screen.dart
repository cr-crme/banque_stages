import 'package:flutter/material.dart';

import '/common/providers/internships_provider.dart';
import '/common/providers/students_provider.dart';
import 'student_steps/generic_questions.dart';
import 'student_steps/student_form_controller.dart';

class StudentEvaluationScreen extends StatefulWidget {
  const StudentEvaluationScreen({super.key, required this.internshipId});

  final String internshipId;

  @override
  State<StudentEvaluationScreen> createState() =>
      _StudentEvaluationScreenState();
}

class _StudentEvaluationScreenState extends State<StudentEvaluationScreen> {
  final _formController = StudentFormController();

  @override
  Widget build(BuildContext context) {
    final internship = InternshipsProvider.of(context)[widget.internshipId];
    final allStudents = StudentsProvider.of(context);
    if (!allStudents.hasId(internship.studentId)) {
      return Container();
    }
    final student = allStudents[internship.studentId];

    return Scaffold(
      appBar: AppBar(
        title: Text('Évaluation de ${student.fullName}'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GenericQuestions(
              internship: internship,
              formController: _formController,
            ),
          ],
        ),
      ),
    );
  }
}
