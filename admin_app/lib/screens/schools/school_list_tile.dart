import 'package:admin_app/providers/school_boards_provider.dart';
import 'package:admin_app/screens/schools/confirm_delete_school_dialog.dart';
import 'package:admin_app/widgets/animated_expanding_card.dart';
import 'package:common/models/school_boards/school.dart';
import 'package:common/models/school_boards/school_board.dart';
import 'package:common/utils.dart';
import 'package:flutter/material.dart';

class SchoolListTile extends StatefulWidget {
  const SchoolListTile({
    super.key,
    required this.school,
    required this.schoolBoard,
    this.isExpandable = true,
    this.forceEditingMode = false,
  });

  final School school;
  final bool isExpandable;
  final bool forceEditingMode;
  final SchoolBoard schoolBoard;

  @override
  State<SchoolListTile> createState() => SchoolListTileState();
}

class SchoolListTileState extends State<SchoolListTile> {
  final _formKey = GlobalKey<FormState>();
  bool validate() {
    // We do both like so, so all the fields get validated even if one is not valid
    bool isValid = _formKey.currentState?.validate() ?? false;
    return isValid;
  }

  bool _isExpanded = false;
  bool _isEditing = false;

  TextEditingController? _nameController;
  String get firstName => _nameController?.text ?? widget.school.name;

  @override
  void initState() {
    super.initState();
    if (widget.forceEditingMode) _onClickedEditing();
  }

  Future<void> _onClickedDeleting(BuildContext context) async {
    // Show confirmation dialog
    final answer = await showDialog(
      context: context,
      builder: (context) => ConfirmDeleteSchoolDialog(school: widget.school),
    );
    if (answer == null || !answer || !context.mounted) return;

    final schoolBoard = await SchoolBoardsProvider.mySchoolBoardOf(
      context,
      listen: false,
    );
    if (schoolBoard == null || !context.mounted) return;

    schoolBoard.schools.removeWhere((school) => school.id == widget.school.id);
    SchoolBoardsProvider.of(context).replace(schoolBoard);
  }

  void _onClickedEditing() {
    if (_isEditing) {
      // Finish editing
      final newSchool = widget.school.copyWith(name: _nameController?.text);

      if (newSchool.getDifference(widget.school).isNotEmpty) {
        widget.schoolBoard.schools.removeWhere(
          (school) => school.id == widget.school.id,
        );
        widget.schoolBoard.schools.add(newSchool);
        SchoolBoardsProvider.of(
          context,
          listen: false,
        ).replace(widget.schoolBoard);
      }
    } else {
      // Start editing
      _nameController = TextEditingController(text: widget.school.name);
    }

    setState(() => _isEditing = !_isEditing);
  }

  @override
  Widget build(BuildContext context) {
    return widget.isExpandable
        ? AnimatedExpandingCard(
          initialExpandedState: _isExpanded,
          onTapHeader: (isExpanded) => setState(() => _isExpanded = isExpanded),
          header: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 12.0, top: 8, bottom: 8),
                child: Text(
                  widget.school.name,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              if (_isExpanded)
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _onClickedDeleting(context),
                    ),
                    IconButton(
                      icon: Icon(
                        _isEditing ? Icons.save : Icons.edit,
                        color: Colors.black,
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
          children: [_buildName()],
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
              controller: _nameController,
              validator:
                  (value) =>
                      value?.isEmpty == true
                          ? 'Le nom de l\'école est requis'
                          : null,
              decoration: const InputDecoration(labelText: 'Nom de l\'école'),
            ),
          ],
        )
        : Container();
  }
}
