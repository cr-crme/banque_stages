import 'package:flutter/material.dart';

import '/common/models/address.dart';
import '/screens/enterprise/pages/widgets/show_school.dart';

class AddressController {
  late Future<String?> Function() _validationFunction;
  Future<String?> requestionValidation() async {
    return _validationFunction();
  }
}

class AddressListTile extends StatefulWidget {
  const AddressListTile({
    super.key,
    required this.isMandatory,
    required this.enabled,
    this.addressController,
  });

  final bool enabled;
  final bool isMandatory;
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
    }
  }

  Address? address;

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
      address = null;
      isValidating = false;
      return 'L\'adresse n\'a pu être trouvée';
    }

    if (newAddress.toString() == address.toString()) {
      // Don't don anything if the address did not change
      address = newAddress;
      _textController.text = address.toString();
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
                    child: ShowSchoolAddress(newAddress),
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
      address = null;
      isValidating = false;
      return 'Essayer une nouvelle adresse';
    }

    address = newAddress;
    _textController.text = address.toString();
    isValidating = false;
    setState(() {});
    return null;
  }

  bool _isValid() {
    if (_textController.text == '') {
      return !widget.isMandatory;
    }

    return address != null;
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (hasFocus) {
        if (!hasFocus) {
          validate();
        }
      },
      child: ListTile(
        title: TextFormField(
          controller: _textController,
          decoration:
              const InputDecoration(labelText: '* Adresse de l\'établissement'),
          maxLines: null,
          onSaved: (newAddress) => validate(),
          validator: (_) => _isValid() ? null : 'Entrer une adresse valide',
          keyboardType: TextInputType.streetAddress,
        ),
      ),
    );
  }
}
