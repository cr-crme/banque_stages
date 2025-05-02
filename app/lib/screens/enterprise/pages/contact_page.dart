import 'package:common/models/enterprises/enterprise.dart';
import 'package:common/models/generic/address.dart';
import 'package:common/models/generic/phone_number.dart';
import 'package:crcrme_banque_stages/common/providers/enterprises_provider.dart';
import 'package:crcrme_banque_stages/common/widgets/address_list_tile.dart';
import 'package:crcrme_banque_stages/common/widgets/dialogs/confirm_exit_dialog.dart';
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

  late final _contactInfoController =
      _ContactInfoController(enterprise: widget.enterprise);
  late final _enterpriseInfoController = _EnterpriseInfoController(
      enterprise: widget.enterprise,
      onAddressChanged: (address) {
        if (!mounted) return;
        if (_taxesInfoController.useSameAddress) {
          _taxesInfoController.address.address =
              address?.copyWith(id: _taxesInfoController.address.address?.id);
        }
        setState(() {});
      });
  late final _taxesInfoController =
      _TaxesInfoController(enterprise: widget.enterprise);

  bool _editing = false;
  bool get editing => _editing;

  Future<void> toggleEdit({bool save = true}) async {
    if (_editing) {
      if (!save) {
        _editing = false;
        _contactInfoController.reset();
        _enterpriseInfoController.reset();
        _taxesInfoController.reset();
        setState(() {});
        return;
      }
    } else {
      _editing = true;
      setState(() {});
      return;
    }

    // Validate address
    final status = await _enterpriseInfoController.address.requestValidation();
    if (!mounted) return;
    if (status != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(status)));
      return;
    }
    _editing = false;

    if (!_taxesInfoController.useSameAddress) {
      // Validate headquarter address
      final status = await _taxesInfoController.address.requestValidation();
      if (!mounted) return;
      if (status != null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(status)));
        return;
      }
    }

    if (!mounted) return;
    if (!FormService.validateForm(_formKey, save: true)) return;

    EnterprisesProvider.of(context, listen: false).replace(
      widget.enterprise.copyWith(
        contact: widget.enterprise.contact.copyWith(
          firstName: _contactInfoController.firstName.text,
          lastName: _contactInfoController.lastName.text,
          phone: _contactInfoController.contactPhone.text == ''
              ? null
              : PhoneNumber.fromString(_contactInfoController.contactPhone.text,
                  id: widget.enterprise.contact.phone.id),
          email: _contactInfoController.contactEmail.text,
        ),
        contactFunction: _contactInfoController.contactFunction.text == ''
            ? null
            : _contactInfoController.contactFunction.text,
        address: _enterpriseInfoController.address.address,
        phone: _enterpriseInfoController.phone.text == ''
            ? null
            : PhoneNumber.fromString(_enterpriseInfoController.phone.text,
                id: widget.enterprise.phone.id),
        fax: _enterpriseInfoController.fax.text == ''
            ? null
            : PhoneNumber.fromString(_enterpriseInfoController.fax.text,
                id: widget.enterprise.fax.id),
        website: _enterpriseInfoController.website.text == ''
            ? null
            : _enterpriseInfoController.website.text,
        headquartersAddress: _taxesInfoController.useSameAddress
            ? _enterpriseInfoController.address.address
                ?.copyWith(id: _taxesInfoController.address.address?.id)
            : _taxesInfoController.address.address,
        neq: _taxesInfoController.neq.text == ''
            ? null
            : _taxesInfoController.neq.text,
      ),
    );

    setState(() {});
  }

  bool _canPop = false;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _canPop,
      onPopInvokedWithResult: (didPop, result) async {
        if (_canPop) return;

        _canPop = await ConfirmExitDialog.show(context,
            content: Text.rich(TextSpan(children: [
              const TextSpan(
                  text: '** Vous quittez la page sans avoir '
                      'cliqué sur Enregistrer '),
              WidgetSpan(
                  child: SizedBox(
                height: 22,
                width: 22,
                child: Icon(
                  Icons.save,
                  color: Theme.of(context).primaryColor,
                ),
              )),
              const TextSpan(
                text: '. **\n\nToutes vos modifications seront perdues.',
              ),
            ])),
            isEditing: editing);

        // If the user confirms the exit, redo the pop
        if (_canPop && context.mounted) Navigator.of(context).pop();
      },
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _ContactInfo(
                controller: _contactInfoController,
                editMode: _editing,
              ),
              _EnterpriseInfo(
                controller: _enterpriseInfoController,
                editMode: _editing,
              ),
              _TaxesInfo(
                controller: _taxesInfoController,
                editMode: _editing,
                useSameAddress: _taxesInfoController.useSameAddress,
                onChangedUseSame: (newValue) => setState(() {
                  _taxesInfoController.useSameAddress = newValue!;
                  if (_taxesInfoController.useSameAddress) {
                    _taxesInfoController.address.address =
                        _enterpriseInfoController.address.address?.copyWith(
                            id: _taxesInfoController.address.address?.id);
                  } else {
                    _taxesInfoController.address.address = Address.empty;
                  }
                }),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContactInfoController {
  Enterprise enterprise;
  final firstName = TextEditingController();
  final lastName = TextEditingController();
  final contactFunction = TextEditingController();
  final contactPhone = TextEditingController();
  final contactEmail = TextEditingController();

  _ContactInfoController({required this.enterprise}) {
    reset();
  }

  void reset() {
    firstName.text = enterprise.contact.firstName;
    lastName.text = enterprise.contact.lastName;
    contactFunction.text = enterprise.contactFunction;
    contactPhone.text = enterprise.contact.phone.toString();
    contactEmail.text = enterprise.contact.email ?? '';
  }
}

class _ContactInfo extends StatelessWidget {
  const _ContactInfo({
    required this.controller,
    required this.editMode,
  });

  final bool editMode;
  final _ContactInfoController controller;

  @override
  Widget build(BuildContext context) {
    // ThemeData does not work anymore so we have to override the style manually
    const styleOverride = TextStyle(color: Colors.black);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SubTitle('Entreprise représentée par'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              TextFormField(
                controller: controller.firstName,
                decoration: const InputDecoration(
                  labelText: '* Prénom',
                  labelStyle: styleOverride,
                  disabledBorder: InputBorder.none,
                ),
                style: styleOverride,
                enabled: editMode,
                validator: (text) => text!.isEmpty
                    ? 'Ajouter le nom de la personne représentant l\'entreprise.'
                    : null,
                maxLines: null,
              ),
              TextFormField(
                controller: controller.lastName,
                decoration: const InputDecoration(
                  labelText: '* Nom',
                  labelStyle: styleOverride,
                  disabledBorder: InputBorder.none,
                ),
                style: styleOverride,
                enabled: editMode,
                validator: (text) => text!.isEmpty
                    ? 'Ajouter le nom de la personne représentant l\'entreprise.'
                    : null,
                maxLines: null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: controller.contactFunction,
                decoration: const InputDecoration(
                  labelText: '* Fonction',
                  labelStyle: styleOverride,
                  disabledBorder: InputBorder.none,
                ),
                style: styleOverride,
                enabled: editMode,
                validator: (text) => text!.isEmpty
                    ? 'Ajouter la fonction de cette personne.'
                    : null,
              ),
              const SizedBox(height: 8),
              PhoneListTile(
                controller: controller.contactPhone,
                titleStyle: styleOverride,
                contentStyle: styleOverride,
                isMandatory: true,
                enabled: editMode,
              ),
              const SizedBox(height: 8),
              EmailListTile(
                controller: controller.contactEmail,
                titleStyle: styleOverride,
                contentStyle: styleOverride,
                enabled: editMode,
                isMandatory: true,
              ),
            ],
          ),
        )
      ],
    );
  }
}

class _EnterpriseInfoController {
  Enterprise enterprise;
  Function(Address?) onAddressChanged;

  final address = AddressController();
  final phone = TextEditingController();
  final fax = TextEditingController();
  final website = TextEditingController();

  _EnterpriseInfoController(
      {required this.enterprise, required this.onAddressChanged}) {
    reset();
    address.initialValue = enterprise.address;
    address.onAddressChangedCallback = () => onAddressChanged(address.address);
  }

  void reset() {
    address.address = enterprise.address;
    phone.text = enterprise.phone.toString();
    fax.text = enterprise.fax.toString();
    website.text = enterprise.website;
  }
}

class _EnterpriseInfo extends StatelessWidget {
  const _EnterpriseInfo({
    required this.controller,
    required this.editMode,
  });

  final _EnterpriseInfoController controller;
  final bool editMode;

  @override
  Widget build(BuildContext context) {
    // ThemeData does not work anymore so we have to override the style manually
    const styleOverride = TextStyle(color: Colors.black);

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
                titleStyle: styleOverride,
                contentStyle: styleOverride,
                addressController: controller.address,
                isMandatory: true,
                enabled: editMode,
              ),
              const SizedBox(height: 8),
              PhoneListTile(
                  controller: controller.phone,
                  titleStyle: styleOverride,
                  contentStyle: styleOverride,
                  isMandatory: false,
                  enabled: editMode),
              const SizedBox(height: 8),
              PhoneListTile(
                  title: 'Télécopieur',
                  titleStyle: styleOverride,
                  contentStyle: styleOverride,
                  controller: controller.fax,
                  icon: Icons.fax,
                  isMandatory: false,
                  enabled: editMode),
              const SizedBox(height: 8),
              WebSiteListTile(
                controller: controller.website,
                titleStyle: styleOverride,
                contentStyle: styleOverride,
                enabled: editMode,
              ),
            ],
          ),
        )
      ],
    );
  }
}

class _TaxesInfoController {
  Enterprise enterprise;
  bool useSameAddress = false;
  final address = AddressController();
  final neq = TextEditingController();

  _TaxesInfoController({required this.enterprise}) {
    reset();
    address.initialValue = enterprise.headquartersAddress ??
        enterprise.address?.copyWith(id: Address.empty.id);
  }

  void reset() {
    address.address = enterprise.headquartersAddress;
    neq.text = enterprise.neq ?? '';
    useSameAddress = enterprise.address.toString() ==
        enterprise.headquartersAddress.toString();
  }
}

class _TaxesInfo extends StatefulWidget {
  const _TaxesInfo({
    required this.controller,
    required this.editMode,
    required this.useSameAddress,
    required this.onChangedUseSame,
  });

  final _TaxesInfoController controller;
  final bool editMode;
  final bool useSameAddress;
  final Function(bool?) onChangedUseSame;

  @override
  State<_TaxesInfo> createState() => _TaxesInfoState();
}

class _TaxesInfoState extends State<_TaxesInfo> {
  @override
  Widget build(BuildContext context) {
    // ThemeData does not work anymore so we have to override the style manually
    const styleOverride = TextStyle(color: Colors.black);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SubTitle('Informations pour le crédit d\'impôt'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(children: [
            if (widget.editMode)
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Flexible(
                  child: Text(
                    'Adresse du siège social identique à l\'adresse de l\'établissement',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Switch(
                  value: widget.useSameAddress,
                  onChanged: widget.onChangedUseSame,
                )
              ]),
            AddressListTile(
              title: 'Adresse du siège social',
              titleStyle: styleOverride,
              contentStyle: styleOverride,
              addressController: widget.controller.address,
              isMandatory: false,
              enabled: widget.editMode && !widget.useSameAddress,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: widget.controller.neq,
              decoration: const InputDecoration(
                labelText: 'Numéro d\'entreprise du Québec (NEQ)',
                labelStyle: styleOverride,
                disabledBorder: InputBorder.none,
              ),
              style: styleOverride,
              enabled: widget.editMode,
              validator: null,
              keyboardType: TextInputType.number,
            ),
          ]),
        ),
      ],
    );
  }
}
