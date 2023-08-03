import 'package:crcrme_banque_stages/common/models/address.dart';
import 'package:crcrme_banque_stages/common/models/enterprise.dart';
import 'package:crcrme_banque_stages/common/models/phone_number.dart';
import 'package:crcrme_banque_stages/common/providers/enterprises_provider.dart';
import 'package:crcrme_banque_stages/common/widgets/address_list_tile.dart';
import 'package:crcrme_banque_stages/common/widgets/dialogs/confirm_pop_dialog.dart';
import 'package:crcrme_banque_stages/common/widgets/email_list_tile.dart';
import 'package:crcrme_banque_stages/common/widgets/phone_list_tile.dart';
import 'package:crcrme_banque_stages/common/widgets/sub_title.dart';
import 'package:crcrme_banque_stages/common/widgets/web_site_list_tile.dart';
import 'package:crcrme_banque_stages/misc/form_service.dart';
import 'package:flutter/material.dart';

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

  String? _contactFirstName;
  String? _contactLastName;
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

  Future<void> toggleEdit({bool save = true}) async {
    if (_editing) {
      _editing = false;
      if (!save) {
        setState(() {});
        return;
      }
    } else {
      _editing = true;
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
        contact: widget.enterprise.contact.copyWith(
          firstName: _contactFirstName,
          lastName: _contactLastName,
          phone: _contactPhone == null
              ? null
              : PhoneNumber.fromString(_contactPhone),
          email: _contactEmail,
        ),
        contactFunction: _contactFunction,
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
      onWillPop: () => ConfirmExitDialog.show(context,
          message:
              'Enregistrer vos modifications en cliquant sur la disquette, '
              'sinon, elles seront perdues.',
          isEditing: editing),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _ContactInfo(
                enterprise: widget.enterprise,
                editMode: _editing,
                onSavedFirstName: (name) => _contactFirstName = name!,
                onSavedLastName: (name) => _contactLastName = name!,
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
                  } else {
                    _headquartersAddressController.address = Address();
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
    required this.onSavedFirstName,
    required this.onSavedLastName,
    required this.onSavedJob,
    required this.onSavedPhone,
    required this.onSavedEmail,
  });

  final Enterprise enterprise;
  final bool editMode;
  final Function(String?) onSavedFirstName;
  final Function(String?) onSavedLastName;
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
                initialValue: enterprise.contact.firstName,
                decoration: const InputDecoration(
                  labelText: '* Prénom',
                  disabledBorder: InputBorder.none,
                ),
                enabled: editMode,
                validator: (text) => text!.isEmpty
                    ? 'Ajouter le nom de la personne représentant l\'entreprise.'
                    : null,
                maxLines: null,
                onSaved: onSavedFirstName,
              ),
              TextFormField(
                initialValue: enterprise.contact.lastName,
                decoration: const InputDecoration(
                  labelText: '* Nom',
                  disabledBorder: InputBorder.none,
                ),
                enabled: editMode,
                validator: (text) => text!.isEmpty
                    ? 'Ajouter le nom de la personne représentant l\'entreprise.'
                    : null,
                maxLines: null,
                onSaved: onSavedLastName,
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
                initialValue: enterprise.contact.phone,
                onSaved: onSavedPhone,
                isMandatory: true,
                enabled: editMode,
              ),
              const SizedBox(height: 8),
              EmailListTile(
                initialValue: enterprise.contact.email,
                enabled: editMode,
                onSaved: onSavedEmail,
                isMandatory: true,
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
        const SubTitle('Coordonnées de l\'établissement'),
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
              WebSiteListTile(
                initialValue: enterprise.website,
                enabled: editMode,
                onSaved: onSavedWebsite,
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
                labelText: 'Numéro d\'entreprise du Québec (NEQ)',
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
