import 'package:flutter/material.dart';

import 'package:crcrme_banque_stages/common/widgets/phone_list_tile.dart';
import 'package:crcrme_banque_stages/misc/form_service.dart';

class ContactPage extends StatefulWidget {
  const ContactPage({super.key});

  @override
  State<ContactPage> createState() => ContactPageState();
}

class ContactPageState extends State<ContactPage> {
  final _formKey = GlobalKey<FormState>();

  String? contactFirstName;
  String? contactLastName;
  String? contactFunction;
  String? contactPhone;
  String? contactEmail;

  ///
  /// Validate if all the fields are correct
  ///
  Future<String?> validate() async {
    _formKey.currentState!.save();

    if (!_formKey.currentState!.validate()) {
      return 'Remplir tous les champs avec un *.';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Entreprise représentée par',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: '* Prénom'),
              validator: (text) => text!.isEmpty
                  ? 'Ajouter le nom de la personne représentant l\'entreprise.'
                  : null,
              onSaved: (name) => contactFirstName = name!,
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: '* Nom'),
              validator: (text) => text!.isEmpty
                  ? 'Ajouter le nom de la personne représentant l\'entreprise.'
                  : null,
              onSaved: (name) => contactLastName = name!,
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: '* Fonction'),
              validator: (text) => text!.isEmpty
                  ? 'Ajouter la fonction de cette personne.'
                  : null,
              onSaved: (function) => contactFunction = function!,
            ),
            PhoneListTile(
              onSaved: (phone) => contactPhone = phone!,
              isMandatory: true,
              enabled: true,
            ),
            TextFormField(
              decoration: const InputDecoration(
                icon: Icon(Icons.mail),
                labelText: '* Courriel',
              ),
              validator: FormService.emailValidator,
              onSaved: (email) => contactEmail = email!,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
