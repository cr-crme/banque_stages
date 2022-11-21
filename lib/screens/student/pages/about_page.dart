import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '/common/models/student.dart';
import '/common/providers/students_provider.dart';
import '/common/widgets/dialogs/confirm_pop_dialog.dart';
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

  String? _phone;
  String? _email;
  String? _address;

  String? _contactName;
  String? _contactLink;
  String? _contactPhone;
  String? _contactEmail;

  bool _editing = false;
  bool get editing => _editing;

  void toggleEdit() {
    if (!_editing) {
      setState(() => _editing = true);
      return;
    }

    if (!FormService.validateForm(_formKey, save: true)) {
      return;
    }

    context.read<StudentsProvider>().replace(
          widget.student.copyWith(
            phone: _phone,
            email: _email,
            address: _address,
            contactName: _contactName,
            contactLink: _contactLink,
            contactPhone: _contactPhone,
            contactEmail: _contactEmail,
          ),
        );

    setState(() => _editing = false);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => ConfirmPopDialog.show(context, editing: editing),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              ListTile(
                title: Text(
                  AppLocalizations.of(context)!.generalInformations,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 140,
                          height: 105,
                          color: Theme.of(context).disabledColor,
                          child: widget.student.photo.isNotEmpty
                              ? Image.network(widget.student.photo)
                              : null,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                AppLocalizations.of(context)!.student_name,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              Text(
                                widget.student.name,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                AppLocalizations.of(context)!.dateBirth,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              Text(
                                widget.student.dateBirth.toString(),
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            Text(
                              AppLocalizations.of(context)!.student_program,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            Text(
                              widget.student.program,
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
                              widget.student.group,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
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
                          text: widget.student.contactName),
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.name,
                      ),
                      enabled: _editing,
                      onSaved: (name) => _contactName = name,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: TextEditingController(
                          text: widget.student.contactLink),
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!
                            .student_linkWithStudent,
                      ),
                      enabled: _editing,
                      onSaved: (link) => _contactLink = link,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: TextEditingController(
                          text: widget.student.contactPhone),
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.phoneNumber,
                      ),
                      enabled: _editing,
                      onSaved: (phone) => _contactPhone = phone,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: TextEditingController(
                          text: widget.student.contactEmail),
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.email,
                      ),
                      enabled: _editing,
                      onSaved: (email) => _contactEmail = email,
                    ),
                  ],
                ),
              ),
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
                      controller:
                          TextEditingController(text: widget.student.phone),
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.phoneNumber,
                      ),
                      enabled: _editing,
                      onSaved: (phone) => _phone = phone,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller:
                          TextEditingController(text: widget.student.email),
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.email,
                      ),
                      enabled: _editing,
                      onSaved: (email) => _email = email,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller:
                          TextEditingController(text: widget.student.address),
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.address,
                      ),
                      enabled: _editing,
                      onSaved: (address) => _address = address,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
