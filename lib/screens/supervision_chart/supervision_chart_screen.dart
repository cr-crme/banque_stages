import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:crcrme_banque_stages/common/models/internship.dart';
import 'package:crcrme_banque_stages/common/models/student.dart';
import 'package:crcrme_banque_stages/common/models/visiting_priority.dart';
import 'package:crcrme_banque_stages/common/providers/enterprises_provider.dart';
import 'package:crcrme_banque_stages/common/providers/internships_provider.dart';
import 'package:crcrme_banque_stages/common/providers/students_provider.dart';
import 'package:crcrme_banque_stages/common/providers/teachers_provider.dart';
import 'package:crcrme_banque_stages/common/widgets/main_drawer.dart';
import 'package:crcrme_banque_stages/router.dart';
import 'widgets/transfer_dialog.dart';

class SupervisionChart extends StatefulWidget {
  const SupervisionChart({super.key});

  @override
  State<SupervisionChart> createState() => _SupervisionChartState();
}

class _SupervisionChartState extends State<SupervisionChart> {
  bool _isSearchBarExpanded = false;
  final _searchTextController = TextEditingController();
  bool _isFlagFilterExpanded = true;
  final _visibilityFilters = {
    VisitingPriority.high: true,
    VisitingPriority.mid: true,
    VisitingPriority.low: true,
    VisitingPriority.notApplicable: true,
  };

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
            labelText: 'Rechercher un élève',
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
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(
            'Niveau de priorité',
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: _visibilityFilters.keys.map<Widget>((priority) {
            return InkWell(
              onTap: () => setState(() => _visibilityFilters[priority] =
                  !_visibilityFilters[priority]!),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Checkbox(
                      value: _visibilityFilters[priority],
                      onChanged: (value) => setState(
                          () => _visibilityFilters[priority] = value!)),
                  Padding(
                    padding: const EdgeInsets.only(right: 25),
                    child: Icon(priority.icon, color: priority.color),
                  )
                ],
              ),
            );
          }).toList(),
        ),
      ],
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
    final allInterships = InternshipsProvider.of(context, listen: false);

    return students
        .map<Student?>((e) {
          final interships = allInterships.byStudentId(e.id);
          if (interships.isEmpty || !interships.last.isActive) {
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
    final interships = InternshipsProvider.of(context, listen: false);
    final studentInternships = interships.byStudentId(studentId);
    if (studentInternships.isEmpty) return;
    interships.replacePriority(
        studentId, studentInternships.last.visitingPriority.next());

    setState(() {});
  }

  void _transferStudent() async {
    final internships = InternshipsProvider.of(context, listen: false);
    final students =
        StudentsProvider.of(context, listen: false).map((e) => e).toList();
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
    internships.transferStudent(studentId: answer[0], newTeacherId: answer[1]);
  }

  Future<void> _showTransferedStudent({listenInternships = false}) async {
    final myId = TeachersProvider.of(context, listen: false).currentTeacherId;
    final internships =
        InternshipsProvider.of(context, listen: listenInternships);

    for (final internship in internships) {
      if (internship.isTransfering && internship.teacherId == myId) {
        final student = await StudentsProvider.fromLimitedId(context,
            studentId: internship.studentId);
        if (student == null) continue;

        if (!mounted) return;
        final acceptTransfer = await showDialog<bool>(
            barrierDismissible: false,
            context: context,
            builder: (BuildContext context) =>
                AcceptTransferDialog(student: student));
        if (acceptTransfer!) {
          internships.acceptTransfer(studentId: internship.studentId);
        } else {
          internships.refuseTransfer(studentId: internship.studentId);
        }
      }
    }
  }

  void _goToItinerary() {
    GoRouter.of(context).pushNamed(Screens.itinerary);
  }

  Future<List<Student>> _fetchSupervizedStudents() async {
    // Check if a student was transfered to the teacher, if so, show a dialog
    // box to accept or refuse
    await _showTransferedStudent(listenInternships: true);
    if (!mounted) return [];

    var out =
        await StudentsProvider.getMySupervizedStudents(context, listen: false);
    out.sort(
      (a, b) => a.lastName.toLowerCase().compareTo(b.lastName.toLowerCase()),
    );
    out = _filterByName(out);
    out = _filterByFlag(out);

    return out;
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final iconSize = screenSize.width / 16;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tableau des supervisions'),
        actions: [
          IconButton(
            onPressed: _goToItinerary,
            icon: const Icon(Icons.directions),
            iconSize: 35,
          )
        ],
        bottom: PreferredSize(
            preferredSize: Size(screenSize.width, iconSize * 1.5),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _TabIcon(
                      title: 'Transfert',
                      screenSize: screenSize,
                      iconSize: iconSize,
                      onTap: _transferStudent,
                      icon: Icons.transfer_within_a_station),
                  _TabIcon(
                      title: 'Recherche',
                      screenSize: screenSize,
                      iconSize: iconSize,
                      onTap: _toggleSearchBar,
                      icon: Icons.search),
                  _TabIcon(
                      title: 'Niveau de priorité',
                      screenSize: screenSize,
                      iconSize: iconSize,
                      onTap: _toggleFlagFilter,
                      icon: Icons.filter_alt_sharp),
                ])),
      ),
      body: FutureBuilder<List<Student>>(
          future: _fetchSupervizedStudents(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            final students = snapshot.data!;
            return Column(
              children: [
                if (_isSearchBarExpanded) _searchBarBuilder(),
                if (_isFlagFilterExpanded) _flagFilterBuilder(),
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: students.length,
                    itemBuilder: ((ctx, i) {
                      final student = students[i];
                      final internships =
                          InternshipsProvider.of(context, listen: true)
                              .byStudentId(student.id);

                      return _StudentTile(
                        key: Key(student.id),
                        student: student,
                        internship:
                            internships.isNotEmpty ? internships.last : null,
                        onUpdatePriority: () => _updatePriority(student.id),
                      );
                    }),
                  ),
                ),
              ],
            );
          }),
      drawer: const MainDrawer(),
    );
  }
}

class _TabIcon extends StatelessWidget {
  const _TabIcon({
    Key? key,
    required this.title,
    required this.screenSize,
    required this.iconSize,
    required this.icon,
    this.onTap,
  }) : super(key: key);

  final String title;
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
        height: iconSize * 1.8,
        child: Column(
          children: [
            Icon(
              icon,
              size: iconSize,
            ),
            Text(
              title,
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

class _StudentTile extends StatelessWidget {
  const _StudentTile({
    super.key,
    required this.student,
    required this.internship,
    required this.onUpdatePriority,
  });

  final Student student;
  final Internship? internship;
  final Function() onUpdatePriority;

  @override
  Widget build(BuildContext context) {
    final enterprise = internship?.isActive ?? false
        ? EnterprisesProvider.of(context, listen: false)
            .fromId(internship!.enterpriseId)
        : null;
    final specialization = internship?.isActive ?? false
        ? enterprise?.jobs.fromId(internship!.jobId).specialization
        : null;

    return Card(
      elevation: 10,
      child: ListTile(
        onTap: () => GoRouter.of(context).goNamed(
          Screens.supervisionStudentDetails,
          params: Screens.params(student),
        ),
        leading: SizedBox(
          height: double.infinity, // This centers the avatar
          child: student.avatar,
        ),
        title: Text(student.fullName),
        isThreeLine: true,
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              enterprise?.name ?? 'Aucun stage',
              style: const TextStyle(color: Colors.black87),
            ),
            AutoSizeText(
              specialization?.name ?? '',
              maxLines: 2,
              style: const TextStyle(color: Colors.black87),
            ),
          ],
        ),
        trailing: internship?.isActive ?? false
            ? Ink(
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
                child: Tooltip(
                  message: 'Niveau de priorité pour les visites de supervision',
                  child: IconButton(
                    onPressed: onUpdatePriority,
                    alignment: Alignment.center,
                    icon: Icon(
                      internship!.visitingPriority.icon,
                      color: internship!.visitingPriority.color,
                      size: 30,
                    ),
                  ),
                ),
              )
            : null,
      ),
    );
  }
}
