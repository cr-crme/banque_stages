import 'package:flutter/material.dart';

import '/common/models/enterprise.dart';
import '/common/models/phone_number.dart';
import '/common/providers/enterprises_provider.dart';
import '/common/widgets/address_list_tile.dart';
import '/common/widgets/dialogs/confirm_pop_dialog.dart';
import '/common/widgets/phone_list_tile.dart';
import '/common/widgets/sub_title.dart';
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

  final _addressController = AddressController();
  String? _phone;
  String? _fax;
  String? _website;

  late bool _useSameAddress = widget.enterprise.address.toString() ==
      widget.enterprise.headquartersAddress.toString();
  final _headquartersAddressController = AddressController();
  String? _neq;

  bool _editing = false;
  bool get editing => _editing;

  Future<void> toggleEdit() async {
    if (!_editing) {
      _editing = !_editing;
      setState(() {});
      return;
    }

    // Validate address
    final status = await _addressController.requestValidation();
    if (!mounted) return;
    if (status != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(status)));
      return;
    }

    if (!_useSameAddress) {
      // Validate headquarter address
      final status = await _headquartersAddressController.requestValidation();
      if (!mounted) return;
      if (status != null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(status)));
        return;
      }
    }

    if (!mounted) return;
    if (!FormService.validateForm(_formKey, save: true)) return;

    _editing = !_editing;

    EnterprisesProvider.of(context).replace(
      widget.enterprise.copyWith(
        contactName: _contactName,
        contactFunction: _contactFunction,
        contactPhone: _contactPhone == null
            ? null
            : PhoneNumber.fromString(_contactPhone),
        contactEmail: _contactEmail,
        address: _addressController.address,
        phone: _phone == null ? null : PhoneNumber.fromString(_phone),
        fax: _fax == null ? null : PhoneNumber.fromString(_fax),
        website: _website,
        headquartersAddress: _useSameAddress
            ? _addressController.address
            : _headquartersAddressController.address,
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
                addressController: _addressController,
                onSavedPhone: (phone) => _phone = phone,
                onSavedFax: (fax) => _fax = fax,
                onSavedWebsite: (website) => _website = website!,
              ),
              _TaxesInfo(
                enterprise: widget.enterprise,
                editMode: _editing,
                useSameAddress: _useSameAddress,
                onChangedUseSame: (newValue) => setState(() {
                  _useSameAddress = newValue!;
                  if (_useSameAddress) {
                    _headquartersAddressController.address =
                        _addressController.address;
                  }
                }),
                addressController: _headquartersAddressController,
                onSavedNeq: (neq) => _neq = neq,
              ),
              const SizedBox(height: 12),
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SubTitle('Entreprise représentée par'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              TextFormField(
                initialValue: enterprise.contactName,
                decoration: const InputDecoration(
                  labelText: '* Nom',
                  disabledBorder: InputBorder.none,
                ),
                enabled: editMode,
                validator: (text) => text!.isEmpty
                    ? 'Ajouter le nom de la personne représentant l\'entreprise.'
                    : null,
                maxLines: null,
                onSaved: onSavedName,
              ),
              const SizedBox(height: 8),
              TextFormField(
                initialValue: enterprise.contactFunction,
                decoration: const InputDecoration(
                  labelText: '* Fonction',
                  disabledBorder: InputBorder.none,
                ),
                enabled: editMode,
                validator: (text) => text!.isEmpty
                    ? 'Ajouter la fonction de cette personne.'
                    : null,
                onSaved: onSavedJob,
              ),
              const SizedBox(height: 8),
              PhoneListTile(
                initialValue: enterprise.contactPhone,
                onSaved: onSavedPhone,
                isMandatory: true,
                enabled: editMode,
              ),
              const SizedBox(height: 8),
              TextFormField(
                initialValue: enterprise.contactEmail,
                decoration: const InputDecoration(
                  icon: Icon(Icons.mail),
                  labelText: '* Courriel',
                  disabledBorder: InputBorder.none,
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
    required this.addressController,
    required this.onSavedPhone,
    required this.onSavedFax,
    required this.onSavedWebsite,
  });

  final Enterprise enterprise;
  final bool editMode;
  final AddressController addressController;
  final Function(String?) onSavedWebsite;
  final Function(String?) onSavedPhone;
  final Function(String?) onSavedFax;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SubTitle('Informations de l\'établissement'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              AddressListTile(
                title: 'Adresse de l\'établissement',
                addressController: addressController,
                isMandatory: true,
                enabled: editMode,
                initialValue: enterprise.address,
              ),
              const SizedBox(height: 8),
              PhoneListTile(
                  initialValue: enterprise.phone,
                  onSaved: onSavedPhone,
                  isMandatory: false,
                  enabled: editMode),
              const SizedBox(height: 8),
              PhoneListTile(
                  title: 'Télécopieur',
                  initialValue: enterprise.fax,
                  icon: Icons.fax,
                  onSaved: onSavedFax,
                  isMandatory: false,
                  enabled: editMode),
              const SizedBox(height: 8),
              TextFormField(
                initialValue: enterprise.website,
                decoration: const InputDecoration(
                  labelText: 'Site web',
                  disabledBorder: InputBorder.none,
                ),
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
    required this.addressController,
    required this.onSavedNeq,
  });

  final Enterprise enterprise;
  final bool editMode;
  final bool useSameAddress;
  final Function(bool?) onChangedUseSame;
  final AddressController addressController;
  final Function(String?) onSavedNeq;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SubTitle('Informations pour le crédit d\'impôt'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
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
            AddressListTile(
              initialValue: useSameAddress
                  ? enterprise.address
                  : enterprise.headquartersAddress,
              title: 'Adresse du siège social',
              addressController: addressController,
              isMandatory: false,
              enabled: editMode && !useSameAddress,
            ),
            const SizedBox(height: 8),
            TextFormField(
              initialValue: enterprise.neq,
              decoration: const InputDecoration(
                labelText: 'NEQ',
                disabledBorder: InputBorder.none,
              ),
              enabled: editMode,
              validator: null,
              onSaved: onSavedNeq,
              keyboardType: TextInputType.number,
            ),
          ]),
        ),
      ],
    );
  }
}
