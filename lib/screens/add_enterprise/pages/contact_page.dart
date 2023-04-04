import 'package:flutter/material.dart';

import '/common/models/address.dart';
import '/common/widgets/phone_list_tile.dart';
import '/misc/form_service.dart';
import '/screens/enterprise/pages/widgets/show_school.dart';

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
    late final Address addressTp;
    try {
      addressTp = (await Address.fromAddress(address!))!;
    } catch (e) {
      return 'L\'adresse n\'a pu être trouvée';
    }
    if (!mounted) return 'Erreur inconnue';

    final confirmAddress = await showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: const Text('Confimer l\'adresse'),
              content: SingleChildScrollView(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Text('L\'adresse trouvée est :\n$addressTp'),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 1 / 2,
                    width: MediaQuery.of(context).size.width * 2 / 3,
                    child: ShowSchoolAddress(addressTp),
                  )
                ]),
              ),
              actions: [
                OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Annuler')),
                TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Confirmer'))
              ],
            ));
    if (confirmAddress == null || !confirmAddress) {
      return 'Essayer une nouvelle adresse';
    }

    address = addressTp.toString();
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
                maxLines: null,
                keyboardType: TextInputType.streetAddress,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
