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
                validator: FormService.textNotEmptyValidator,
                onSaved: (name) => contactName = name!,
              ),
            ),
            ListTile(
              title: TextFormField(
                decoration: const InputDecoration(labelText: "* Fonction"),
                validator: FormService.textNotEmptyValidator,
                onSaved: (function) => contactFunction = function!,
              ),
            ),
            ListTile(
              title: TextFormField(
                decoration: const InputDecoration(
                  icon: Icon(Icons.phone),
                  labelText: "* Téléphone",
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
                  labelText: "* Courriel",
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
