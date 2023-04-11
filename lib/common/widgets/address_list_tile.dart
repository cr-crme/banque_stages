import 'package:flutter/material.dart';

import '/common/models/address.dart';
import '/screens/enterprise/pages/widgets/show_address_dialog.dart';

class AddressController {
  late Future<String?> Function() _validationFunction;
  late Address? Function() _address;

  // Interface to expose to the user
  Address? get address => _address();
  Future<String?> requestValidation() async {
    return _validationFunction();
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
  final _textController = TextEditingController();
  bool isValidating = false;

  @override
  void initState() {
    super.initState();

    if (widget.addressController != null) {
      widget.addressController!._validationFunction = validate;
      widget.addressController!._address = getAddress;
    }

    if (widget.initialValue != null) {
      _address = widget.initialValue;
      _textController.text = _address.toString();
    }
  }

  Address? _address;
  Address? getAddress() => _address;

  Future<String?> validate() async {
    if (_textController.text == '') {
      return widget.isMandatory ? 'Entrer une adresse valide' : null;
    }

    while (isValidating) {
      await Future.delayed(const Duration(milliseconds: 250));
    }

    isValidating = true;
    late Address newAddress;
    try {
      newAddress = (await Address.fromAddress(_textController.text))!;
    } catch (e) {
      _address = null;
      isValidating = false;
      return 'L\'adresse n\'a pu être trouvée';
    }

    if (newAddress.toString() == _address.toString()) {
      // Don't don anything if the address did not change
      _address = newAddress;
      _textController.text = _address.toString();
      isValidating = false;
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
                  Text('L\'adresse trouvée est :\n$newAddress'),
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
    _textController.text = _address.toString();
    isValidating = false;
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
    if (_textController.text == '') {
      return !widget.isMandatory;
    }

    return _address != null;
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (hasFocus) {
        if (!hasFocus) {
          validate();
        }
      },
      child: Stack(
        alignment: Alignment.centerRight,
        children: [
          TextFormField(
            controller: _textController,
            decoration: InputDecoration(
                labelText:
                    '${widget.isMandatory ? '* ' : ''}${widget.title ?? 'Adresse'}',
                // Add an invisible icon so the text wraps
                suffixIcon: const Icon(Icons.map, color: Colors.white),
                disabledBorder: InputBorder.none),
            enabled: widget.enabled,
            maxLines: null,
            onSaved: (newAddress) => validate(),
            validator: (_) => _isValid() ? null : 'Entrer une adresse valide',
            keyboardType: TextInputType.streetAddress,
          ),
          IconButton(
            onPressed: _address != null ? () => _showAddress(context) : null,
            icon: Icon(Icons.map,
                color: _address != null ? Colors.purple : Colors.grey),
          )
        ],
      ),
    );
  }
}
