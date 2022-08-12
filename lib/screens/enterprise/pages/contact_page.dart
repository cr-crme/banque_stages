import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/common/models/enterprise.dart';
import '/common/providers/enterprises_provider.dart';

class ContactPage extends StatefulWidget {
  const ContactPage({
    Key? key,
    required this.enterprise,
  }) : super(key: key);

  final Enterprise enterprise;

  @override
  State<ContactPage> createState() => ContactPageState();
}

class ContactPageState extends State<ContactPage> {
  final _formKey = GlobalKey<FormState>();

  String? _contactName;
  String? _contactFunction;
  String? _contactPhone;
  String? _contactEmail;

  String? _address;
  String? _phone;
  String? _fax;
  String? _website;

  String? _headquartersAddress;
  late bool _addressesAreIdentical =
      widget.enterprise.address == widget.enterprise.headquartersAddress;
  String? _neq;

  bool _editing = false;
  bool get editing => _editing;

  void _showInvalidFieldsSnakBar() {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Assurez vous que tous les champs soient valides")));
  }

  void toggleEdit() {
    if (!_editing) {
      setState(() => _editing = true);
      return;
    }

    if (!_formKey.currentState!.validate()) {
      _showInvalidFieldsSnakBar();
      return;
    }

    _formKey.currentState!.save();

    context.read<EnterprisesProvider>().replace(
          widget.enterprise.copyWith(
            contactName: _contactName,
            contactFunction: _contactFunction,
            contactPhone: _contactPhone,
            contactEmail: _contactEmail,
            address: _address,
            phone: _phone,
            fax: _fax,
            website: _website,
            headquartersAddress:
                _addressesAreIdentical ? _address : _headquartersAddress,
            neq: _neq,
          ),
        );

    setState(() {
      _editing = false;
      _addressesAreIdentical = _address == _headquartersAddress;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            ListTile(
              title: Text(
                "Contact en entreprise",
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  TextFormField(
                    controller: TextEditingController(
                        text: widget.enterprise.contactName),
                    decoration: const InputDecoration(labelText: "* Nom"),
                    enabled: _editing,
                    validator: (text) {
                      if (text!.isEmpty) {
                        return "Le champ ne peut pas être vide";
                      }
                      return null;
                    },
                    onSaved: (name) => _contactName = name!,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: TextEditingController(
                        text: widget.enterprise.contactFunction),
                    decoration: const InputDecoration(labelText: "* Fonction"),
                    enabled: _editing,
                    validator: (text) {
                      if (text!.isEmpty) {
                        return "Le champ ne peut pas être vide";
                      }
                      return null;
                    },
                    onSaved: (function) => _contactFunction = function!,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: TextEditingController(
                        text: widget.enterprise.contactPhone),
                    decoration: const InputDecoration(
                      icon: Icon(Icons.phone),
                      labelText: "* Téléphone",
                    ),
                    enabled: _editing,
                    validator: (phone) {
                      if (phone!.isEmpty) {
                        return "Le champ ne peut pas être vide";
                      } else if (!RegExp(
                              r'^[\+]?[(]?[0-9]{3}[)]?[-\s\.]?[0-9]{3}[-\s\.]?[0-9]{4,6}$')
                          .hasMatch(phone)) {
                        return "Le numéro entré n'est pas valide";
                      }
                      return null;
                    },
                    onSaved: (phone) => _contactPhone = phone!,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: TextEditingController(
                        text: widget.enterprise.contactEmail),
                    decoration: const InputDecoration(
                      icon: Icon(Icons.mail),
                      labelText: "* Courriel",
                    ),
                    enabled: _editing,
                    validator: (email) {
                      if (email!.isEmpty) {
                        return "Le champ ne peut pas être vide";
                      } else if (!RegExp(
                              r'^[^@ \t\r\n]+@[^@ \t\r\n]+\.[^@ \t\r\n]+$')
                          .hasMatch(email)) {
                        return "Le courriel entré n'est pas valide";
                      }
                      return null;
                    },
                    onSaved: (email) => _contactEmail = email!,
                  ),
                ],
              ),
            ),
            ListTile(
              title: Text(
                "Informations de l'établissement",
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  TextFormField(
                    controller:
                        TextEditingController(text: widget.enterprise.address),
                    decoration: const InputDecoration(labelText: "Adresse"),
                    enabled: _editing,
                    onSaved: (address) => _address = address,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller:
                        TextEditingController(text: widget.enterprise.phone),
                    decoration: const InputDecoration(labelText: "Téléphone"),
                    enabled: _editing,
                    onSaved: (phone) => _phone = phone,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller:
                        TextEditingController(text: widget.enterprise.fax),
                    decoration: const InputDecoration(labelText: "Télécopieur"),
                    enabled: _editing,
                    onSaved: (fax) => _fax = fax,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller:
                        TextEditingController(text: widget.enterprise.website),
                    decoration: const InputDecoration(labelText: "Site web"),
                    enabled: _editing,
                    onSaved: (website) => _website = website,
                  ),
                ],
              ),
            ),
            ListTile(
              title: Text(
                "Informations pour le crédit d'impôt",
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(children: [
                Visibility(
                  visible: !_addressesAreIdentical,
                  child: TextFormField(
                    controller: TextEditingController(
                        text: widget.enterprise.headquartersAddress),
                    decoration: const InputDecoration(
                        labelText: "Adresse du siège social"),
                    enabled: _editing && !_addressesAreIdentical,
                    onSaved: (address) => _headquartersAddress = address,
                  ),
                ),
                SizedBox(
                  height: 59,
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          "Adresse du siège social identique à l'adresse de l'établissement",
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Switch(
                        value: _addressesAreIdentical,
                        onChanged: (newValue) => setState(() {
                          if (_editing) _addressesAreIdentical = newValue;
                        }),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller:
                      TextEditingController(text: widget.enterprise.neq),
                  decoration: const InputDecoration(labelText: "NEQ"),
                  enabled: _editing,
                  onSaved: (neq) => _neq = neq,
                ),
                const SizedBox(height: 8),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}
