import 'package:collection/collection.dart';
import 'package:common_flutter/helpers/responsive_service.dart';
import 'package:crcrme_banque_stages/common/extensions/students_extension.dart';
import 'package:crcrme_banque_stages/common/provider_helpers/students_helpers.dart';
import 'package:crcrme_banque_stages/common/widgets/main_drawer.dart';
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

  Future<bool> _preventIfEditing(int tabIndex) async {
    if (tabIndex != 1) return false;
    if (_internshipPageKey.currentState?.activeKey.currentState == null) {
      return false;
    }

    // For each internships
    final keys =
        _internshipPageKey.currentState!.activeKey.currentState!.detailKeys;
    for (final key in keys.keys) {
      if (keys[key]!.currentState?.editMode ?? false) {
        if (keys[key]!.currentState?.editMode ?? false) {
          return await keys[key]!.currentState?.preventClosingIfEditing() ??
              false;
        }
      }
    }
    return false;
  }

  void _onTapBack() async {
    if (await _preventIfEditing(_tabController.index)) return;

    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final student = StudentsHelpers.studentsInMyGroups(context)
        .firstWhereOrNull((e) => e.id == widget.id);

    return student == null
        ? Container()
        : ResponsiveService.scaffoldOf(
            context,
            appBar: ResponsiveService.appBarOf(
              context,
              title: Row(
                children: [
                  student.avatar,
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(student.fullName),
                      Text(
                        '${student.program} - groupe ${student.group}',
                        style: const TextStyle(fontSize: 14),
                      )
                    ],
                  )
                ],
              ),
              leading: IconButton(
                  onPressed: _onTapBack, icon: const Icon(Icons.arrow_back)),
              bottom: TabBar(
                controller: _tabController,
                onTap: (value) {
                  // Prevent from changing for now
                  int previousIndex = _tabController.previousIndex;
                  _tabController.index = previousIndex;
                  Future.microtask(() async {
                    if (!(await _preventIfEditing(previousIndex))) {
                      // If it is allowed to change, then do it
                      _tabController.index = value;
                    }
                  });
                },
                tabs: const [
                  Tab(icon: Icon(Icons.info_outlined), text: 'À propos'),
                  Tab(icon: Icon(Icons.assignment), text: 'Stages'),
                  Tab(
                      icon: Icon(Icons.card_membership),
                      text: 'Plan formation'),
                ],
              ),
            ),
            smallDrawer: null,
            mediumDrawer: MainDrawer.medium,
            largeDrawer: MainDrawer.large,
            body: TabBarView(
              controller: _tabController,
              children: [
                AboutPage(key: _aboutPageKey, student: student),
                InternshipsPage(key: _internshipPageKey, student: student),
                SkillsPage(key: _skillsPageKey, student: student),
              ],
            ),
          );
  }
}
