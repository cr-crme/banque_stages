import 'package:flutter/material.dart';

import '/common/models/internship.dart';
import '/common/models/student.dart';
import '/common/models/visiting_priority.dart';
import '/common/providers/enterprises_provider.dart';
import '/common/providers/internships_provider.dart';
import '/common/providers/students_provider.dart';
import '/common/providers/teachers_provider.dart';
import '/common/widgets/main_drawer.dart';
import '/misc/job_data_file_service.dart';
import 'widgets/transfer_dialog.dart';

class SupervisionChart extends StatefulWidget {
  const SupervisionChart({super.key});

  @override
  State<SupervisionChart> createState() => _SupervisionChartState();
}

class _SupervisionChartState extends State<SupervisionChart> {
  bool _isSearchBarExpanded = false;
  final _searchTextController = TextEditingController();
  bool _isFlagFilterExpanded = false;
  final _visibilityFilters = {
    VisitingPriority.high: true,
    VisitingPriority.mid: true,
    VisitingPriority.low: true,
    VisitingPriority.notApplicable: false,
  };

  ///
  /// Get all the students who the current teacher is assigned to, meaning
  /// they supervise this student for their internship
  ///
  List<Student> _getSupervisedStudents() {
    final myId = TeachersProvider.of(context, listen: false).currentTeacherId;
    final allInternships = InternshipsProvider.of(context, listen: false);
    final allStudents = StudentsProvider.of(context).map((e) => e).toList();

    return allStudents
        .map<Student?>((student) {
          final internships = allInternships.byStudentId(student.id);
          if (internships.isEmpty) return student;
          return internships.last.teacherId == myId ? student : null;
        })
        .where((e) => e != null)
        .toList()
        .cast<Student>();
  }

  ///
  /// Get all the who the current teacher is in charge. Meaning they are
  /// responsible in a more general way
  ///
  List<Student> _getInChargeStudents() {
    final myId = TeachersProvider.of(context, listen: false).currentTeacherId;
    final allStudents =
        StudentsProvider.of(context, listen: false).map((e) => e).toList();

    return allStudents
        .map<Student?>((student) => student.teacherId == myId ? student : null)
        .where((e) => e != null)
        .toList()
        .cast<Student>();
  }

  void _toggleSearchBar() {
    _isFlagFilterExpanded = false;
    _isSearchBarExpanded = !_isSearchBarExpanded;
    setState(() {});
  }

  void _toggleFlagFilter() {
    _isSearchBarExpanded = false;
    _isFlagFilterExpanded = !_isFlagFilterExpanded;
    setState(() {});
  }

  Widget _searchBarBuilder() {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.only(left: 15, right: 15),
      child: TextFormField(
        decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search),
            labelText: 'Rechercher un métier',
            suffixIcon: IconButton(
                onPressed: () =>
                    setState(() => _searchTextController.text = ''),
                icon: const Icon(Icons.clear)),
            border: const OutlineInputBorder(borderSide: BorderSide())),
        controller: _searchTextController,
        onChanged: (value) => setState(() {}),
      ),
    );
  }

  Widget _flagFilterBuilder() {
    final flags = _visibilityFilters.keys.map<Widget>((priority) {
      return InkWell(
        onTap: () => setState(() =>
            _visibilityFilters[priority] = !_visibilityFilters[priority]!),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Checkbox(
                value: _visibilityFilters[priority],
                onChanged: (value) =>
                    setState(() => _visibilityFilters[priority] = value!)),
            Padding(
              padding: const EdgeInsets.only(right: 25),
              child: Icon(VisitingPriorityStyled.icon, color: priority.color),
            )
          ],
        ),
      );
    }).toList();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: flags,
    );
  }

  List<Student> _filterByName(List<Student> students) {
    return students
        .map<Student?>((e) => e.fullName
                .toLowerCase()
                .contains(_searchTextController.text.toLowerCase())
            ? e
            : null)
        .where((e) => e != null)
        .toList()
        .cast<Student>();
  }

  List<Student> _filterByFlag(List<Student> students) {
    final allInterships = InternshipsProvider.of(context, listen: true);

    return students
        .map<Student?>((e) {
          final interships = allInterships.byStudentId(e.id);
          if (interships.isEmpty) {
            return _visibilityFilters[VisitingPriority.notApplicable]!
                ? e
                : null;
          }
          return _visibilityFilters[interships.last.visitingPriority]!
              ? e
              : null;
        })
        .where((e) => e != null)
        .toList()
        .cast<Student>();
  }

  void _updatePriority(String studentId) {
    debugPrint(studentId);
    final interships = InternshipsProvider.of(context, listen: false);
    final studentInternships = interships.byStudentId(studentId);
    if (studentInternships.isEmpty) return;
    interships.replacePriority(
        studentId, studentInternships.last.visitingPriority.next());

    setState(() {});
  }

  void _transferStudent() async {
    final internships = InternshipsProvider.of(context, listen: false);
    final students = _getInChargeStudents();
    final teachers =
        TeachersProvider.of(context, listen: false).map((e) => e).toList();

    students.sort(
        (a, b) => a.lastName.toLowerCase().compareTo(b.lastName.toLowerCase()));
    teachers.sort(
        (a, b) => a.lastName.toLowerCase().compareTo(b.lastName.toLowerCase()));

    final answer = await showDialog<List<String>>(
      context: context,
      builder: (BuildContext context) =>
          TransferDialog(students: students, teachers: teachers),
    );

    if (answer == null) return;

    final internship = internships.byStudentId(answer[0]);
    if (internship.isEmpty) return;
    internships.replace(internship.last.copyWith(teacherId: answer[1]));
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final iconSize = screenSize.width / 16;

    // Make a copy before filtering
    var students = _getSupervisedStudents();
    final allInternships = InternshipsProvider.of(context);

    students.sort(
      (a, b) => a.fullName.toLowerCase().compareTo(b.fullName.toLowerCase()),
    );
    students = _filterByName(students);
    students = _filterByFlag(students);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Élèves à superviser'),
        bottom: PreferredSize(
            preferredSize: Size(screenSize.width, iconSize * 1.5),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _TabIcon(
                      screenSize: screenSize,
                      iconSize: iconSize,
                      onTap: _transferStudent,
                      icon: Icons.transfer_within_a_station),
                  _TabIcon(
                      screenSize: screenSize,
                      iconSize: iconSize,
                      onTap: _toggleSearchBar,
                      icon: Icons.search),
                  _TabIcon(
                      screenSize: screenSize,
                      iconSize: iconSize,
                      onTap: _toggleFlagFilter,
                      icon: Icons.filter_alt_sharp),
                ])),
      ),
      body: Column(
        children: [
          if (_isSearchBarExpanded) _searchBarBuilder(),
          if (_isFlagFilterExpanded) _flagFilterBuilder(),
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: students.length,
              itemBuilder: ((ctx, i) {
                final student = students[i];

                return _StudentTile(
                  key: Key(student.id),
                  student: student,
                  internships: allInternships.byStudentId(student.id),
                  onUpdatePriority: () => _updatePriority(student.id),
                );
              }),
            ),
          ),
        ],
      ),
      drawer: const MainDrawer(),
    );
  }
}

class _TabIcon extends StatelessWidget {
  const _TabIcon({
    Key? key,
    required this.screenSize,
    required this.iconSize,
    required this.icon,
    this.onTap,
  }) : super(key: key);

  final Size screenSize;
  final double iconSize;
  final IconData icon;
  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        width: screenSize.width / 3,
        height: iconSize * 1.5,
        child: Icon(
          icon,
          size: iconSize,
        ),
      ),
    );
  }
}

class _StudentTile extends StatelessWidget {
  const _StudentTile({
    super.key,
    required this.student,
    required this.internships,
    required this.onUpdatePriority,
  });

  final Student student;
  final List<Internship> internships;
  final Function() onUpdatePriority;

  @override
  Widget build(BuildContext context) {
    final enterprise = internships.isNotEmpty
        ? EnterprisesProvider.of(context, listen: false)
            .fromId(internships.last.enterpriseId)
            .name
        : 'Aucun stage';
    final job = internships.isNotEmpty
        ? JobDataFileService.specializationById(internships.last.jobId)!.name
        : '';

    return Card(
      elevation: 10,
      child: ListTile(
        leading: SizedBox(
          height: double.infinity, // This centers the avatar
          child: student.avatar,
        ),
        title: Text(student.fullName),
        isThreeLine: true,
        subtitle: Text(
          '$enterprise\n$job',
          maxLines: 2,
          style: const TextStyle(color: Colors.black87),
        ),
        trailing: internships.isEmpty
            ? null
            : Ink(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.grey,
                      blurRadius: 5.0,
                      spreadRadius: 0.0,
                      offset: Offset(2.0, 2.0),
                    )
                  ],
                  border: Border.all(color: Colors.lightBlue, width: 3),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: onUpdatePriority,
                  alignment: Alignment.center,
                  icon: Icon(
                    VisitingPriorityStyled.icon,
                    color: internships.last.visitingPriority.color,
                    size: 30,
                  ),
                ),
              ),
      ),
    );
  }
}
