import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';

import '/common/models/person.dart';
import '/common/models/phone_number.dart';
import '/common/models/student.dart';
import '/common/providers/students_provider.dart';
import '/common/widgets/address_list_tile.dart';
import '/common/widgets/dialogs/confirm_pop_dialog.dart';
import '/common/widgets/phone_list_tile.dart';
import '/common/widgets/sub_title.dart';
import '/misc/form_service.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({
    super.key,
    required this.student,
  });

  final Student student;

  @override
  State<AboutPage> createState() => AboutPageState();
}

class AboutPageState extends State<AboutPage> {
  final _formKey = GlobalKey<FormState>();
  final _dateFormat = DateFormat.yMd();

  String? _phone;
  String? _email;
  final _addressController = AddressController();

  String? _contactFirstName;
  String? _contactLastName;
  String? _contactLink;
  String? _contactPhone;
  String? _contactEmail;

  bool editing = false;

  Future<void> toggleEdit() async {
    if (!editing) {
      setState(() => editing = true);
      return;
    }
    final status = await _addressController.requestValidation();
    if (!mounted) return;
    if (status != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(status)));
      return;
    }

    if (!FormService.validateForm(_formKey, save: true)) {
      return;
    }

    editing = false;
    if (mounted) {
      StudentsProvider.of(context, listen: false).replace(
        widget.student.copyWith(
          phone: PhoneNumber.fromString(_phone),
          email: _email,
          address: _addressController.address,
          contact: Person(
              firstName: _contactFirstName!,
              lastName: _contactLastName!,
              phone: PhoneNumber.fromString(_contactPhone),
              email: _contactEmail),
          contactLink: _contactLink,
        ),
      );
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => ConfirmPopDialog.show(context, editing: editing),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _GeneralInformation(
                  student: widget.student, dateFormat: _dateFormat),
              _ContactInformation(
                student: widget.student,
                isEditing: editing,
                onSavedPhone: (phone) => _phone = phone,
                onSavedEmail: (email) => _email = email,
                addressController: _addressController,
              ),
              _EmergencyContact(
                student: widget.student,
                isEditing: editing,
                onSavedFirstName: (name) => _contactFirstName = name,
                onSavedLastName: (name) => _contactLastName = name,
                onSavedLink: (link) => _contactLink = link,
                onSavedPhone: (phone) => _contactPhone = phone,
                onSavedEmail: (email) => _contactEmail = email,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GeneralInformation extends StatelessWidget {
  const _GeneralInformation({required this.student, required this.dateFormat});

  final Student student;
  final DateFormat dateFormat;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SubTitle(AppLocalizations.of(context)!.generalInformations, top: 12),
          Padding(
            padding: const EdgeInsets.only(left: 32.0, right: 40),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(width: 105, height: 105, child: student.avatar),
                Column(
                  children: [
                    Text(
                      AppLocalizations.of(context)!.student_program,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      student.program.title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      AppLocalizations.of(context)!.student_group,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      student.group,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.only(left: 32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  AppLocalizations.of(context)!.dateBirth,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  dateFormat.format(student.dateBirth!),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactInformation extends StatelessWidget {
  const _ContactInformation({
    required this.student,
    required this.isEditing,
    required this.onSavedPhone,
    required this.onSavedEmail,
    required this.addressController,
  });

  final Student student;
  final bool isEditing;
  final Function(String?) onSavedPhone;
  final Function(String?) onSavedEmail;
  final AddressController addressController;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          title: Text(
            AppLocalizations.of(context)!.contactInformations,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              PhoneListTile(
                onSaved: onSavedPhone,
                isMandatory: false,
                enabled: isEditing,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: TextEditingController(text: student.email),
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.email,
                ),
                enabled: isEditing,
                onSaved: onSavedEmail,
              ),
              const SizedBox(height: 8),
              AddressListTile(
                initialValue: student.address,
                addressController: addressController,
                isMandatory: false,
                enabled: isEditing,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _EmergencyContact extends StatelessWidget {
  const _EmergencyContact({
    required this.student,
    required this.isEditing,
    required this.onSavedFirstName,
    required this.onSavedLastName,
    required this.onSavedLink,
    required this.onSavedPhone,
    required this.onSavedEmail,
  });

  final Student student;
  final bool isEditing;
  final Function(String?) onSavedFirstName;
  final Function(String?) onSavedLastName;
  final Function(String?) onSavedLink;
  final Function(String?) onSavedPhone;
  final Function(String?) onSavedEmail;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: Text(
            AppLocalizations.of(context)!.emergencyContact,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              TextFormField(
                controller:
                    TextEditingController(text: student.contact.firstName),
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.firstName,
                ),
                enabled: isEditing,
                onSaved: onSavedFirstName,
              ),
              TextFormField(
                controller:
                    TextEditingController(text: student.contact.lastName),
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.lastName,
                ),
                enabled: isEditing,
                onSaved: onSavedLastName,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: TextEditingController(text: student.contactLink),
                decoration: InputDecoration(
                  labelText:
                      AppLocalizations.of(context)!.student_linkWithStudent,
                ),
                enabled: isEditing,
                onSaved: onSavedLink,
              ),
              const SizedBox(height: 8),
              PhoneListTile(
                onSaved: onSavedPhone,
                enabled: isEditing,
                isMandatory: false,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: TextEditingController(text: student.contact.email),
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.email,
                ),
                enabled: isEditing,
                onSaved: onSavedEmail,
              ),
            ],
          ),
        )
      ],
    );
  }
}
