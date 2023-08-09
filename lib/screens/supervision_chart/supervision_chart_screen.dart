import 'package:auto_size_text/auto_size_text.dart';
import 'package:crcrme_banque_stages/common/models/internship.dart';
import 'package:crcrme_banque_stages/common/models/student.dart';
import 'package:crcrme_banque_stages/common/models/visiting_priority.dart';
import 'package:crcrme_banque_stages/common/providers/enterprises_provider.dart';
import 'package:crcrme_banque_stages/common/providers/internships_provider.dart';
import 'package:crcrme_banque_stages/common/providers/students_provider.dart';
import 'package:crcrme_banque_stages/common/providers/teachers_provider.dart';
import 'package:crcrme_banque_stages/common/widgets/main_drawer.dart';
import 'package:crcrme_banque_stages/router.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SupervisionChart extends StatefulWidget {
  const SupervisionChart({super.key});

  @override
  State<SupervisionChart> createState() => _SupervisionChartState();
}

class _SupervisionChartState extends State<SupervisionChart> {
  bool _inManagingMode = false;
  bool _isSearchBarExpanded = false;
  final _searchTextController = TextEditingController();
  bool _isFlagFilterExpanded = false;
  final _visibilityFilters = {
    VisitingPriority.high: true,
    VisitingPriority.mid: true,
    VisitingPriority.low: true,
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
            'Niveau de priorité des visites',
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

  List<Internship> _filterByName(List<Internship> internships) {
    final students =
        StudentsProvider.studentsInMyGroups(context, listen: false);
    return internships
        .where((internship) =>
            students.any((student) => student.id == internship.studentId))
        .toList();
  }

  List<Internship> _filterByFlag(List<Internship> internships) {
    return internships
        .where((internship) => _visibilityFilters.keys.any((key) =>
            _visibilityFilters[key]! && key == internship.visitingPriority))
        .toList();
  }

  void _updatePriority(String studentId) {
    final interships = InternshipsProvider.of(context, listen: false);
    final studentInternships = interships.byStudentId(studentId);
    if (studentInternships.isEmpty) return;
    interships.replacePriority(
        studentId, studentInternships.last.visitingPriority.next());

    setState(() {});
  }

  void _goToItinerary() {
    GoRouter.of(context).pushNamed(Screens.itinerary);
  }

  void _navigateToStudentInfo(Student student) {
    GoRouter.of(context).goNamed(
      Screens.supervisionStudentDetails,
      params: Screens.params(student),
    );
  }

  List<Internship> _getInternshipsByStudents() {
    final myId = TeachersProvider.of(context, listen: false).currentTeacherId;
    var allMyStudents =
        StudentsProvider.studentsInMyGroups(context, listen: false);

    var internships = [...InternshipsProvider.of(context)];
    internships = internships
        .where((internship) =>
            internship.isActive &&
            internship.supervisingTeacherIds.contains(myId) &&
            allMyStudents.any((student) => student.id == internship.studentId))
        .toList();

    internships.sort(
      (a, b) => allMyStudents
          .firstWhere((student) => student.id == a.studentId)
          .lastName
          .toLowerCase()
          .compareTo(allMyStudents
              .firstWhere((student) => student.id == b.studentId)
              .lastName
              .toLowerCase()),
    );
    internships = _filterByName(internships);
    internships = _filterByFlag(internships);

    return internships;
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final iconSize = screenSize.width / 16;
    final students =
        StudentsProvider.studentsInMyGroups(context, listen: false);

    final internships = _getInternshipsByStudents();

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
                  // TODO This becomes a 'managing' tab
                  // TODO If managing, a Text appears at the top 'Sélectionner les ...'
                  // TODO If managing, the numbers changes in person_add/remove
                  // TODO If managing, clicking on the card swap person_add/remove
                  // TODO We cannot remove if we are the creator of the internship
                  _TabIcon(
                      title: 'Gestion',
                      screenSize: screenSize,
                      iconSize: iconSize,
                      onTap: () {
                        _inManagingMode = !_inManagingMode;
                        if (_inManagingMode) _isFlagFilterExpanded = false;
                        setState(() {});
                      },
                      icon: Icons.group),
                  _TabIcon(
                      title: 'Recherche',
                      screenSize: screenSize,
                      iconSize: iconSize,
                      onTap: _toggleSearchBar,
                      icon: Icons.search),
                  Visibility(
                    visible: !_inManagingMode,
                    child: _TabIcon(
                        title: 'Priorité',
                        screenSize: screenSize,
                        iconSize: iconSize,
                        onTap: _toggleFlagFilter,
                        icon: Icons.filter_alt_sharp),
                  ),
                ])),
      ),
      body: Column(
        children: [
          if (_isSearchBarExpanded) _searchBarBuilder(),
          if (_isFlagFilterExpanded) _flagFilterBuilder(),
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: internships.length,
              itemBuilder: ((ctx, i) {
                final internship = internships[i];
                final student = students.firstWhere(
                    (student) => student.id == internship.studentId);

                return _StudentTile(
                  key: Key(student.id),
                  student: student,
                  internship: internship,
                  onTap: () => _navigateToStudentInfo(student),
                  onUpdatePriority: () => _updatePriority(student.id),
                  onAlreadyEndedInternship: () =>
                      _navigateToStudentInfo(student),
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
    required this.onTap,
    required this.onUpdatePriority,
    required this.onAlreadyEndedInternship,
  });

  final Student student;
  final Internship? internship;
  final Function() onTap;
  final Function() onUpdatePriority;
  final Function() onAlreadyEndedInternship;

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
        onTap: onTap,
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
                  border: Border.all(
                      color: Theme.of(context).primaryColor.withAlpha(100),
                      width: 2.5),
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
