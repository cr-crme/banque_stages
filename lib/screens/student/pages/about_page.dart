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
              student: widget.student,
              dateFormat: _dateFormat,
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
                        disabledBorder: InputBorder.none,
                      ),
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
                    initialValue: student.phone,
                    isMandatory: false,
                    enabled: false),
                const SizedBox(height: 8),
                EmailListTile(
                  controller: TextEditingController(text: student.email),
                  enabled: false,
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.only(left: 12.0),
                  child: AddressListTile(
                    initialValue: student.address,
                    addressController: addressController,
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
                  disabledBorder: InputBorder.none,
                ),
                enabled: false,
              ),
              TextFormField(
                controller:
                    TextEditingController(text: student.contact.lastName),
                decoration: const InputDecoration(
                  labelText: 'Nom de famille',
                  disabledBorder: InputBorder.none,
                ),
                enabled: false,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: TextEditingController(text: student.contactLink),
                decoration: const InputDecoration(
                  labelText: 'Lien avec l\'élève',
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
              EmailListTile(
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
