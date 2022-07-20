import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/common/models/enterprise.dart';
import '/common/providers/enterprises_provider.dart';
import '/common/widgets/confirm_pop_dialog.dart';

class EnterpriseContact extends StatefulWidget {
  const EnterpriseContact({Key? key, required this.enterpriseId})
      : super(key: key);

  static const String route = "contact";

  final String enterpriseId;

  @override
  State<EnterpriseContact> createState() => _EnterpriseContactState();
}

class _EnterpriseContactState extends State<EnterpriseContact> {
  final _formKey = GlobalKey<FormState>();

  bool _editable = false;

  String? _contactName;
  String? _contactFunction;
  String? _contactPhone;
  String? _contactEmail;

  String? _address;

  Future<bool> _onWillPop() async {
    if (_editable) {
      return await showDialog(
          context: context, builder: (context) => const ConfirmPopDialog());
    }

    return true;
  }

  void _toggleEdit() {
    if (_editable) {
      if (!_formKey.currentState!.validate()) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Assurez vous que tous les champs soient valides")));

        return;
      }

      _formKey.currentState!.save();
      EnterprisesProvider provider = context.read<EnterprisesProvider>();

      Enterprise enterprise = provider[widget.enterpriseId].copyWith(
        contactName: _contactName!,
        contactFunction: _contactFunction!,
        contactPhone: _contactPhone!,
        contactEmail: _contactEmail!,
        address: _address!,
      );

      provider.replace(enterprise);
    }

    setState(() => _editable = !_editable);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: _onWillPop,
        child: Selector<EnterprisesProvider, Enterprise>(
            builder: (context, enterprise, child) => Scaffold(
                  appBar: AppBar(title: Text(enterprise.name)),
                  body: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      child: Column(children: [
                        const ListTile(
                          title: Text("Personne contact en enterprise"),
                        ),
                        ListTile(
                          title: TextFormField(
                            initialValue: enterprise.contactName,
                            enabled: _editable,
                            decoration:
                                const InputDecoration(labelText: "Nom *"),
                            validator: (text) {
                              if (text!.isEmpty) {
                                return "Le champ ne peut pas être vide";
                              }
                              return null;
                            },
                            onSaved: (name) => _contactName = name!,
                          ),
                        ),
                        ListTile(
                          title: TextFormField(
                            initialValue: enterprise.contactFunction,
                            enabled: _editable,
                            decoration:
                                const InputDecoration(labelText: "Fonction"),
                            onSaved: (function) => _contactFunction = function!,
                          ),
                        ),
                        ListTile(
                          title: TextFormField(
                            initialValue: enterprise.contactPhone,
                            enabled: _editable,
                            decoration: InputDecoration(
                                label: Row(children: const [
                              Icon(Icons.phone),
                              Padding(
                                padding: EdgeInsets.only(left: 8.0),
                                child: Text("Téléphone *"),
                              )
                            ])),
                            validator: (phone) {
                              if (phone!.isEmpty) {
                                return "Le champ ne peut pas être vide";
                              }
                              if (!RegExp(
                                      r'^[\+]?[(]?[0-9]{3}[)]?[-\s\.]?[0-9]{3}[-\s\.]?[0-9]{4,6}$')
                                  .hasMatch(phone)) {
                                return "Le numéro entré doit être valide";
                              }
                              return null;
                            },
                            onSaved: (phone) => _contactPhone = phone!,
                          ),
                        ),
                        ListTile(
                          title: TextFormField(
                            initialValue: enterprise.contactEmail,
                            enabled: _editable,
                            decoration: InputDecoration(
                                label: Row(children: const [
                              Icon(Icons.mail),
                              Padding(
                                padding: EdgeInsets.only(left: 8.0),
                                child: Text("Courriel"),
                              )
                            ])),
                            onSaved: (email) => _contactEmail = email!,
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        const ListTile(
                            title: Text("Addresse de l'établissement")),
                        ListTile(
                          title: TextFormField(
                            initialValue: enterprise.address,
                            enabled: _editable,
                            decoration:
                                const InputDecoration(labelText: "Adresse"),
                            onSaved: (address) => _address = address!,
                          ),
                        )
                      ]),
                    ),
                  ),
                  floatingActionButton: FloatingActionButton(
                    onPressed: _toggleEdit,
                    child: _editable
                        ? const Icon(Icons.save_rounded)
                        : const Icon(Icons.edit),
                  ),
                ),
            selector: (context, enterprises) =>
                enterprises[widget.enterpriseId]));
  }
}
