import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';

import '/common/models/address.dart';
import '/common/models/person.dart';
import '/common/models/phone_number.dart';
import '/common/models/student.dart';
import '/common/providers/students_provider.dart';
import '/common/widgets/dialogs/confirm_pop_dialog.dart';
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
  String? _address;

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

    if (!FormService.validateForm(_formKey, save: true)) {
      return;
    }
    late Address address;
    try {
      address = (await Address.fromAddress(_address!))!;
    } catch (e) {
      return;
    }

    editing = false;
    if (mounted) {
      StudentsProvider.of(context, listen: false).replace(
        widget.student.copyWith(
          phone: PhoneNumber.fromString(_phone), // TODO check if validated
          email: _email,
          address: address,
          contact: Person(
              firstName: _contactFirstName!,
              lastName: _contactLastName!,
              phone: PhoneNumber.fromString(
                  _contactPhone), // TODO check if validated
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
                onSavedAddress: (address) => _address = address,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SubTitle(AppLocalizations.of(context)!.generalInformations, top: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 140,
              height: 105,
              child: student.avatar,
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  AppLocalizations.of(context)!.student_name,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  student.fullName,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
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
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              children: [
                Text(
                  AppLocalizations.of(context)!.student_program,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  student.program.name,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(width: 100),
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
        )
      ],
    );
  }
}

class _ContactInformation extends StatefulWidget {
  const _ContactInformation({
    required this.student,
    required this.isEditing,
    required this.onSavedPhone,
    required this.onSavedEmail,
    required this.onSavedAddress,
  });

  final Student student;
  final bool isEditing;
  final Function(String?) onSavedPhone;
  final Function(String?) onSavedEmail;
  final Function(String?) onSavedAddress;

  @override
  State<_ContactInformation> createState() => _ContactInformationState();
}

class _ContactInformationState extends State<_ContactInformation> {
  late final _phoneController =
      TextEditingController(text: widget.student.phone.toString());

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
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.phoneNumber,
                ),
                validator: (value) =>
                    value == '' ? null : FormService.phoneValidator(value),
                enabled: widget.isEditing,
                onSaved: (value) {
                  widget.onSavedPhone(value);
                  _phoneController.text =
                      PhoneNumber.fromString(value).toString();
                  setState(() {});
                },
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: TextEditingController(text: widget.student.email),
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.email,
                ),
                enabled: widget.isEditing,
                onSaved: widget.onSavedEmail,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: TextEditingController(
                    text: widget.student.address.toString()),
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.address,
                ),
                maxLines: null,
                enabled: widget.isEditing,
                onSaved: widget.onSavedAddress,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _EmergencyContact extends StatefulWidget {
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
  State<_EmergencyContact> createState() => _EmergencyContactState();
}

class _EmergencyContactState extends State<_EmergencyContact> {
  late final _phoneController =
      TextEditingController(text: widget.student.contact.phone.toString());

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
                controller: TextEditingController(
                    text: widget.student.contact.firstName),
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.firstName,
                ),
                enabled: widget.isEditing,
                onSaved: widget.onSavedFirstName,
              ),
              TextFormField(
                controller: TextEditingController(
                    text: widget.student.contact.lastName),
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.lastName,
                ),
                enabled: widget.isEditing,
                onSaved: widget.onSavedLastName,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller:
                    TextEditingController(text: widget.student.contactLink),
                decoration: InputDecoration(
                  labelText:
                      AppLocalizations.of(context)!.student_linkWithStudent,
                ),
                enabled: widget.isEditing,
                onSaved: widget.onSavedLink,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.phoneNumber,
                ),
                validator: FormService.phoneValidator,
                enabled: widget.isEditing,
                onSaved: (value) {
                  widget.onSavedPhone(value);
                  _phoneController.text =
                      PhoneNumber.fromString(value).toString();
                  setState(() {});
                },
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller:
                    TextEditingController(text: widget.student.contact.email),
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.email,
                ),
                enabled: widget.isEditing,
                onSaved: widget.onSavedEmail,
              ),
            ],
          ),
        )
      ],
    );
  }
}
