import 'package:crcrme_banque_stages/common/models/student.dart';
import 'package:crcrme_banque_stages/common/widgets/address_list_tile.dart';
import 'package:crcrme_banque_stages/common/widgets/email_list_tile.dart';
import 'package:crcrme_banque_stages/common/widgets/phone_list_tile.dart';
import 'package:crcrme_banque_stages/common/widgets/sub_title.dart';
import 'package:flutter/material.dart';
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

  late final _addressController = AddressController()
    ..initialValue = widget.student.address;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(disabledColor: Colors.black),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _GeneralInformation(
                student: widget.student,
                dateFormat: _dateFormat,
                addressController: _addressController,
              ),
              _EmergencyContact(student: widget.student),
            ],
          ),
        ),
      ),
    );
  }
}

class _GeneralInformation extends StatelessWidget {
  const _GeneralInformation({
    required this.student,
    required this.dateFormat,
    required this.addressController,
  });

  final Student student;
  final DateFormat dateFormat;
  final AddressController addressController;

  @override
  Widget build(BuildContext context) {
    // ThemeData does not work anymore so we have to override the style manually
    const styleOverride = TextStyle(color: Colors.black);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SubTitle('Informations générales', top: 12),
          Padding(
            padding: const EdgeInsets.only(left: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    TextFormField(
                      controller: TextEditingController(
                          text: dateFormat.format(student.dateBirth!)),
                      decoration: const InputDecoration(
                        icon: SizedBox(width: 30),
                        labelText: 'Date de naissance',
                        labelStyle: styleOverride,
                        disabledBorder: InputBorder.none,
                      ),
                      style: styleOverride,
                      enabled: false,
                    ),
                    InkWell(
                      borderRadius: BorderRadius.circular(25),
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.cake,
                          color: Colors.grey,
                        ),
                      ),
                    )
                  ],
                ),
                PhoneListTile(
                  titleStyle: styleOverride,
                  contentStyle: styleOverride,
                  initialValue: student.phone,
                  isMandatory: false,
                  enabled: false,
                ),
                const SizedBox(height: 8),
                EmailListTile(
                  controller: TextEditingController(text: student.email),
                  titleStyle: styleOverride,
                  contentStyle: styleOverride,
                  enabled: false,
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.only(left: 12.0),
                  child: AddressListTile(
                    addressController: addressController,
                    titleStyle: styleOverride,
                    contentStyle: styleOverride,
                    isMandatory: false,
                    enabled: false,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmergencyContact extends StatelessWidget {
  const _EmergencyContact({required this.student});

  final Student student;

  @override
  Widget build(BuildContext context) {
    // ThemeData does not work anymore so we have to override the style manually
    const styleOverride = TextStyle(color: Colors.black);

    return Column(
      children: [
        ListTile(
          title: Text(
            'Contact en cas d\'urgence',
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
                decoration: const InputDecoration(
                  labelText: 'Prénom',
                  labelStyle: styleOverride,
                  disabledBorder: InputBorder.none,
                ),
                style: styleOverride,
                enabled: false,
              ),
              TextFormField(
                controller:
                    TextEditingController(text: student.contact.lastName),
                decoration: const InputDecoration(
                  labelText: 'Nom de famille',
                  labelStyle: styleOverride,
                  disabledBorder: InputBorder.none,
                ),
                style: styleOverride,
                enabled: false,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: TextEditingController(text: student.contactLink),
                decoration: const InputDecoration(
                  labelText: 'Lien avec l\'élève',
                  labelStyle: styleOverride,
                  disabledBorder: InputBorder.none,
                ),
                style: styleOverride,
                enabled: false,
              ),
              const SizedBox(height: 8),
              PhoneListTile(
                titleStyle: styleOverride,
                contentStyle: styleOverride,
                initialValue: student.contact.phone,
                enabled: false,
                isMandatory: false,
              ),
              const SizedBox(height: 8),
              EmailListTile(
                titleStyle: styleOverride,
                contentStyle: styleOverride,
                controller: TextEditingController(text: student.contact.email),
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
