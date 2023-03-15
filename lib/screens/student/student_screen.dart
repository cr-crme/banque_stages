import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/common/models/student.dart';
import '/common/providers/students_provider.dart';
import 'pages/internships_page.dart';
import '/screens/student/pages/skills_page.dart';
import 'pages/about_page.dart';

class StudentScreen extends StatefulWidget {
  const StudentScreen({super.key, required this.id});

  final String id;

  @override
  State<StudentScreen> createState() => _StudentScreenState();
}

class _StudentScreenState extends State<StudentScreen>
    with SingleTickerProviderStateMixin {
  late final _tabController = TabController(length: 3, vsync: this);

  late IconButton _actionButton;

  final _aboutPageKey = GlobalKey<AboutPageState>();
  final _internshipPageKey = GlobalKey<InternshipsPageState>();
  final _skillsPageKey = GlobalKey<SkillsPageState>();

  void _updateActionButton() {
    late Icon icon;

    if (_tabController.index == 0) {
      icon = _aboutPageKey.currentState?.editing ?? false
          ? const Icon(Icons.save)
          : const Icon(Icons.edit);
    } else if (_tabController.index == 1) {
      icon = const Icon(Icons.add);
    } else if (_tabController.index == 2) {
      icon = const Icon(Icons.add);
    }

    setState(() {
      _actionButton = IconButton(
        icon: icon,
        onPressed: () {
          if (_tabController.index == 0) {
            _aboutPageKey.currentState?.toggleEdit();
          } else if (_tabController.index == 1) {
            // _internshipPageKey.currentState?.toggleEdit();
          } else if (_tabController.index == 2) {
            // _skillsPageKey.currentState?.addJob();
          }

          _updateActionButton();
        },
      );
    });
  }

  @override
  void initState() {
    super.initState();
    _updateActionButton();
    _tabController.addListener(() => _updateActionButton());
  }

  @override
  Widget build(BuildContext context) {
    return Selector<StudentsProvider, Student>(
      builder: (context, student, _) => Scaffold(
        appBar: AppBar(
          title: Text(student.fullName),
          actions: [_actionButton],
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(icon: Icon(Icons.info_outlined), text: "À propos"),
              Tab(icon: Icon(Icons.assignment), text: "Stages"),
              Tab(icon: Icon(Icons.person), text: "Plan de\nformation"),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            AboutPage(key: _aboutPageKey, student: student),
            InternshipsPage(key: _internshipPageKey, student: student),
            SkillsPage(key: _skillsPageKey, student: student),
          ],
        ),
      ),
      selector: (context, students) => students[widget.id],
    );
  }
}
