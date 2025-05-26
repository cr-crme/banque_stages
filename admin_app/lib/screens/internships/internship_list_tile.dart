import 'package:admin_app/providers/internships_provider.dart';
import 'package:admin_app/screens/internships/confirm_delete_internship_dialog.dart';
import 'package:admin_app/widgets/animated_expanding_card.dart';
import 'package:common/models/internships/internship.dart';
import 'package:common/utils.dart';
import 'package:flutter/material.dart';

class InternshipListTile extends StatefulWidget {
  const InternshipListTile({
    super.key,
    required this.internship,
    this.isExpandable = true,
    this.forceEditingMode = false,
  });

  final Internship internship;
  final bool isExpandable;
  final bool forceEditingMode;

  @override
  State<InternshipListTile> createState() => InternshipListTileState();
}

class InternshipListTileState extends State<InternshipListTile> {
  final _formKey = GlobalKey<FormState>();
  Future<bool> validate() async {
    // We do both like so, so all the fields get validated even if one is not valid
    bool isValid = _formKey.currentState?.validate() ?? false;
    return isValid;
  }

  @override
  void dispose() {
    _teacherNotesController.dispose();
    super.dispose();
  }

  bool _isExpanded = false;
  bool _isEditing = false;

  late final _teacherNotesController = TextEditingController(
    text: widget.internship.teacherNotes,
  );

  Internship get editedInternship =>
      widget.internship.copyWith(teacherNotes: _teacherNotesController.text);

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
              ConfirmDeleteInternshipDialog(internship: widget.internship),
    );
    if (answer == null || !answer || !mounted) return;

    InternshipsProvider.of(context, listen: false).remove(widget.internship);
  }

  Future<void> _onClickedEditing() async {
    if (_isEditing) {
      // Validate the form
      if (!(await validate()) || !mounted) return;

      // Finish editing
      final newInternship = editedInternship;
      if (newInternship.getDifference(widget.internship).isNotEmpty) {
        InternshipsProvider.of(context, listen: false).replace(newInternship);
      }
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
                  'Coucou',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              if (_isExpanded)
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
          children: [_buildTeacherNotes()],
        ),
      ),
    );
  }

  Widget _buildTeacherNotes() {
    return Padding(
      padding: const EdgeInsets.only(right: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _teacherNotesController,
            enabled: _isEditing,
            style: TextStyle(color: Colors.black),
            decoration: const InputDecoration(
              labelText: 'Notes de l\'enseignant·e·s',
              labelStyle: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
