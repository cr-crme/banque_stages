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

class TeachersListScreen extends StatefulWidget {
  const TeachersListScreen({super.key});

  static const route = '/teachers_list';

  @override
  State<TeachersListScreen> createState() => _TeachersListScreenState();
}

class _TeachersListScreenState extends State<TeachersListScreen> {
  final _teachersKey = <String, GlobalKey>{};

  Future<List<Teacher>> getTeachers(BuildContext context) async {
    final teachers = TeachersProvider.of(context, listen: true);
    final schoolBoard = await SchoolBoardsProvider.mySchoolBoardOf(context);
    final schools = schoolBoard?.schools ?? [];

    // Sort by school name
    teachers.sorted((a, b) {
      final schoolA =
          utils.IterableExtensions(
            schools,
          ).firstWhereOrNull((e) => e.id == a.schoolId)?.name ??
          '';
      final schoolB =
          utils.IterableExtensions(
            schools,
          ).firstWhereOrNull((e) => e.id == b.schoolId)?.name ??
          '';
      return schoolA.compareTo(schoolB);
    });

    // Sort by last name
    teachers.sorted((a, b) {
      final lastNameA = a.lastName.toLowerCase();
      final lastNameB = b.lastName.toLowerCase();
      return lastNameA.compareTo(lastNameB);
    });
    // Sort by first name
    teachers.sorted((a, b) {
      final firstNameA = a.firstName.toLowerCase();
      final firstNameB = b.firstName.toLowerCase();
      return firstNameA.compareTo(firstNameB);
    });

    // Set the key for each teacher
    for (final teacher in teachers) {
      if (_teachersKey[teacher.id] != null) continue;
      _teachersKey[teacher.id] = GlobalKey(
        debugLabel: '${teacher.firstName} ${teacher.lastName}',
      );
    }

    return [...teachers];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Liste des enseignant·e·s')),
      drawer: const MainDrawer(),
      body: FutureBuilder(
        future: Future.wait([
          SchoolBoardsProvider.mySchoolBoardOf(context),
          getTeachers(context),
        ]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final schoolBoard = snapshot.data?[0] as SchoolBoard?;
          final teachers = snapshot.data?[1] as List<Teacher>?;
          if (schoolBoard == null || teachers == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView.builder(
            itemCount: teachers.length,
            itemBuilder:
                (context, index) => _TeacherListTile(
                  key: _teachersKey[teachers[index].id],
                  teacher: teachers[index],
                  schoolBoard: schoolBoard,
                ),
          );
        },
      ),
    );
  }
}

class _TeacherListTile extends StatefulWidget {
  const _TeacherListTile({
    super.key,
    required this.teacher,
    required this.schoolBoard,
  });

  final Teacher teacher;
  final SchoolBoard schoolBoard;

  @override
  State<_TeacherListTile> createState() => _TeacherListTileState();
}

class _TeacherListTileState extends State<_TeacherListTile> {
  bool _isExpanded = false;
  bool _isEditing = false;
  final Map<TextEditingController, int?> _currentGroups = {};
  TextEditingController? _emailController;

  void _onClickedEditing() {
    if (_isEditing) {
      // Finish editing
      final newTeacher = widget.teacher.copyWith(
        firstName: widget.teacher.firstName,
        middleName: widget.teacher.middleName,
        lastName: widget.teacher.lastName,
        email: _emailController?.text,
        phone: widget.teacher.phone,
        address: widget.teacher.address,
        dateBirth: widget.teacher.dateBirth,
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
      _currentGroups.clear();
      for (var group in widget.teacher.groups) {
        _currentGroups[TextEditingController(text: group)] = int.tryParse(
          group,
        );
      }
      _emailController = TextEditingController(text: widget.teacher.email);
    }

    setState(() {
      _isEditing = !_isEditing;
    });
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
            Text(
              'École : ${utils.IterableExtensions(widget.schoolBoard.schools).firstWhereOrNull((e) => e.id == widget.teacher.schoolId)?.name ?? 'Nom de l\'école introuvable'}',
            ),
            const SizedBox(height: 4),
            _buildGroups(),
            const SizedBox(height: 4),
            _buildEmail(),
          ],
        ),
      ),
    );
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
              for (final controller in _currentGroups.keys)
                TextFormField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Groupe'),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
