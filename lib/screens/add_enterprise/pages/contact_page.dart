import 'package:flutter/material.dart';

import '/common/widgets/phone_list_tile.dart';
import '/misc/form_service.dart';

class ContactPage extends StatefulWidget {
  const ContactPage({super.key});

  @override
  State<ContactPage> createState() => ContactPageState();
}

class ContactPageState extends State<ContactPage> {
  final _formKey = GlobalKey<FormState>();

  String? contactName;
  String? contactFunction;
  String? contactPhone;
  String? contactEmail;

  ///
  /// Validate if all the fields are correct
  ///
  Future<String?> validate() async {
    _formKey.currentState!.save();

    if (!_formKey.currentState!.validate()) {
      return 'Assurez vous que tous les champs soient emplis';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          children: [
            const ListTile(
              visualDensity:
                  VisualDensity(vertical: VisualDensity.minimumDensity),
              title: Text('Entreprise représentée par'),
            ),
            ListTile(
              title: TextFormField(
                decoration: const InputDecoration(labelText: '* Nom'),
                validator: FormService.textNotEmptyValidator,
                onSaved: (name) => contactName = name!,
              ),
            ),
            ListTile(
              title: TextFormField(
                decoration: const InputDecoration(labelText: '* Fonction'),
                validator: FormService.textNotEmptyValidator,
                onSaved: (function) => contactFunction = function!,
              ),
            ),
            PhoneListTile(
              onSaved: (phone) => contactPhone = phone!,
              isMandatory: true,
              enabled: true,
            ),
            ListTile(
              title: TextFormField(
                decoration: const InputDecoration(
                  icon: Icon(Icons.mail),
                  labelText: '* Courriel',
                ),
                validator: FormService.emailValidator,
                onSaved: (email) => contactEmail = email!,
                keyboardType: TextInputType.emailAddress,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }
}
