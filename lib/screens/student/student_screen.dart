import 'package:crcrme_banque_stages/common/models/student.dart';
import 'package:crcrme_banque_stages/common/providers/students_provider.dart';
import 'package:crcrme_banque_stages/common/widgets/dialogs/confirm_pop_dialog.dart';
import 'package:crcrme_banque_stages/screens/student/pages/skills_page.dart';
import 'package:flutter/material.dart';

import 'pages/about_page.dart';
import 'pages/internships_page.dart';

class StudentScreen extends StatefulWidget {
  const StudentScreen({
    super.key,
    required this.id,
    this.initialPage = 0,
  });

  final String id;
  final int initialPage;

  @override
  State<StudentScreen> createState() => _StudentScreenState();
}

class _StudentScreenState extends State<StudentScreen>
    with SingleTickerProviderStateMixin {
  late final _tabController = TabController(length: 3, vsync: this)
    ..index = widget.initialPage;

  final _aboutPageKey = GlobalKey<AboutPageState>();
  final _internshipPageKey = GlobalKey<InternshipsPageState>();
  final _skillsPageKey = GlobalKey<SkillsPageState>();

  void _onTapBack() async {
    if (_tabController.index == 1) {
      for (final key in _internshipPageKey.currentState!.detailKeys) {
        if (key.currentState?.editMode ?? false) {
          final answer = await ConfirmPopDialog.show(context);
          if (!answer || !mounted) return;
          Navigator.of(context).pop();
          return;
        }
      }
    }

    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Student>(
        future: StudentsProvider.fromLimitedId(context, studentId: widget.id),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final student = snapshot.data!;
          return Scaffold(
            appBar: AppBar(
              title: Text(student.fullName),
              leading: IconButton(
                  onPressed: _onTapBack, icon: const Icon(Icons.arrow_back)),
              bottom: TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(icon: Icon(Icons.info_outlined), text: 'À propos'),
                  Tab(icon: Icon(Icons.assignment), text: 'Stages'),
                  Tab(
                      icon: Icon(Icons.card_membership),
                      text: 'Plan formation'),
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
          );
        });
  }
}
