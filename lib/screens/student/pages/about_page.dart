import 'package:crcrme_banque_stages/common/models/student.dart';
import 'package:crcrme_banque_stages/common/widgets/address_list_tile.dart';
import 'package:crcrme_banque_stages/common/widgets/phone_list_tile.dart';
import 'package:crcrme_banque_stages/common/widgets/sub_title.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';

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

  final _addressController = AddressController();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _GeneralInformation(
                student: widget.student, dateFormat: _dateFormat),
            _ContactInformation(
              student: widget.student,
              addressController: _addressController,
            ),
            _EmergencyContact(student: widget.student),
          ],
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
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium!
                          .copyWith(color: Colors.grey[700]),
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
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium!
                          .copyWith(color: Colors.grey[700]),
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
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium!
                      .copyWith(color: Colors.grey[700]),
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
    required this.addressController,
  });

  final Student student;
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
                  initialValue: student.phone,
                  isMandatory: false,
                  enabled: false),
              const SizedBox(height: 8),
              TextFormField(
                controller: TextEditingController(text: student.email),
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.email,
                  disabledBorder: InputBorder.none,
                ),
                enabled: false,
              ),
              const SizedBox(height: 8),
              AddressListTile(
                initialValue: student.address,
                addressController: addressController,
                isMandatory: false,
                enabled: false,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _EmergencyContact extends StatelessWidget {
  const _EmergencyContact({required this.student});

  final Student student;

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
                  disabledBorder: InputBorder.none,
                ),
                enabled: false,
              ),
              TextFormField(
                controller:
                    TextEditingController(text: student.contact.lastName),
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.lastName,
                  disabledBorder: InputBorder.none,
                ),
                enabled: false,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: TextEditingController(text: student.contactLink),
                decoration: InputDecoration(
                  labelText:
                      AppLocalizations.of(context)!.student_linkWithStudent,
                  disabledBorder: InputBorder.none,
                ),
                enabled: false,
              ),
              const SizedBox(height: 8),
              PhoneListTile(
                initialValue: student.contact.phone,
                enabled: false,
                isMandatory: false,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: TextEditingController(text: student.contact.email),
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.email,
                  disabledBorder: InputBorder.none,
                ),
                enabled: false,
              ),
              const SizedBox(height: 12),
            ],
          ),
        )
      ],
    );
  }
}
