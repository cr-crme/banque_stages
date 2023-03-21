import 'package:crcrme_banque_stages/common/models/address.dart';
import 'package:flutter/material.dart';

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

  String? address;

  ///
  /// Validate if all the fields are correct
  ///
  Future<String?> validate() async {
    _formKey.currentState!.save();
    
    if (!_formKey.currentState!.validate()) {
      return 'Assurez vous que tous les champs soient emplis';
    }
    try {
      await Address.fromAddress(address!);
    } catch (e) {
      return 'L\'adresse n\'a pu être trouvée';
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
              title: Text(' Entreprise représentée par'),
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
            ListTile(
              title: TextFormField(
                decoration: const InputDecoration(
                  icon: Icon(Icons.phone),
                  labelText: '* Téléphone',
                ),
                validator: FormService.phoneValidator,
                onSaved: (phone) => contactPhone = phone!,
                keyboardType: TextInputType.phone,
              ),
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
            const ListTile(
              visualDensity:
                  VisualDensity(vertical: VisualDensity.minimumDensity),
              title: Text('* Adresse de l\'établissement'),
            ),
            ListTile(
              title: TextFormField(
                decoration: const InputDecoration(labelText: 'Adresse'),
                onSaved: (address) => this.address = address!,
                validator: (value) => FormService.textNotEmptyValidator(value),
                keyboardType: TextInputType.streetAddress,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
