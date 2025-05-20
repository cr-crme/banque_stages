import 'package:admin_app/providers/school_boards_provider.dart';
import 'package:admin_app/providers/teachers_provider.dart';
import 'package:admin_app/screens/drawer/main_drawer.dart';
import 'package:admin_app/widgets/animated_expanding_card.dart';
import 'package:collection/collection.dart';
import 'package:common/models/persons/teacher.dart';
import 'package:common/models/school_boards/school_board.dart';
import 'package:common/utils.dart' as utils;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TeachersListScreen extends StatelessWidget {
  const TeachersListScreen({super.key});

  static const route = '/teachers_list';

  Future<Map<String, List<Teacher>>> getTeachers(BuildContext context) async {
    final teachersTp = TeachersProvider.of(context, listen: true);
    final schoolBoard = await SchoolBoardsProvider.mySchoolBoardOf(context);
    final schools = schoolBoard?.schools ?? [];

    // Sort by school name
    final teachers = <String, List<Teacher>>{}; // Teachers by school
    for (final school in schools) {
      final scoolTeachers = teachersTp.where(
        (teacher) => teacher.schoolId == school.id,
      );

      // Sort by last name then first name
      scoolTeachers.sorted((a, b) {
        final lastNameA = a.lastName.toLowerCase();
        final lastNameB = b.lastName.toLowerCase();
        return lastNameA.compareTo(lastNameB);
      });
      scoolTeachers.sorted((a, b) {
        final firstNameA = a.firstName.toLowerCase();
        final firstNameB = b.firstName.toLowerCase();
        return firstNameA.compareTo(firstNameB);
      });
      teachers[school.id] = scoolTeachers.toList();
    }

    return teachers;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Liste des enseignant·e·s')),
      drawer: const MainDrawer(),
      body: SingleChildScrollView(
        child: FutureBuilder(
          future: Future.wait([
            SchoolBoardsProvider.mySchoolBoardOf(context),
            getTeachers(context),
          ]),
          builder: (context, snapshot) {
            final schoolBoard = snapshot.data?[0] as SchoolBoard?;
            final schoolTeachers =
                snapshot.data?[1] as Map<String, List<Teacher>>?;
            if (schoolBoard == null || schoolTeachers == null) {
              return const Center(child: CircularProgressIndicator());
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    schoolBoard.name,
                    style: Theme.of(
                      context,
                    ).textTheme.titleLarge!.copyWith(color: Colors.black),
                  ),
                ),
                ...schoolTeachers.keys.map(
                  (String schoolId) => _SchoolTeachers(
                    schoolId: schoolId,
                    teachers: schoolTeachers[schoolId] ?? [],
                    schoolBoard: schoolBoard,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SchoolTeachers extends StatelessWidget {
  const _SchoolTeachers({
    required this.schoolId,
    required this.teachers,
    required this.schoolBoard,
  });

  final String schoolId;
  final List<Teacher> teachers;
  final SchoolBoard schoolBoard;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12.0, top: 8, bottom: 8),
          child: Text(
            utils.IterableExtensions(
                  schoolBoard.schools,
                ).firstWhereOrNull((school) => school.id == schoolId)?.name ??
                'École introuvable',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        if (teachers.isEmpty)
          Center(child: Text('Aucun enseignant·e inscrit·e')),
        if (teachers.isNotEmpty)
          ...teachers.map(
            (Teacher teacher) =>
                _TeacherListTile(key: ValueKey(teacher.id), teacher: teacher),
          ),
        const Divider(),
      ],
    );
  }
}

class _TeacherListTile extends StatefulWidget {
  const _TeacherListTile({super.key, required this.teacher});

  final Teacher teacher;

  @override
  State<_TeacherListTile> createState() => _TeacherListTileState();
}

class _TeacherListTileState extends State<_TeacherListTile> {
  bool _isExpanded = false;
  bool _isEditing = false;
  TextEditingController? _firstNameController;
  TextEditingController? _lastNameController;
  final Map<TextEditingController, int?> _currentGroups = {};
  TextEditingController? _emailController;

  void _onClickedEditing() {
    if (_isEditing) {
      // Finish editing
      final newTeacher = widget.teacher.copyWith(
        firstName: _firstNameController?.text,
        lastName: _lastNameController?.text,
        email: _emailController?.text,
        groups:
            _currentGroups.keys
                .map((e) => e.text)
                .where((e) => e.isNotEmpty)
                .toList(),
      );

      if (newTeacher.getDifference(widget.teacher).isNotEmpty) {
        TeachersProvider.of(context, listen: false).replace(newTeacher);
      }
    } else {
      // Start editing
      _firstNameController = TextEditingController(
        text: widget.teacher.firstName,
      );
      _lastNameController = TextEditingController(
        text: widget.teacher.lastName,
      );
      _currentGroups.clear();
      for (var group in widget.teacher.groups) {
        _currentGroups[TextEditingController(text: group)] = int.tryParse(
          group,
        );
      }
      _emailController = TextEditingController(text: widget.teacher.email);
    }

    setState(() => _isEditing = !_isEditing);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedExpandingCard(
      initialExpandedState: _isExpanded,
      onTapHeader: (isExpanded) => setState(() => _isExpanded = isExpanded),
      header: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 12.0, top: 8, bottom: 8),
            child: Text(
              '${widget.teacher.firstName} ${widget.teacher.lastName}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          if (_isExpanded)
            IconButton(
              icon: Icon(
                _isEditing ? Icons.save : Icons.edit,
                color: Colors.black,
              ),
              onPressed: _onClickedEditing,
            ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 24.0, bottom: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildName(),
            const SizedBox(height: 4),
            _buildGroups(),
            const SizedBox(height: 4),
            _buildEmail(),
          ],
        ),
      ),
    );
  }

  Widget _buildName() {
    return _isEditing
        ? Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _firstNameController,
              decoration: const InputDecoration(labelText: 'Prénom'),
            ),
            TextFormField(
              controller: _lastNameController,
              decoration: const InputDecoration(labelText: 'Nom de famille'),
            ),
          ],
        )
        : Container();
  }

  Widget _buildGroups() {
    if (widget.teacher.groups.isEmpty) {
      return const Text('Aucun groupe');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_isEditing)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (int i = 0; i < _currentGroups.keys.length; i++)
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _currentGroups.keys.elementAt(i),
                        keyboardType: TextInputType.number,
                        decoration:
                            i == 0
                                ? const InputDecoration(labelText: 'Groupes')
                                : null,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _currentGroups.remove(
                            _currentGroups.keys.elementAt(i),
                          );
                        });
                      },
                      icon: Icon(Icons.delete, color: Colors.red),
                    ),
                  ],
                ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextButton(
                    onPressed:
                        () => setState(
                          () => _currentGroups[TextEditingController()] = null,
                        ),
                    child: const Text('Ajouter un groupe'),
                  ),
                ),
              ),
            ],
          ),
        if (!_isEditing) Text('Groupes : ${widget.teacher.groups.join(', ')}'),
      ],
    );
  }

  Widget _buildEmail() {
    return _isEditing
        ? TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(labelText: 'Courriel'),
        )
        : Text('Courriel : ${widget.teacher.email ?? 'Courriel introuvable'}');
  }
}
