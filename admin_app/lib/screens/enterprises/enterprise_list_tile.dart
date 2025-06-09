import 'package:admin_app/screens/enterprises/activity_type_list_tile.dart';
import 'package:admin_app/screens/enterprises/confirm_delete_enterprise_dialog.dart';
import 'package:admin_app/screens/enterprises/job_list_tile.dart';
import 'package:admin_app/widgets/address_list_tile.dart';
import 'package:admin_app/widgets/email_list_tile.dart';
import 'package:admin_app/widgets/phone_list_tile.dart';
import 'package:admin_app/widgets/teacher_picker_tile.dart';
import 'package:admin_app/widgets/web_site_list_tile.dart';
import 'package:common/models/enterprises/enterprise.dart';
import 'package:common/models/enterprises/job.dart';
import 'package:common/models/enterprises/job_list.dart';
import 'package:common/models/generic/phone_number.dart';
import 'package:common/models/persons/teacher.dart';
import 'package:common/utils.dart';
import 'package:common_flutter/providers/enterprises_provider.dart';
import 'package:common_flutter/providers/teachers_provider.dart';
import 'package:common_flutter/widgets/animated_expanding_card.dart';
import 'package:common_flutter/widgets/show_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
    await _headquartersAddressController.waitForValidation();
    bool isValid = _formKey.currentState?.validate() ?? false;
    isValid = _addressController.isValid && isValid;
    isValid = _headquartersAddressController.isValid && isValid;
    return isValid;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _activityTypeController.dispose();
    _teacherPickerController.dispose();
    _phoneController.dispose();
    _faxController.dispose();
    _websiteController.dispose();
    _addressController.dispose();
    _headquartersAddressController.dispose();
    _contactFirstNameController.dispose();
    _contactLastNameController.dispose();
    _contactFunctionController.dispose();
    _contactPhoneController.dispose();
    _contactEmailController.dispose();
    _neqController.dispose();
    super.dispose();
  }

  bool _isExpanded = false;
  bool _isEditing = false;

  late final _nameController = TextEditingController(
    text: widget.enterprise.name,
  );
  late final _activityTypeController = ActivityTypeListController(
    initial: widget.enterprise.activityTypes,
  );
  late final _jobControllers = Map.fromEntries(
    widget.enterprise.jobs.map(
      (job) => MapEntry(job.id, JobListController(job: job)),
    ),
  );
  late final _teacherPickerController = TeacherPickerController(
    initial: TeachersProvider.of(context, listen: true).firstWhereOrNull(
      (teacher) => teacher.id == widget.enterprise.recruiterId,
    ),
  );
  late final _phoneController = TextEditingController(
    text: widget.enterprise.phone?.toString(),
  );
  late final _faxController = TextEditingController(
    text: widget.enterprise.fax?.toString(),
  );
  late final _websiteController = TextEditingController(
    text: widget.enterprise.website,
  );
  late final _addressController = AddressController(
    initialValue: widget.enterprise.address,
  );
  late final _headquartersAddressController = AddressController(
    initialValue: widget.enterprise.headquartersAddress,
  );
  late final _contactFirstNameController = TextEditingController(
    text: widget.enterprise.contact.firstName,
  );
  late final _contactLastNameController = TextEditingController(
    text: widget.enterprise.contact.lastName,
  );
  late final _contactFunctionController = TextEditingController(
    text: widget.enterprise.contactFunction,
  );
  late final _contactPhoneController = TextEditingController(
    text: widget.enterprise.contact.phone?.toString(),
  );
  late final _contactEmailController = TextEditingController(
    text: widget.enterprise.contact.email,
  );
  late final _neqController = TextEditingController(
    text: widget.enterprise.neq,
  );

  Enterprise get editedEnterprise => widget.enterprise.copyWith(
    name: _nameController.text,
    activityTypes: _activityTypeController.activityTypes,
    recruiterId: _teacherPickerController.teacher.id,
    phone: PhoneNumber.fromString(
      _phoneController.text,
      id: widget.enterprise.phone?.id,
    ),
    fax: PhoneNumber.fromString(
      _faxController.text,
      id: widget.enterprise.fax?.id,
    ),
    jobs:
        JobList()..addAll(
          _jobControllers.values.map((jobController) => jobController.job),
        ),
    website: _websiteController.text,
    address: _addressController.address,
    headquartersAddress: _headquartersAddressController.address,
    contact: widget.enterprise.contact.copyWith(
      firstName: _contactFirstNameController.text,
      lastName: _contactLastNameController.text,
      phone: PhoneNumber.fromString(
        _contactPhoneController.text,
        id: widget.enterprise.contact.phone?.id,
      ),
      email: _contactEmailController.text,
    ),
    contactFunction: _contactFunctionController.text,
    neq: _neqController.text,
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

    final isSuccess = await EnterprisesProvider.of(
      context,
      listen: false,
    ).removeWithConfirmation(widget.enterprise);
    if (!mounted) return;

    showSnackBar(
      context,
      message:
          isSuccess
              ? 'Entreprise supprimée avec succès'
              : 'Échec de la suppression de l\'entreprise',
    );
  }

  Future<void> _onClickedEditing() async {
    if (_isEditing) {
      // Validate the form
      if (!(await validate()) || !mounted) return;

      // Finish editing
      final newEnterprise = editedEnterprise;
      if (newEnterprise.getDifference(widget.enterprise).isNotEmpty) {
        final isSuccess = await EnterprisesProvider.of(
          context,
          listen: false,
        ).replaceWithConfirmation(newEnterprise);
        if (!mounted) return;

        showSnackBar(
          context,
          message:
              isSuccess
                  ? 'Entreprise mise à jour avec succès'
                  : 'Échec de la mise à jour de l\'entreprise',
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
          children: [
            _buildName(),
            const SizedBox(height: 8),
            _buildActivityTypes(),
            const SizedBox(height: 8),
            _buildJob(),
            const SizedBox(height: 8),
            _buildRecruiter(),
            const SizedBox(height: 8),
            _buildAddress(),
            const SizedBox(height: 8),
            _buildPhone(),
            const SizedBox(height: 8),
            _buildFax(),
            const SizedBox(height: 8),
            _buildWebsite(),
            const SizedBox(height: 8),
            _buildHeadquartersAddress(),
            const SizedBox(height: 8),
            _buildContact(),
            const SizedBox(height: 8),
            _buildNeq(),
          ],
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

  Widget _buildActivityTypes() {
    return ActivityTypeListTile(
      controller: _activityTypeController,
      editMode: _isEditing,
    );
  }

  void _addJob() {
    final job = Job.empty;
    setState(() => _jobControllers[job.id] = JobListController(job: job));
  }

  void _deleteJob(String id) {
    setState(() => _jobControllers.remove(id));
  }

  Widget _buildJob() {
    return Padding(
      padding: const EdgeInsets.only(right: 12.0),
      child: Column(
        children: [
          _jobControllers.isEmpty
              ? Padding(
                padding: const EdgeInsets.only(
                  left: 12.0,
                  top: 8.0,
                  bottom: 4.0,
                ),
                child: Text('Aucun stage proposé pour le moment.'),
              )
              : Column(
                children: [
                  ..._jobControllers.keys.map(
                    (jobId) => JobListTile(
                      key: ValueKey(jobId),
                      controller: _jobControllers[jobId]!,
                      editMode: _isEditing,
                      onRequestDelete: () => _deleteJob(jobId),
                    ),
                  ),
                ],
              ),
          if (_isEditing)
            Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 24.0),
              child: TextButton(
                onPressed: _addJob,
                child: const Text('Enregitrer un stage'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRecruiter() {
    _teacherPickerController.teacher =
        TeachersProvider.of(context, listen: false).firstWhereOrNull(
          (teacher) => teacher.id == widget.enterprise.recruiterId,
        ) ??
        Teacher.empty;

    return Padding(
      padding: const EdgeInsets.only(right: 12.0),
      child: TeacherPickerTile(
        title: 'Enseignant·e ayant démarché l\'entreprise',
        schoolBoardId: widget.enterprise.schoolBoardId,
        controller: _teacherPickerController,
        editMode: _isEditing,
      ),
    );
  }

  Widget _buildPhone() {
    return Padding(
      padding: const EdgeInsets.only(right: 12.0),
      child: PhoneListTile(
        title: 'Téléphone',
        controller: _phoneController,
        isMandatory: false,
        enabled: _isEditing,
      ),
    );
  }

  Widget _buildFax() {
    return Padding(
      padding: const EdgeInsets.only(right: 12.0),
      child: PhoneListTile(
        title: 'Fax',
        controller: _faxController,
        isMandatory: false,
        enabled: _isEditing,
      ),
    );
  }

  Widget _buildWebsite() {
    return Padding(
      padding: const EdgeInsets.only(right: 12.0),
      child: WebSiteListTile(
        controller: _websiteController,
        title: 'Site web de l\'entreprise',
        enabled: _isEditing,
      ),
    );
  }

  Widget _buildAddress() {
    return Padding(
      padding: const EdgeInsets.only(right: 12.0),
      child: AddressListTile(
        title: 'Adresse de l\'entreprise',
        addressController: _addressController,
        isMandatory: true,
        enabled: _isEditing,
      ),
    );
  }

  Widget _buildHeadquartersAddress() {
    return Padding(
      padding: const EdgeInsets.only(right: 12.0),
      child: AddressListTile(
        title: 'Adresse du siège social',
        addressController: _headquartersAddressController,
        isMandatory: true,
        enabled: _isEditing,
      ),
    );
  }

  Widget _buildContact() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _isEditing
            ? Text('Contact')
            : Text(
              'Contact : ${widget.enterprise.contact.toString()} (${widget.enterprise.contactFunction})',
            ),
        Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_isEditing)
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _contactFirstNameController,
                        decoration: const InputDecoration(labelText: 'Prénom'),
                        validator: (value) {
                          if (value?.isEmpty == true) {
                            return 'Le prénom du contact est requis';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: _contactLastNameController,
                        decoration: const InputDecoration(
                          labelText: 'Nom de famille',
                        ),
                        validator: (value) {
                          if (value?.isEmpty == true) {
                            return 'Le nom du contact est requis';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              if (_isEditing)
                TextFormField(
                  controller: _contactFunctionController,
                  decoration: const InputDecoration(
                    labelText: 'Fonction dans l\'entreprise',
                  ),
                ),
              const SizedBox(height: 4),
              PhoneListTile(
                controller: _contactPhoneController,
                isMandatory: false,
                enabled: _isEditing,
              ),
              const SizedBox(height: 4),
              EmailListTile(
                controller: _contactEmailController,
                isMandatory: false,
                enabled: _isEditing,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNeq() {
    return Padding(
      padding: const EdgeInsets.only(right: 12.0),
      child: TextFormField(
        controller: _neqController,
        enabled: _isEditing,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: const InputDecoration(
          labelText: 'Numéro d\'entreprise (NEQ)',
          labelStyle: TextStyle(color: Colors.black),
        ),
        style: TextStyle(color: Colors.black),
      ),
    );
  }
}
