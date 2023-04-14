import 'package:flutter/material.dart';

class StudentEvaluationScreen extends StatelessWidget {
  const StudentEvaluationScreen({super.key, required this.internshipId});

  final String internshipId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Évaluation post-stage'),
        leading: Container(),
      ),
      body: Container(),
    );
  }
}
