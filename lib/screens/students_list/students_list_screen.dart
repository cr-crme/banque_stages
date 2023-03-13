import 'package:crcrme_banque_stages/common/providers/internships_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '/common/models/student.dart';
import '/common/providers/students_provider.dart';
import '/common/widgets/main_drawer.dart';
import '/common/widgets/search_bar.dart';
import '/dummy_data.dart';
import '/router.dart';
import 'widgets/student_card.dart';

class StudentsListScreen extends StatefulWidget {
  const StudentsListScreen({super.key});

  @override
  State<StudentsListScreen> createState() => _StudentsListScreenState();
}

class _StudentsListScreenState extends State<StudentsListScreen> {
  final _searchController = TextEditingController();
  bool _showSearchBar = false;

  List<Student> _filterSelectedStudents(List<Student> students) {
    return students.where((student) {
      if (student.name.contains(_searchController.text)) {
        return true;
      }

      return false;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.studentsList_title),
        actions: [
          IconButton(
            onPressed: () => setState(() => _showSearchBar = !_showSearchBar),
            icon: const Icon(Icons.search),
          )
        ],
        bottom:
            _showSearchBar ? SearchBar(controller: _searchController) : null,
      ),
      drawer: const MainDrawer(),
      body: Column(
        children: [
          Selector<StudentsProvider, List<Student>>(
            builder: (context, students, child) => Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: students.length,
                itemBuilder: (context, index) => StudentCard(
                  student: students.elementAt(index),
                  onTap: (student) => GoRouter.of(context).goNamed(
                    Screens.student,
                    params: Screens.withId(student),
                  ),
                ),
              ),
            ),
            selector: (context, students) =>
                _filterSelectedStudents(students.toList()),
          ),
          //! Remove this in production
          Consumer2<StudentsProvider, InternshipsProvider>(
            builder: (context, students, interships, child) => Visibility(
              visible: students.isEmpty,
              child: ElevatedButton(
                  onPressed: () => addDummyStudents(students, interships),
                  child: const Text("Add dummy students")),
            ),
          ),
        ],
      ),
    );
  }
}
