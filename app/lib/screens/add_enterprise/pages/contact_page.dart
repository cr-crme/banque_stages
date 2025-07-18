import 'package:common_flutter/widgets/email_list_tile.dart';
import 'package:common_flutter/widgets/phone_list_tile.dart';
import 'package:crcrme_banque_stages/common/widgets/sub_title.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

final _logger = Logger('ContactPage');

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
    _logger.finer('Validating ContactPage');
    _formKey.currentState!.save();

    if (!_formKey.currentState!.validate()) {
      return 'Remplir tous les champs avec un *.';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    _logger.finer('Building ContactPage');

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: FocusScope(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SubTitle('Entreprise représentée par', left: 0, top: 0),
              TextFormField(
                decoration: const InputDecoration(labelText: '* Prénom'),
                validator: (text) => text!.isEmpty
                    ? 'Ajouter le nom de la personne représentant l\'entreprise.'
                    : null,
                onSaved: (name) => contactFirstName = name!,
              ),
              TextFormField(
                decoration:
                    const InputDecoration(labelText: '* Nom de famille'),
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
                canCall: false,
                enabled: true,
              ),
              EmailListTile(
                onSaved: (email) => contactEmail = email!,
                isMandatory: true,
                canMail: false,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
