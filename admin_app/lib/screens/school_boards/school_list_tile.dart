import 'package:admin_app/screens/school_boards/confirm_delete_school_dialog.dart';
import 'package:common/models/generic/access_level.dart';
import 'package:common/models/generic/phone_number.dart';
import 'package:common/models/school_boards/school.dart';
import 'package:common/models/school_boards/school_board.dart';
import 'package:common/utils.dart';
import 'package:common_flutter/providers/auth_provider.dart';
import 'package:common_flutter/providers/school_boards_provider.dart';
import 'package:common_flutter/widgets/address_list_tile.dart';
import 'package:common_flutter/widgets/animated_expanding_card.dart';
import 'package:common_flutter/widgets/phone_list_tile.dart';
import 'package:common_flutter/widgets/show_snackbar.dart';
import 'package:flutter/material.dart';

class SchoolListTile extends StatefulWidget {
  const SchoolListTile({
    super.key,
    required this.school,
    required this.schoolBoard,
    this.isExpandable = true,
    this.forceEditingMode = false,
    this.elevation = 10.0,
    required this.canEdit,
    required this.canDelete,
  });

  final School school;
  final bool isExpandable;
  final bool forceEditingMode;
  final SchoolBoard schoolBoard;
  final double elevation;
  final bool canEdit;
  final bool canDelete;

  @override
  State<SchoolListTile> createState() => SchoolListTileState();
}

class SchoolListTileState extends State<SchoolListTile> {
  final _formKey = GlobalKey<FormState>();
  Future<bool> validate() async {
    // We do both like so, so all the fields get validated even if one is not valid
    await _addressController.waitForValidation();

    bool isValid = _formKey.currentState?.validate() ?? false;
    isValid = _addressController.isValid && isValid;
    return isValid;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  bool _isExpanded = false;
  bool _isEditing = false;
  late final bool _canEdit =
      AuthProvider.of(context, listen: false).databaseAccessLevel >=
      AccessLevel.admin;

  late final _nameController = TextEditingController(text: widget.school.name);
  late final _addressController = AddressController(
    initialValue: widget.school.address,
  );
  late final _phoneController = TextEditingController(
    text: widget.school.phone.toString(),
  );

  School get editedSchool => widget.school.copyWith(
    name: _nameController.text,
    address: _addressController.address,
    phone: PhoneNumber.fromString(
      _phoneController.text,
      id: widget.school.phone.id,
    ),
  );

  @override
  void initState() {
    super.initState();
    if (widget.forceEditingMode) _onClickedEditing();
  }

  Future<void> _onClickedDeleting() async {
    // Show confirmation dialog
    final answer = await showDialog(
      context: context,
      builder: (context) => ConfirmDeleteSchoolDialog(school: widget.school),
    );
    if (answer == null || !answer || !mounted) return;

    widget.schoolBoard.schools.removeWhere(
      (school) => school.id == widget.school.id,
    );
    final isSuccess = await SchoolBoardsProvider.of(
      context,
    ).replaceWithConfirmation(widget.schoolBoard);
    if (!mounted) return;

    showSnackBar(
      context,
      message:
          isSuccess
              ? 'L\'école a été supprimée avec succès'
              : 'Une erreur est survenue lors de la suppression de l\'école',
    );
  }

  Future<void> _onClickedEditing() async {
    if (_isEditing) {
      // Validate the form
      if (!(await validate()) || !mounted) return;

      // Finish editing
      final newSchool = editedSchool;
      if (newSchool.getDifference(widget.school).isNotEmpty) {
        widget.schoolBoard.schools.removeWhere(
          (school) => school.id == widget.school.id,
        );
        widget.schoolBoard.schools.add(newSchool);
        final isSuccess = await SchoolBoardsProvider.of(
          context,
          listen: false,
        ).replaceWithConfirmation(widget.schoolBoard);
        if (!mounted) return;

        showSnackBar(
          context,
          message:
              isSuccess
                  ? 'L\'école a été modifiée avec succès'
                  : 'Une erreur est survenue lors de la modification de l\'école',
        );
      }
    }

    setState(() => _isEditing = !_isEditing);
  }

  @override
  Widget build(BuildContext context) {
    return widget.isExpandable
        ? AnimatedExpandingCard(
          initialExpandedState: _isExpanded,
          elevation: widget.elevation,
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
              if (_isExpanded && _canEdit)
                Row(
                  children: [
                    if (widget.canDelete)
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: _onClickedDeleting,
                      ),
                    if (widget.canEdit)
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
          children: [_buildName(), _buildAddress(), _buildPhone()],
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
                            ? 'Le nom de l\'école est requis'
                            : null,
                decoration: const InputDecoration(labelText: 'Nom de l\'école'),
              ),
            ],
          ),
        )
        : Container();
  }

  Widget _buildAddress() {
    return Padding(
      padding: const EdgeInsets.only(right: 12.0),
      child: AddressListTile(
        title: 'Adresse de l\'école',
        addressController: _addressController,
        isMandatory: true,
        enabled: _isEditing,
      ),
    );
  }

  Widget _buildPhone() {
    return Padding(
      padding: const EdgeInsets.only(right: 12.0),
      child: PhoneListTile(
        title: 'Téléphone',
        controller: _phoneController,
        isMandatory: true,
        enabled: _isEditing,
      ),
    );
  }
}
