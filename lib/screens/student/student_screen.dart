import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/common/models/student.dart';
import '/common/providers/students_provider.dart';
import '/screens/student/pages/internship_page.dart';
import '/screens/student/pages/skills_page.dart';
import 'pages/about_page.dart';

class StudentScreen extends StatefulWidget {
  const StudentScreen({super.key});

  static const route = "/student-details";

  @override
  State<StudentScreen> createState() => _StudentScreenState();
}

class _StudentScreenState extends State<StudentScreen>
    with SingleTickerProviderStateMixin {
  late final _studentId = ModalRoute.of(context)!.settings.arguments as String;

  late final _tabController = TabController(length: 3, vsync: this);

  @override
  Widget build(BuildContext context) {
    return Selector<StudentsProvider, Student>(
      builder: (context, student, _) => Scaffold(
        appBar: AppBar(
          title: Text(student.name),
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(icon: Icon(Icons.info_outlined), text: "À propos"),
              Tab(icon: Icon(Icons.assignment), text: "Stages"),
              Tab(icon: Icon(Icons.person), text: "Compétences"),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            AboutPage(student: student),
            InternshipPage(student: student),
            SkillsPage(student: student),
          ],
        ),
      ),
      selector: (context, students) => students[_studentId],
    );
  }
}
