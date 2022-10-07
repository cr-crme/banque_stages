import 'package:flutter/material.dart';

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

  bool validate() {
    return _formKey.currentState!.validate();
  }

  void save() {
    _formKey.currentState!.save();
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
              title: Text("Personne contact en entreprise"),
            ),
            ListTile(
              title: TextFormField(
                decoration: const InputDecoration(labelText: "* Nom"),
                validator: (text) {
                  if (text!.isEmpty) {
                    return "Le champ ne peut pas être vide";
                  }
                  return null;
                },
                onSaved: (name) => contactName = name!,
              ),
            ),
            ListTile(
              title: TextFormField(
                decoration: const InputDecoration(labelText: "* Fonction"),
                validator: (text) {
                  if (text!.isEmpty) {
                    return "Le champ ne peut pas être vide";
                  }
                  return null;
                },
                onSaved: (function) => contactFunction = function!,
              ),
            ),
            ListTile(
              title: TextFormField(
                decoration: const InputDecoration(
                  icon: Icon(Icons.phone),
                  labelText: "* Téléphone",
                ),
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
                onSaved: (phone) => contactPhone = phone!,
                keyboardType: TextInputType.phone,
              ),
            ),
            ListTile(
              title: TextFormField(
                decoration: const InputDecoration(
                  icon: Icon(Icons.mail),
                  labelText: "* Courriel",
                ),
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
              title: Text("Adresse de l'établissement"),
            ),
            // TODO: Implement Google Maps (?) autocomplete
            ListTile(
              title: TextFormField(
                decoration: const InputDecoration(labelText: "Adresse"),
                onSaved: (address) => this.address = address!,
                keyboardType: TextInputType.streetAddress,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
