import 'package:auto_size_text/auto_size_text.dart';
import 'package:common/models/enterprises/enterprise.dart';
import 'package:common/models/internships/internship.dart';
import 'package:common/models/itineraries/visiting_priority.dart';
import 'package:common/models/persons/student.dart';
import 'package:common/services/job_data_file_service.dart';
import 'package:common_flutter/helpers/responsive_service.dart';
import 'package:common_flutter/providers/enterprises_provider.dart';
import 'package:common_flutter/providers/internships_provider.dart';
import 'package:common_flutter/providers/teachers_provider.dart';
import 'package:crcrme_banque_stages/common/extensions/students_extension.dart';
import 'package:crcrme_banque_stages/common/extensions/visiting_priorities_extension.dart';
import 'package:crcrme_banque_stages/common/provider_helpers/students_helpers.dart';
import 'package:crcrme_banque_stages/common/widgets/main_drawer.dart';
import 'package:crcrme_banque_stages/router.dart';
import 'package:crcrme_banque_stages/screens/visiting_students/itinerary_screen.dart';
import 'package:crcrme_material_theme/crcrme_material_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SupervisionChart extends StatefulWidget {
  const SupervisionChart({super.key});

  static const route = '/supervision';

  @override
  State<SupervisionChart> createState() => _SupervisionChartState();
}

class _SupervisionChartState extends State<SupervisionChart>
    with SingleTickerProviderStateMixin {
  late final _tabController =
      TabController(initialIndex: 0, length: 2, vsync: this)
        ..addListener(() => setState(() {}));

  bool _editMode = false;
  final _searchTextController = TextEditingController();
  final _visibilityFilters = {
    VisitingPriority.high: true,
    VisitingPriority.mid: true,
    VisitingPriority.low: true,
  };

  final Map<Internship, bool> _supervisingInternships = {};
  final Map<Internship, VisitingPriority> _visitingPriorities = {};

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

  void _navigateToStudentInfo(Student student) {
    GoRouter.of(context).goNamed(
      Screens.supervisionStudentDetails,
      pathParameters: Screens.params(student),
    );
  }

  void _toggleEditMode() {
    if (_editMode) {
      // TODO: Make the call to update the internships/students for _supervisingInternships and _visitingPriorities
    }

    setState(() {
      _editMode = !_editMode;
    });
  }

  @override
  void initState() {
    super.initState();

    final myId = TeachersProvider.of(context, listen: false).myTeacher?.id;
    if (myId == null) return;

    for (final internship in InternshipsProvider.of(context, listen: false)) {
      _supervisingInternships[internship] =
          internship.supervisingTeacherIds.contains(myId);
      _visitingPriorities[internship] = internship.visitingPriority;
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
    final myId = TeachersProvider.of(context, listen: false).myTeacher?.id;
    final internships = _getInternshipsByStudents();

    final studentsInMyGroups = StudentsHelpers.studentsInMyGroups(context);
    // TODO Add the next list with grey checkbox
    final studentsISignedIntenships = internships
        .where((internship) => internship.signatoryTeacherId == myId)
        .map((internship) => studentsInMyGroups
            .firstWhere((student) => student.id == internship.studentId));
    final studentsISupervize = StudentsHelpers.mySupervizedStudents(context);

    return LayoutBuilder(builder: (context, constraints) {
      return ResponsiveService.scaffoldOf(
        context,
        smallDrawer: MainDrawer.small,
        mediumDrawer: MainDrawer.medium,
        largeDrawer: MainDrawer.large,
        appBar: AppBar(
          title: const Text('Tableau des supervisions'),
          actions: [
            if (_tabController.index == 0)
              IconButton(
                onPressed: _toggleEditMode,
                icon: Icon(
                  _editMode ? Icons.save : Icons.edit,
                ),
              )
          ],
          bottom: _buildBottomTabBar(constraints),
        ),
        body: TabBarView(controller: _tabController, children: [
          Column(
            children: [
              _buildFilters(constraints),
              if (internships.isEmpty)
                Center(
                  child: Padding(
                    padding:
                        const EdgeInsets.only(top: 12.0, left: 36, right: 36),
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
                        onTap: () => _navigateToStudentInfo(student),
                        onVisitingPriorityChanged: (priority) =>
                            _visitingPriorities[internship] = priority,
                        onAlreadyEndedInternship: () =>
                            _navigateToStudentInfo(student),
                        isManagingStudents: false,
                        isInternshipSupervised:
                            studentsISupervize.any((e) => e.id == student.id),
                        editMode: _editMode,
                      );
                    }),
                  ),
                ),
            ],
          ),
          const ItineraryMainScreen(),
        ]),
      );
    });
  }

  PreferredSizeWidget _buildBottomTabBar(BoxConstraints constraints) {
    final isColumn = constraints.maxWidth < ResponsiveService.smallScreenWidth;
    return TabBar(
      controller: _tabController,
      tabs: [
        Tab(
          child: _TabIcon(
            title: 'Élèves à superviser',
            icon: Icons.supervisor_account,
            isColumn: isColumn,
          ),
        ),
        Tab(
          child: _TabIcon(
            title: 'Itinéraire de visites',
            icon: Icons.map,
            isColumn: isColumn,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
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

  Widget _buildFlagFilter() {
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

  Widget _buildFilters(BoxConstraints constraints) {
    return constraints.maxWidth < ResponsiveService.smallScreenWidth
        ? Column(
            children: [
              _buildFlagFilter(),
              _buildSearchBar(),
            ],
          )
        : Row(
            children: [
              Expanded(child: _buildFlagFilter()),
              Expanded(child: _buildSearchBar()),
            ],
          );
  }
}

class _TabIcon extends StatelessWidget {
  const _TabIcon({
    required this.title,
    required this.icon,
    required this.isColumn,
  });

  final String title;
  final IconData icon;
  final bool isColumn;

  @override
  Widget build(BuildContext context) {
    return isColumn
        ? Column(
            children: [
              Icon(icon),
              Text(
                title,
                style: const TextStyle(color: Colors.white),
              ),
            ],
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon),
              SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(color: Colors.white),
              ),
            ],
          );
  }
}

class _StudentTile extends StatefulWidget {
  const _StudentTile({
    super.key,
    required this.student,
    required this.internship,
    required this.onTap,
    required this.onVisitingPriorityChanged,
    required this.onAlreadyEndedInternship,
    required this.isManagingStudents,
    required this.isInternshipSupervised,
    required this.editMode,
  });

  final Student student;
  final Internship internship;
  final Function()? onTap;
  final Function(VisitingPriority priority) onVisitingPriorityChanged;
  final Function() onAlreadyEndedInternship;
  final bool isManagingStudents;
  final bool isInternshipSupervised;
  final bool editMode;

  @override
  State<_StudentTile> createState() => _StudentTileState();
}

class _StudentTileState extends State<_StudentTile> {
  Enterprise? _enterprise;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _getEnterprise();
  }

  Future<void> _getEnterprise() async {
    while (true) {
      if (!mounted) {
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

  late VisitingPriority _currentPriority = widget.internship.visitingPriority;

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
                      onTap: widget.editMode
                          ? () {
                              setState(() =>
                                  _currentPriority = _currentPriority.next);
                              widget
                                  .onVisitingPriorityChanged(_currentPriority);
                            }
                          : null,
                      borderRadius: BorderRadius.circular(25),
                      child: SizedBox(
                        width: 45,
                        height: 45,
                        child: Icon(
                          _currentPriority.icon,
                          color: _currentPriority.color,
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
