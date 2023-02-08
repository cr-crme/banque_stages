import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/common/models/enterprise.dart';
import '/common/providers/enterprises_provider.dart';
import '/common/widgets/dialogs/confirm_pop_dialog.dart';
import '/misc/form_service.dart';

class ContactPage extends StatefulWidget {
  const ContactPage({
    super.key,
    required this.enterprise,
  });

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

  void toggleEdit() {
    if (!_editing) {
      setState(() => _editing = true);
      return;
    }

    if (!FormService.validateForm(_formKey, save: true)) {
      return;
    }

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
    return WillPopScope(
      onWillPop: () => ConfirmPopDialog.show(context, editing: editing),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              ListTile(
                title: Text(
                  "Entreprise représentée par",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    TextFormField(
                      initialValue: widget.enterprise.contactName,
                      decoration: const InputDecoration(labelText: "* Nom"),
                      enabled: _editing,
                      validator: FormService.textNotEmptyValidator,
                      onSaved: (name) => _contactName = name!,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      initialValue: widget.enterprise.contactFunction,
                      decoration:
                          const InputDecoration(labelText: "* Fonction"),
                      enabled: _editing,
                      validator: FormService.textNotEmptyValidator,
                      onSaved: (function) => _contactFunction = function!,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      initialValue: widget.enterprise.contactPhone,
                      decoration: const InputDecoration(
                        icon: Icon(Icons.phone),
                        labelText: "* Téléphone",
                      ),
                      enabled: _editing,
                      validator: FormService.phoneValidator,
                      onSaved: (phone) => _contactPhone = phone!,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      initialValue: widget.enterprise.contactEmail,
                      decoration: const InputDecoration(
                        icon: Icon(Icons.mail),
                        labelText: "* Courriel",
                      ),
                      enabled: _editing,
                      validator: FormService.emailValidator,
                      onSaved: (email) => _contactEmail = email!,
                      keyboardType: TextInputType.emailAddress,
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
                      initialValue: widget.enterprise.address,
                      decoration: const InputDecoration(labelText: "Adresse"),
                      enabled: _editing,
                      onSaved: (address) => _address = address,
                      keyboardType: TextInputType.streetAddress,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      initialValue: widget.enterprise.phone,
                      decoration: const InputDecoration(labelText: "Téléphone"),
                      enabled: _editing,
                      onSaved: (phone) => _phone = phone,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      initialValue: widget.enterprise.fax,
                      decoration:
                          const InputDecoration(labelText: "Télécopieur"),
                      enabled: _editing,
                      onSaved: (fax) => _fax = fax,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      initialValue: widget.enterprise.website,
                      decoration: const InputDecoration(labelText: "Site web"),
                      enabled: _editing,
                      onSaved: (website) => _website = website,
                      keyboardType: TextInputType.url,
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
                      initialValue: widget.enterprise.headquartersAddress,
                      decoration: const InputDecoration(
                          labelText: "Adresse du siège social"),
                      enabled: _editing && !_addressesAreIdentical,
                      onSaved: (address) => _headquartersAddress = address,
                      keyboardType: TextInputType.streetAddress,
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
                    initialValue: widget.enterprise.neq,
                    decoration: const InputDecoration(labelText: "NEQ"),
                    enabled: _editing,
                    validator: FormService.neqValidator,
                    onSaved: (neq) => _neq = neq,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 8),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
