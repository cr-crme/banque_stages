import 'package:flutter/material.dart';

import 'package:crcrme_banque_stages/common/models/address.dart';
import 'package:crcrme_banque_stages/screens/enterprise/pages/widgets/show_address_dialog.dart';

class AddressController {
  Function()? onAddressChangedCallback;
  AddressController({this.onAddressChangedCallback});

  Future<String?> Function()? _validationFunction;
  Address? Function()? _getAddress;
  Address? Function(Address)? _setAddress;
  Address? initialValue;
  final TextEditingController _textController = TextEditingController();

  // Interface to expose to the user
  Address? get address => _getAddress == null ? null : _getAddress!();
  set address(Address? value) {
    if (value != null && _setAddress != null) _setAddress!(value);

    _textController.text = address?.toString() ?? '';
    if (_validationFunction != null) _validationFunction!();
  }

  Future<String?> requestValidation() async {
    return _validationFunction == null ? null : _validationFunction!();
  }
}

class AddressListTile extends StatefulWidget {
  const AddressListTile({
    super.key,
    this.title,
    this.initialValue,
    required this.isMandatory,
    required this.enabled,
    this.addressController,
  });

  final String? title;
  final bool enabled;
  final bool isMandatory;
  final Address? initialValue;
  final AddressController? addressController;

  @override
  State<AddressListTile> createState() => _AddressListTileState();
}

class _AddressListTileState extends State<AddressListTile> {
  bool isValidating = false;
  late bool addressHasChanged = widget.initialValue == null;

  @override
  void initState() {
    super.initState();

    if (widget.addressController != null) {
      widget.addressController!._validationFunction = validate;
      widget.addressController!._getAddress = getAddress;
      widget.addressController!._setAddress = setAddress;
    }

    if (widget.addressController!.initialValue != null &&
        widget.initialValue != null) {
      throw 'Initial values for the address controller can only be set via one '
          'of the methods';
    } else if (widget.addressController!.initialValue != null) {
      _address = widget.addressController!.initialValue;
    } else if (widget.initialValue != null) {
      _address = widget.initialValue;
    }

    if (_address != null) {
      widget.addressController!._textController.text = _address.toString();
    }
  }

  Address? _address;
  Address? getAddress() => _address;
  Address? setAddress(newAddress) => _address = newAddress;

  Future<String?> validate() async {
    if (!addressHasChanged) return null;

    if (widget.addressController!._textController.text == '') {
      return widget.isMandatory ? 'Entrer une adresse valide' : null;
    }

    while (isValidating) {
      await Future.delayed(const Duration(milliseconds: 250));
    }

    isValidating = true;
    late Address newAddress;
    try {
      newAddress = (await Address.fromAddress(
          widget.addressController!._textController.text))!;
    } catch (e) {
      _address = null;
      isValidating = false;
      return 'L\'adresse n\'a pu être trouvée';
    }

    if (newAddress.toString() == _address.toString()) {
      // Don't do anything if the address did not change
      _address = newAddress;
      widget.addressController!._textController.text = _address.toString();
      isValidating = false;
      addressHasChanged = false;
      setState(() {});
      return null;
    }

    if (!mounted) {
      isValidating = false;
      return 'Erreur inconnue';
    }

    final confirmAddress = await showDialog<bool>(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: const Text('Confimer l\'adresse'),
              content: SingleChildScrollView(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Text('L\'adresse trouvée est\u00a0:\n$newAddress'),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 1 / 2,
                    width: MediaQuery.of(context).size.width * 2 / 3,
                    child: ShowAddressDialog(newAddress),
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
      _address = null;
      isValidating = false;
      return 'Essayer une nouvelle adresse';
    }

    _address = newAddress;

    widget.addressController!._textController.text = _address.toString();
    if (widget.addressController!.onAddressChangedCallback != null) {
      widget.addressController!.onAddressChangedCallback!();
    }

    isValidating = false;
    addressHasChanged = false;
    if (!mounted) return null;

    setState(() {});
    return null;
  }

  void _showAddress(context) async {
    if (_address == null) return;

    await showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: Text(widget.title ?? 'Adresse'),
              content: SingleChildScrollView(
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 1 / 2,
                  width: MediaQuery.of(context).size.width * 2 / 3,
                  child: ShowAddressDialog(_address!),
                ),
              ),
            ));
  }

  bool _isValid() {
    if (widget.addressController!._textController.text == '') {
      return !widget.isMandatory;
    }

    return _address != null;
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (hasFocus) {
        if (!hasFocus) validate();
      },
      child: InkWell(
        onTap: widget.enabled ? null : () => _showAddress(context),
        child: Stack(
          alignment: Alignment.centerRight,
          children: [
            TextFormField(
              controller: widget.addressController!._textController,
              decoration: InputDecoration(
                  labelText:
                      '${widget.isMandatory ? '* ' : ''}${widget.title ?? 'Adresse'}',
                  // Add an invisible icon so the text wraps
                  suffixIcon: Icon(addressHasChanged ? Icons.search : Icons.map,
                      color: Colors.white),
                  disabledBorder: InputBorder.none),
              enabled: widget.enabled,
              maxLines: null,
              onSaved: (newAddress) => validate(),
              validator: (_) =>
                  _isValid() ? null : 'Entrer une adresse valide.',
              keyboardType: TextInputType.streetAddress,
              onChanged: (value) => setState(() {
                addressHasChanged = true;
              }),
            ),
            IconButton(
              onPressed:
                  addressHasChanged ? validate : () => _showAddress(context),
              icon: Icon(addressHasChanged ? Icons.search : Icons.map,
                  color: addressHasChanged
                      ? (widget.addressController!._textController.text == ''
                          ? Colors.grey
                          : Theme.of(context).primaryColor)
                      : Theme.of(context).primaryColor),
            )
          ],
        ),
      ),
    );
  }
}
