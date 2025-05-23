import 'package:admin_app/providers/enterprises_provider.dart';
import 'package:admin_app/screens/enterprises/confirm_delete_enterprise_dialog.dart';
import 'package:admin_app/widgets/address_list_tile.dart';
import 'package:admin_app/widgets/animated_expanding_card.dart';
import 'package:common/models/enterprises/enterprise.dart';
import 'package:common/utils.dart';
import 'package:flutter/material.dart';

class EnterpriseListTile extends StatefulWidget {
  const EnterpriseListTile({
    super.key,
    required this.enterprise,
    this.isExpandable = true,
    this.forceEditingMode = false,
  });

  final Enterprise enterprise;
  final bool isExpandable;
  final bool forceEditingMode;

  @override
  State<EnterpriseListTile> createState() => EnterpriseListTileState();
}

class EnterpriseListTileState extends State<EnterpriseListTile> {
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
    super.dispose();
  }

  bool _isExpanded = false;
  bool _isEditing = false;

  late final _nameController = TextEditingController(
    text: widget.enterprise.name,
  );
  late final _addressController = AddressController(
    initialValue: widget.enterprise.address,
  );

  Enterprise get editedEnterprise => widget.enterprise.copyWith(
    name: _nameController.text,
    address: _addressController.address,
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
      builder:
          (context) =>
              ConfirmDeleteEnterpriseDialog(enterprise: widget.enterprise),
    );
    if (answer == null || !answer || !mounted) return;

    EnterprisesProvider.of(context, listen: false).remove(widget.enterprise);
  }

  Future<void> _onClickedEditing() async {
    if (_isEditing) {
      // Validate the form
      if (!(await validate()) || !mounted) return;

      // Finish editing
      final newEnterprise = editedEnterprise;
      if (newEnterprise.getDifference(widget.enterprise).isNotEmpty) {
        EnterprisesProvider.of(context, listen: false).replace(newEnterprise);
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
                  widget.enterprise.name,
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
          children: [_buildName(), _buildAddress()],
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
                            ? 'Le nom de l\'entreprise est requis'
                            : null,
                decoration: const InputDecoration(
                  labelText: 'Nom de l\'entreprise',
                ),
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
        title: 'Adresse de l\'entrerprise',
        addressController: _addressController,
        isMandatory: true,
        enabled: _isEditing,
      ),
    );
  }
}
