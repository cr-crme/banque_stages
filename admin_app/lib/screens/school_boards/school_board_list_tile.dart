import 'package:admin_app/providers/auth_provider.dart';
import 'package:admin_app/providers/school_boards_provider.dart';
import 'package:admin_app/screens/school_boards/confirm_delete_school_board_dialog.dart';
import 'package:admin_app/screens/school_boards/add_school_dialog.dart';
import 'package:admin_app/screens/school_boards/school_list_tile.dart';
import 'package:admin_app/widgets/animated_expanding_card.dart';
import 'package:common/models/generic/access_level.dart';
import 'package:common/models/school_boards/school.dart';
import 'package:common/models/school_boards/school_board.dart';
import 'package:common/utils.dart';
import 'package:flutter/material.dart';

class SchoolBoardListTile extends StatefulWidget {
  const SchoolBoardListTile({
    super.key,
    required this.schoolBoard,
    this.isExpandable = true,
    this.forceEditingMode = false,
  });

  final bool isExpandable;
  final bool forceEditingMode;
  final SchoolBoard schoolBoard;

  @override
  State<SchoolBoardListTile> createState() => SchoolBoardListTileState();
}

class SchoolBoardListTileState extends State<SchoolBoardListTile> {
  final _formKey = GlobalKey<FormState>();
  Future<bool> validate() async {
    // We do both like so, so all the fields get validated even if one is not valid
    bool isValid = _formKey.currentState?.validate() ?? false;
    return isValid;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  bool _isExpanded = true;
  bool _isEditing = false;
  // TODO Test if a AccessLevel.user user can edit a school board
  late final bool _canEdit =
      (AuthProvider.of(context, listen: false).databaseAccessLevel ??
          AccessLevel.teacher) >=
      AccessLevel.superAdmin;

  late final _nameController = TextEditingController(
    text: widget.schoolBoard.name,
  );

  SchoolBoard get editedSchoolBoard =>
      widget.schoolBoard.copyWith(name: _nameController.text);

  @override
  void initState() {
    super.initState();
    if (widget.forceEditingMode) _onClickedEditing();
  }

  Future<void> _onClickedDeleting() async {
    // Show confirmation dialog
    final answer = await showDialog(
      context: context,
      builder:
          (context) =>
              ConfirmDeleteSchoolBoardDialog(schoolBoard: widget.schoolBoard),
    );
    if (answer == null || !answer || !mounted) return;

    SchoolBoardsProvider.of(context).remove(widget.schoolBoard);
  }

  Future<void> _onClickedEditing() async {
    if (_isEditing) {
      // Validate the form
      if (!(await validate()) || !mounted) return;

      // Finish editing
      final newSchoolBoard = editedSchoolBoard;
      if (newSchoolBoard.getDifference(widget.schoolBoard).isNotEmpty) {
        SchoolBoardsProvider.of(context, listen: false).replace(newSchoolBoard);
      }
    }

    setState(() => _isEditing = !_isEditing);
  }

  @override
  Widget build(BuildContext context) {
    return widget.isExpandable
        ? AnimatedExpandingCard(
          initialExpandedState: _isExpanded,
          elevation: 5.0,
          onTapHeader: (isExpanded) => setState(() => _isExpanded = isExpanded),
          header: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 12.0, top: 8, bottom: 8),
                child: Text(
                  widget.schoolBoard.name,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              if (_isExpanded && _canEdit)
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: _onClickedDeleting,
                    ),
                    IconButton(
                      icon: Icon(
                        _isEditing ? Icons.save : Icons.edit,
                        color: Theme.of(context).primaryColor,
                      ),
                      onPressed: _onClickedEditing,
                    ),
                  ],
                ),
            ],
          ),
          child: _buildEditingForm(),
        )
        : _buildEditingForm();
  }

  Widget _buildEditingForm() {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.only(left: 24.0, bottom: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [_buildName(), _buildSchoolNames()],
        ),
      ),
    );
  }

  Widget _buildName() {
    return _isEditing
        ? Padding(
          padding: const EdgeInsets.only(right: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                validator:
                    (value) =>
                        value?.isEmpty == true
                            ? 'Le nom de la commission scolaire est obligatoire'
                            : null,
                decoration: const InputDecoration(
                  labelText: 'Nom de la commission scolaire',
                ),
              ),
            ],
          ),
        )
        : Container();
  }

  Future<void> _showAddSchoolDialog(SchoolBoard schoolBoard) async {
    final answer = await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => AddSchoolDialog(schoolBoard: schoolBoard),
    );
    if (answer is! School || !mounted) return;

    schoolBoard.schools.add(answer);
    SchoolBoardsProvider.of(context, listen: false).replace(schoolBoard);
  }

  Widget _buildSchoolNames() {
    final schools = _getSchools(widget.schoolBoard);

    return Padding(
      padding: const EdgeInsets.only(right: 12.0),
      child: Column(
        children: [
          schools.isEmpty
              ? const Text('Aucune école associée')
              : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...schools.map(
                    (school) => Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: SchoolListTile(
                        school: school,
                        schoolBoard: widget.schoolBoard,
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
          if (_canEdit && !widget.forceEditingMode)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Center(
                child: TextButton(
                  onPressed: () => _showAddSchoolDialog(widget.schoolBoard),
                  child: Text('Ajouter une école'),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

List<School> _getSchools(SchoolBoard schoolBoard) {
  final schools = schoolBoard.schools;

  schools.sort((a, b) {
    final nameA = a.name.toLowerCase();
    final nameB = b.name.toLowerCase();
    return nameA.compareTo(nameB);
  });
  return schools;
}
