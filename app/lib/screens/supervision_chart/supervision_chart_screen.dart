import 'package:auto_size_text/auto_size_text.dart';
import 'package:common/models/enterprises/enterprise.dart';
import 'package:common/models/internships/internship.dart';
import 'package:common/models/itineraries/visiting_priority.dart';
import 'package:common/models/persons/student.dart';
import 'package:common/services/job_data_file_service.dart';
import 'package:common_flutter/providers/enterprises_provider.dart';
import 'package:common_flutter/providers/internships_provider.dart';
import 'package:common_flutter/providers/teachers_provider.dart';
import 'package:common_flutter/widgets/show_snackbar.dart';
import 'package:crcrme_banque_stages/common/extensions/internship_extension.dart';
import 'package:crcrme_banque_stages/common/extensions/students_extension.dart';
import 'package:crcrme_banque_stages/common/extensions/visiting_priorities_extension.dart';
import 'package:crcrme_banque_stages/common/provider_helpers/students_helpers.dart';
import 'package:crcrme_banque_stages/common/widgets/main_drawer.dart';
import 'package:crcrme_banque_stages/router.dart';
import 'package:crcrme_material_theme/crcrme_material_theme.dart';
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
    final students = StudentsHelpers.studentsInMyGroups(context, listen: false);

    return internships
        .where((internship) => students.any((student) =>
            student.id == internship.studentId &&
            student.fullName
                .toLowerCase()
                .contains(_searchTextController.text.toLowerCase())))
        .toList();
  }

  List<Internship> _filterByFlag(List<Internship> internships) {
    return internships
        .where((internship) => _visibilityFilters.keys.any((key) =>
            _visibilityFilters[key]! && key == internship.visitingPriority))
        .toList();
  }

  void _updatePriority(String studentId) {
    final internships = InternshipsProvider.of(context, listen: false);
    final studentInternships = internships.byStudentId(studentId);
    if (studentInternships.isEmpty) return;
    internships.replacePriority(
        studentId, studentInternships.last.visitingPriority.next);

    setState(() {});
  }

  void _goToItinerary() {
    GoRouter.of(context).pushNamed(Screens.itinerary);
  }

  void _navigateToStudentInfo(Student student) {
    GoRouter.of(context).goNamed(
      Screens.supervisionStudentDetails,
      pathParameters: Screens.params(student),
    );
  }

  void _swapSupervisionStatus(Internship internship) {
    final myId = TeachersProvider.of(context, listen: false).myTeacher?.id;
    if (myId == null) {
      showSnackBar(context, message: 'Vous n\'êtes pas connecté.');
      return;
    }

    if (internship.supervisingTeacherIds.contains(myId)) {
      internship.removeSupervisingTeacher(context, teacherId: myId);
    } else {
      internship.addSupervisingTeacher(context, teacherId: myId);
    }
  }

  List<Internship> _getInternshipsByStudents() {
    final myId = TeachersProvider.of(context, listen: false).myTeacher?.id;
    var allMyStudents =
        StudentsHelpers.studentsInMyGroups(context, listen: false);

    var internships = [...InternshipsProvider.of(context)];
    internships = internships
        .where((internship) =>
            internship.isActive &&
            (_inManagingMode ||
                internship.supervisingTeacherIds.contains(myId)) &&
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
    final myId = TeachersProvider.of(context, listen: false).myTeacher?.id;
    final screenSize = MediaQuery.of(context).size;
    final iconSize = screenSize.width / 16;
    final internships = _getInternshipsByStudents();

    final studentsInMyGroups = StudentsHelpers.studentsInMyGroups(context);
    final studentsISignedIntenships = internships
        .where((internship) => internship.signatoryTeacherId == myId)
        .map((internship) => studentsInMyGroups
            .firstWhere((student) => student.id == internship.studentId));
    final studentsISupervize = StudentsHelpers.mySupervizedStudents(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tableau des supervisions'),
        actions: [
          if (!_inManagingMode)
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
                      title: _inManagingMode ? 'Quitter gestion' : 'Gestion',
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
          if (_inManagingMode)
            Padding(
              padding: const EdgeInsets.only(top: 12.0, bottom: 12),
              child: Text(
                'Sélectionner les élèves à superviser',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          if (internships.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 12.0, left: 36, right: 36),
                child: Text(
                  'Aucun élève en stage',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ),
          if (internships.isNotEmpty)
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: internships.length,
                itemBuilder: ((ctx, i) {
                  final internship = internships[i];
                  final student = studentsInMyGroups.firstWhere(
                      (student) => student.id == internship.studentId);

                  return _StudentTile(
                    key: Key(student.id),
                    student: student,
                    internship: internship,
                    onTap: _inManagingMode
                        ? (studentsISignedIntenships
                                .any((e) => e.id == student.id)
                            ? null
                            : () => _swapSupervisionStatus(internship))
                        : () => _navigateToStudentInfo(student),
                    onUpdatePriority: () => _updatePriority(student.id),
                    onAlreadyEndedInternship: () =>
                        _navigateToStudentInfo(student),
                    isManagingStudents: _inManagingMode,
                    isInternshipSupervised:
                        studentsISupervize.any((e) => e.id == student.id),
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
    required this.title,
    required this.screenSize,
    required this.iconSize,
    required this.icon,
    this.onTap,
  });

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
        height: iconSize * 2,
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

class _StudentTile extends StatefulWidget {
  const _StudentTile({
    super.key,
    required this.student,
    required this.internship,
    required this.onTap,
    required this.onUpdatePriority,
    required this.onAlreadyEndedInternship,
    required this.isManagingStudents,
    required this.isInternshipSupervised,
  });

  final Student student;
  final Internship internship;
  final Function()? onTap;
  final Function() onUpdatePriority;
  final Function() onAlreadyEndedInternship;
  final bool isManagingStudents;
  final bool isInternshipSupervised;

  @override
  State<_StudentTile> createState() => _StudentTileState();
}

class _StudentTileState extends State<_StudentTile> {
  Enterprise? _enterprise;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _getEnterprise(context);
  }

  Future<void> _getEnterprise(BuildContext context) async {
    while (true) {
      if (!context.mounted) {
        _enterprise = null;
        break;
      }
      final enterprises = EnterprisesProvider.of(context, listen: false);
      _enterprise = enterprises.fromIdOrNull(widget.internship.enterpriseId);
      if (_enterprise != null) break;
      await Future.delayed(const Duration(milliseconds: 100));
    }
    setState(() {});
  }

  Specialization? _getSpecialization(BuildContext context) {
    if (_enterprise == null) return null;
    return _enterprise!.jobs
        .fromIdOrNull(widget.internship.jobId)
        ?.specialization;
  }

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      final specialization = _getSpecialization(context);
      if (_enterprise == null || specialization == null) return Container();

      return Card(
        elevation: 10,
        child: ListTile(
          onTap: widget.onTap,
          leading: SizedBox(
            height: double.infinity, // This centers the avatar
            child: widget.student.avatar,
          ),
          tileColor: widget.onTap == null ? disabled.withAlpha(50) : null,
          title: Text(widget.student.fullName),
          isThreeLine: true,
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _enterprise!.name,
                style: const TextStyle(color: Colors.black87),
              ),
              AutoSizeText(
                specialization.name,
                maxLines: 2,
                style: const TextStyle(color: Colors.black87),
              ),
            ],
          ),
          trailing: widget.isManagingStudents
              ? InkWell(
                  borderRadius: BorderRadius.circular(25),
                  onTap: widget.onTap,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                        widget.isInternshipSupervised
                            ? Icons.person_add
                            : Icons.person_remove,
                        color: widget.onTap == null
                            ? disabled
                            : Theme.of(context).primaryColor),
                  ),
                )
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
                    border: Border.all(
                        color: Theme.of(context).primaryColor.withAlpha(100),
                        width: 2.5),
                    shape: BoxShape.circle,
                  ),
                  child: Tooltip(
                    message:
                        'Niveau de priorité pour les visites de supervision',
                    child: InkWell(
                      onTap: widget.onUpdatePriority,
                      borderRadius: BorderRadius.circular(25),
                      child: SizedBox(
                        width: 45,
                        height: 45,
                        child: Icon(
                          widget.internship.visitingPriority.icon,
                          color: widget.internship.visitingPriority.color,
                          size: 30,
                        ),
                      ),
                    ),
                  ),
                ),
        ),
      );
    });
  }
}
