import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '/common/models/student.dart';
import '/common/providers/students_provider.dart';
import '/common/widgets/dialogs/confirm_pop_dialog.dart';
import '/router.dart';
import '/screens/student/pages/skills_page.dart';
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

  late IconButton? _actionButton;

  final _aboutPageKey = GlobalKey<AboutPageState>();
  final _internshipPageKey = GlobalKey<InternshipsPageState>();
  final _skillsPageKey = GlobalKey<SkillsPageState>();

  Future<void> _navigateToAddInternship() async {
    final student =
        StudentsProvider.of(context, listen: false).fromId(widget.id);
    if (!student.hasActiveInternship(context)) {
      GoRouter.of(context).goNamed(
        Screens.internshipEnrollementFromStudent,
        params: Screens.params(widget.id),
      );
      return;
    }
    await showDialog(
        context: context,
        builder: (BuildContext context) => const AlertDialog(
              title: Text('L\'élève a déjà un stage'),
              content: Text(
                  'L\'élève est déjà inscrit comme stagiaire dans une autre '
                  'entreprise. \nMettre fin au stage actuel pour l\'inscrire '
                  'dans un nouveau milieu.'),
            ));
  }

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

  Future<void> _updateActionButton() async {
    late Icon? icon;

    if (_tabController.index == 0) {
      icon = null;
      // This was disabled for security reasons
      // icon = _aboutPageKey.currentState?.editing ?? false
      //     ? const Icon(Icons.save)
      //     : const Icon(Icons.edit);
    } else if (_tabController.index == 1) {
      icon = const Icon(Icons.add);
    } else if (_tabController.index == 2) {
      icon = const Icon(Icons.add);
    }

    _actionButton = icon == null
        ? null
        : IconButton(
            icon: icon,
            onPressed: () async {
              if (_tabController.index == 0) {
                await _aboutPageKey.currentState?.toggleEdit();
              } else if (_tabController.index == 1) {
                await _navigateToAddInternship();
              }
              await _updateActionButton();
            },
          );
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _updateActionButton();
    _tabController.addListener(() => _updateActionButton());
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
              actions: _actionButton == null ? null : [_actionButton!],
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
