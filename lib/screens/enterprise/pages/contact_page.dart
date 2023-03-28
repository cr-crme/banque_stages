import 'package:flutter/material.dart';

import '/common/models/address.dart';
import '/common/models/enterprise.dart';
import '/common/providers/enterprises_provider.dart';
import '/common/widgets/dialogs/confirm_pop_dialog.dart';
import '/misc/form_service.dart';
import 'widgets/show_school.dart';
import 'widgets/sub_title.dart';

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

  late bool _useSameAddress = widget.enterprise.address.toString() ==
      widget.enterprise.headquartersAddress.toString();
  String? _headquartersAddress;
  String? _neq;

  bool _editing = false;
  bool get editing => _editing;

  void toggleEdit() async {
    _editing = !_editing;

    if (!FormService.validateForm(_formKey, save: true)) {
      return;
    }

    EnterprisesProvider.of(context).replace(
      widget.enterprise.copyWith(
        contactName: _contactName,
        contactFunction: _contactFunction,
        contactPhone: _contactPhone,
        contactEmail: _contactEmail,
        address: await Address.fromAddress(_address!),
        phone: _phone,
        fax: _fax,
        website: _website,
        headquartersAddress: await Address.fromAddress(
            _useSameAddress ? _address! : _headquartersAddress!),
        neq: _neq,
      ),
    );

    setState(() {});
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
              _ContactInfo(
                enterprise: widget.enterprise,
                editMode: _editing,
                onSavedName: (name) => _contactName = name!,
                onSavedJob: (function) => _contactFunction = function!,
                onSavedPhone: (phone) => _contactPhone = phone!,
                onSavedEmail: (email) => _contactEmail = email!,
              ),
              _EnterpriseInfo(
                enterprise: widget.enterprise,
                editMode: _editing,
                onSavedAddress: (address) => _address = address!,
                onSavedPhone: (phone) => _phone = phone!,
                onSavedWebsite: (website) => _website = website!,
              ),
              _TaxesInfo(
                enterprise: widget.enterprise,
                editMode: _editing,
                useSameAddress: _useSameAddress,
                onChangedUseSame: (newValue) => setState(() {
                  _useSameAddress = newValue!;
                }),
                onSavedAddress: (address) => _headquartersAddress =
                    !_useSameAddress && address != null ? address : _address,
                onSavedNeq: (neq) => _neq = neq,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContactInfo extends StatelessWidget {
  const _ContactInfo({
    required this.enterprise,
    required this.editMode,
    required this.onSavedName,
    required this.onSavedJob,
    required this.onSavedPhone,
    required this.onSavedEmail,
  });

  final Enterprise enterprise;
  final bool editMode;
  final Function(String?) onSavedName;
  final Function(String?) onSavedJob;
  final Function(String?) onSavedPhone;
  final Function(String?) onSavedEmail;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SubTitle('Entreprise représentée par'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              TextFormField(
                initialValue: enterprise.contactName,
                decoration: const InputDecoration(labelText: '* Nom'),
                enabled: editMode,
                validator: FormService.textNotEmptyValidator,
                maxLines: null,
                onSaved: onSavedName,
              ),
              const SizedBox(height: 8),
              TextFormField(
                initialValue: enterprise.contactFunction,
                decoration: const InputDecoration(labelText: '* Fonction'),
                enabled: editMode,
                validator: FormService.textNotEmptyValidator,
                onSaved: onSavedJob,
              ),
              const SizedBox(height: 8),
              TextFormField(
                initialValue: enterprise.contactPhone,
                decoration: const InputDecoration(
                  icon: Icon(Icons.phone),
                  labelText: '* Téléphone',
                ),
                enabled: editMode,
                validator: FormService.phoneValidator,
                onSaved: onSavedPhone,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 8),
              TextFormField(
                initialValue: enterprise.contactEmail,
                decoration: const InputDecoration(
                  icon: Icon(Icons.mail),
                  labelText: '* Courriel',
                ),
                enabled: editMode,
                validator: FormService.emailValidator,
                onSaved: onSavedEmail,
                keyboardType: TextInputType.emailAddress,
              ),
            ],
          ),
        )
      ],
    );
  }
}

class _EnterpriseInfo extends StatelessWidget {
  const _EnterpriseInfo({
    required this.enterprise,
    required this.editMode,
    required this.onSavedAddress,
    required this.onSavedPhone,
    required this.onSavedWebsite,
  });

  final Enterprise enterprise;
  final bool editMode;
  final Function(String?) onSavedAddress;
  final Function(String?) onSavedWebsite;
  final Function(String?) onSavedPhone;

  void _showAddress(context) async {
    await showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: const Text('Adresse de l\'établissement'),
              content: SingleChildScrollView(
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 1 / 2,
                  width: MediaQuery.of(context).size.width * 2 / 3,
                  child: ShowSchoolAddress(enterprise.address!),
                ),
              ),
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SubTitle('Informations de l\'établissement'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              Stack(
                alignment: Alignment.centerRight,
                children: [
                  TextFormField(
                    initialValue: enterprise.address.toString(),
                    decoration: const InputDecoration(
                        labelText: '* Adresse',
                        suffixIcon: Icon(Icons.map, color: Colors.purple)),
                    enabled: editMode,
                    onSaved: onSavedAddress,
                    maxLines: null,
                    keyboardType: TextInputType.streetAddress,
                  ),
                  IconButton(
                    onPressed: () => _showAddress(context),
                    icon: const Icon(Icons.map, color: Colors.purple),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextFormField(
                initialValue: enterprise.phone,
                decoration: const InputDecoration(labelText: 'Téléphone'),
                enabled: editMode,
                onSaved: onSavedPhone,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 8),
              TextFormField(
                initialValue: enterprise.website,
                decoration: const InputDecoration(labelText: 'Site web'),
                enabled: editMode,
                onSaved: onSavedWebsite,
                keyboardType: TextInputType.url,
              ),
            ],
          ),
        )
      ],
    );
  }
}

class _TaxesInfo extends StatelessWidget {
  const _TaxesInfo({
    required this.enterprise,
    required this.editMode,
    required this.useSameAddress,
    required this.onChangedUseSame,
    required this.onSavedAddress,
    required this.onSavedNeq,
  });

  final Enterprise enterprise;
  final bool editMode;
  final bool useSameAddress;
  final Function(bool?) onChangedUseSame;
  final Function(String?) onSavedAddress;
  final Function(String?) onSavedNeq;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SubTitle('Informations pour le crédit d\'impôt'),
        Padding(
          padding: const EdgeInsets.only(left: 30.0, right: 10),
          child: Column(children: [
            if (editMode)
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Flexible(
                  child: Text(
                    'Adresse du siège social identique à l\'adresse de l\'établissement',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Switch(
                  value: useSameAddress,
                  onChanged: onChangedUseSame,
                )
              ]),
            if (!editMode || !useSameAddress)
              TextFormField(
                initialValue: enterprise.headquartersAddress.toString(),
                decoration:
                    const InputDecoration(labelText: 'Adresse du siège social'),
                maxLines: null,
                enabled: editMode,
                onSaved: (value) => onSavedAddress(value),
                keyboardType: TextInputType.streetAddress,
              ),
            const SizedBox(height: 8),
            TextFormField(
              initialValue: enterprise.neq,
              decoration: const InputDecoration(labelText: 'NEQ'),
              enabled: editMode,
              validator: FormService.neqValidator,
              onSaved: onSavedNeq,
              keyboardType: TextInputType.number,
            ),
          ]),
        ),
      ],
    );
  }
}
