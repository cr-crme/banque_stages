import 'package:auto_size_text/auto_size_text.dart';
import 'package:common/models/enterprises/enterprise.dart';
import 'package:common/models/internships/internship.dart';
import 'package:common/models/itineraries/visiting_priority.dart';
import 'package:common/models/persons/student.dart';
import 'package:common/services/job_data_file_service.dart';
import 'package:common/utils.dart';
import 'package:common_flutter/helpers/responsive_service.dart';
import 'package:common_flutter/providers/enterprises_provider.dart';
import 'package:common_flutter/providers/internships_provider.dart';
import 'package:common_flutter/providers/students_provider.dart';
import 'package:common_flutter/providers/teachers_provider.dart';
import 'package:crcrme_banque_stages/common/extensions/internship_extension.dart';
import 'package:crcrme_banque_stages/common/extensions/students_extension.dart';
import 'package:crcrme_banque_stages/common/extensions/visiting_priorities_extension.dart';
import 'package:crcrme_banque_stages/common/widgets/main_drawer.dart';
import 'package:crcrme_banque_stages/router.dart';
import 'package:crcrme_banque_stages/screens/visiting_students/itinerary_screen.dart';
import 'package:crcrme_material_theme/crcrme_material_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class _InternshipMetaData {
  final Internship internship;
  final Student student;
  bool isSupervised;
  bool isTeacherSignatory;
  VisitingPriority visitingPriority;

  _InternshipMetaData({
    required this.internship,
    required this.student,
    required this.isSupervised,
    required this.visitingPriority,
    required this.isTeacherSignatory,
  });
}

extension _InternshipMetaDataList on List<_InternshipMetaData> {
  int get supervizedCount =>
      fold(0, (count, metaData) => count + (metaData.isSupervised ? 1 : 0));

  List<_InternshipMetaData> filterPriorities(
          List<VisitingPriority> whiteList) =>
      where((metaData) => whiteList.contains(metaData.visitingPriority))
          .toList();

  List<_InternshipMetaData> filterByText(String text) {
    if (text.isEmpty) return this;
    return where((metaData) =>
        metaData.student.fullName.toLowerCase().contains(text)).toList();
  }

  _InternshipMetaData? getSupervized(int index) {
    int count = 0;
    for (final metaData in this) {
      if (metaData.isSupervised) {
        if (count == index) return metaData;
        count++;
      }
    }
    return null;
  }

  static List<_InternshipMetaData> _internshipsOf(BuildContext context,
      {List<VisitingPriority>? visibilityFilters, String? filterText}) {
    final teacherId = TeachersProvider.of(context, listen: true).myTeacher?.id;
    if (teacherId == null) return [];

    final internships = InternshipsProvider.of(context, listen: true);
    final students = StudentsProvider.of(context, listen: true);

    List<_InternshipMetaData> out = [];

    for (final internship in internships) {
      if (!internship.isActive) continue;

      final student = students
          .firstWhereOrNull((student) => student.id == internship.studentId);
      // Skip internships with no student I have access to
      if (student == null) continue;

      out.add(_InternshipMetaData(
        internship: internship,
        student: students
            .firstWhere((student) => student.id == internship.studentId),
        isSupervised: internship.supervisingTeacherIds.contains(teacherId),
        visitingPriority: internship.visitingPriority,
        isTeacherSignatory: internship.signatoryTeacherId == teacherId,
      ));
    }

    // Sort the internships by student names
    out.sort(
      (a, b) => a.student.lastName
          .toLowerCase()
          .compareTo(b.student.lastName.toLowerCase()),
    );

    // Apply the filters
    out = visibilityFilters == null
        ? out
        : out.filterPriorities(visibilityFilters);
    out = (filterText?.isEmpty ?? true) ? out : out.filterByText(filterText!);

    // Return the internships
    return out;
  }
}

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
    VisitingPriority.low: true
  };

  void _navigateToStudentInfo(Student student) => GoRouter.of(context).goNamed(
        Screens.supervisionStudentDetails,
        pathParameters: Screens.params(student),
      );

  void _toggleEditMode(BuildContext context,
      {required List<_InternshipMetaData> internships}) {
    if (_editMode) {
      final teacherId =
          TeachersProvider.of(context, listen: false).myTeacher?.id;
      if (teacherId == null) {
        _editMode = false;
        return;
      }

      final internshipsProvided =
          InternshipsProvider.of(context, listen: false);

      for (final meta in internships) {
        final internship = internshipsProvided.fromIdOrNull(meta.internship.id);
        if (internship == null) continue;

        final newInternship = (meta.isSupervised
                ? internship.copyWithTeacher(context, teacherId: teacherId)
                : internship.copyWithoutTeacher(context, teacherId: teacherId))
            .copyWith(visitingPriority: meta.visitingPriority);

        final differences = internship.getDifference(newInternship);
        if (differences.isEmpty) continue;

        // Update the internship with the new values
        internshipsProvided.replace(newInternship);
      }
    }

    setState(() {
      _editMode = !_editMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    final internships = _InternshipMetaDataList._internshipsOf(context,
        visibilityFilters: _visibilityFilters.keys
            .where((priority) => _visibilityFilters[priority] ?? false)
            .toList(),
        filterText: _searchTextController.text.toLowerCase());

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
                onPressed: () =>
                    _toggleEditMode(context, internships: internships),
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
                    itemCount: _editMode
                        ? internships.length
                        : internships.supervizedCount,
                    itemBuilder: ((ctx, i) {
                      final meta = _editMode
                          ? internships[i]
                          : internships.getSupervized(i);
                      if (meta == null) return Container();

                      return _StudentTile(
                        key: Key(meta.student.id),
                        meta: meta,
                        onTap: () => _navigateToStudentInfo(meta.student),
                        onInternshipChanged: () {},
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
                    padding: const EdgeInsets.only(right: 15),
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
    required this.meta,
    required this.onTap,
    required this.onInternshipChanged,
    required this.editMode,
  });

  final _InternshipMetaData meta;
  final Function()? onTap;
  final Function() onInternshipChanged;
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
      _enterprise =
          enterprises.fromIdOrNull(widget.meta.internship.enterpriseId);
      if (_enterprise != null) break;
      await Future.delayed(const Duration(milliseconds: 100));
    }
    setState(() {});
  }

  Specialization? _getSpecialization(BuildContext context) {
    if (_enterprise == null) return null;
    return _enterprise!.jobs
        .fromIdOrNull(widget.meta.internship.jobId)
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
          onTap: widget.editMode ? null : widget.onTap,
          leading: SizedBox(
            height: double.infinity, // This centers the avatar
            child: widget.meta.student.avatar,
          ),
          tileColor: widget.onTap == null ? disabled.withAlpha(50) : null,
          title: Text(widget.meta.student.fullName),
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
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Ink(
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
                  child: InkWell(
                    onTap: widget.editMode &&
                            (widget.meta.isTeacherSignatory ||
                                widget.meta.isSupervised)
                        ? () {
                            setState(() => widget.meta.visitingPriority =
                                widget.meta.visitingPriority.next);
                            widget.onInternshipChanged();
                          }
                        : null,
                    borderRadius: BorderRadius.circular(25),
                    child: SizedBox(
                      width: 45,
                      height: 45,
                      child: Icon(
                        widget.meta.visitingPriority.icon,
                        color: widget.meta.visitingPriority.color,
                        size: 30,
                      ),
                    ),
                  ),
                ),
              ),
              if (widget.editMode)
                Checkbox(
                  value: widget.meta.isTeacherSignatory
                      ? null
                      : widget.meta.isSupervised,
                  tristate: true,
                  onChanged: widget.editMode && !widget.meta.isTeacherSignatory
                      ? (value) => setState(
                          () => widget.meta.isSupervised = value ?? false)
                      : null,
                ),
            ],
          ),
        ),
      );
    });
  }
}
