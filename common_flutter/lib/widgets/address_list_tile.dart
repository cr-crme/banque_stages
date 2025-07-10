import 'package:common/models/generic/address.dart';
import 'package:common_flutter/widgets/show_address_dialog.dart';
import 'package:flutter/material.dart';

class AddressController {
  Function()? onAddressChangedCallback;
  AddressController({
    this.onAddressChangedCallback,
    Address? initialValue,
    this.fromStringOverrideForDebug,
    this.confirmAddressForDebug,
  }) {
    this.initialValue = initialValue;
  }

  Future<Address?> Function(String)? fromStringOverrideForDebug;
  bool Function(Address?)? confirmAddressForDebug;

  Future<String?> Function()? _validationFunction;
  bool Function()? _isValidating;
  Address? Function()? _getAddress;
  Address? Function(Address)? _setAddress;
  bool Function()? _isMandatory;
  Address? _initialValue;
  set initialValue(Address? value) {
    _initialValue = value;
    _textController.text = value?.toString() ?? '';
  }

  final TextEditingController _textController = TextEditingController();

  // Interface to expose to the user
  Address? get address => _getAddress == null ? null : _getAddress!();
  set address(Address? value) {
    if (value != null && _setAddress != null) _setAddress!(value);

    _textController.text = address?.toString() ?? '';
    requestValidation();
  }

  Future<String?> requestValidation() async {
    return _validationFunction == null ? null : await _validationFunction!();
  }

  Future<void> waitForValidation() async {
    if (_isValidating == null) return;
    while (_isValidating!()) {
      await Future.delayed(const Duration(milliseconds: 50));
    }
  }

  bool get isValid {
    if (_isValidating == null) return false;

    final address = _getAddress!();
    if (address?.isNotEmpty ?? false) {
      // If the address is filled, then it is valid if it is valid
      return address!.isValid;
    } else {
      // If the address is empty, then it is valid if it is not mandatory
      return !_isMandatory!();
    }
  }

  void dispose() {
    _textController.dispose();
  }
}

class AddressListTile extends StatefulWidget {
  const AddressListTile({
    super.key,
    this.title,
    this.titleStyle,
    this.contentStyle,
    required this.addressController,
    required this.isMandatory,
    required this.enabled,
  });

  final String? title;
  final TextStyle? titleStyle;
  final TextStyle? contentStyle;
  final bool enabled;
  final bool isMandatory;
  final AddressController addressController;

  @override
  State<AddressListTile> createState() => _AddressListTileState();
}

class _AddressListTileState extends State<AddressListTile> {
  bool isValidating = false;
  String? previousValidatedAddress;
  late bool addressHasChanged;

  @override
  void initState() {
    super.initState();

    widget.addressController._validationFunction = validate;
    widget.addressController._isValidating = () => isValidating;
    widget.addressController._getAddress = getAddress;
    widget.addressController._setAddress = setAddress;
    widget.addressController._isMandatory = () => widget.isMandatory;
    _address = widget.addressController._initialValue;

    if (_address == null) {
      // Add the search icon if address is empty
      addressHasChanged = true;
    } else {
      addressHasChanged = false;
    }
  }

  Address? _address;
  Address? getAddress() => _address;
  Address? setAddress(newAddress) => _address = newAddress;

  Future<String?> validate() async {
    if (previousValidatedAddress ==
        widget.addressController._textController.text) {
      return null;
    }
    if (!addressHasChanged) return null;

    _address = null;
    previousValidatedAddress = widget.addressController._textController.text;
    if (widget.addressController._textController.text == '') {
      return widget.isMandatory ? 'Entrer une adresse valide' : null;
    }

    while (isValidating) {
      await Future.delayed(const Duration(milliseconds: 50));
    }

    setState(() => isValidating = true);
    late Address newAddress;
    try {
      final toCall =
          widget.addressController.fromStringOverrideForDebug ??
          Address.fromString;
      newAddress =
          (await toCall(widget.addressController._textController.text))!;
    } catch (e) {
      _address = null;
      setState(() => isValidating = false);
      return 'L\'adresse n\'a pu être trouvée';
    }

    if (newAddress.toString() == _address.toString()) {
      // Don't do anything if the address did not change
      _address = newAddress;
      widget.addressController._textController.text = _address.toString();
      addressHasChanged = false;
      setState(() => isValidating = false);
      return null;
    }

    if (!mounted) {
      // coverage:ignore-start
      setState(() => isValidating = false);
      return 'Erreur inconnue';
      // coverage:ignore-end
    }

    // coverage:ignore-start
    final confirmAddress =
        widget.addressController.confirmAddressForDebug == null
            ? await showDialog<bool>(
              barrierDismissible: false,
              context: context,
              builder:
                  (context) => AlertDialog(
                    title: const Text('Confimer l\'adresse'),
                    content: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('L\'adresse trouvée est\u00a0:\n$newAddress'),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 1 / 2,
                            width: MediaQuery.of(context).size.width * 2 / 3,
                            child: ShowAddressDialog(newAddress),
                          ),
                        ],
                      ),
                    ),
                    actions: [
                      OutlinedButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Annuler'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Confirmer'),
                      ),
                    ],
                  ),
            )
            : widget.addressController.confirmAddressForDebug!(newAddress);
    // coverage:ignore-end

    if (confirmAddress == null || !confirmAddress) {
      _address = null;
      setState(() => isValidating = false);
      return 'Essayer une nouvelle adresse';
    }

    _address = newAddress;

    widget.addressController._textController.text = _address.toString();
    if (widget.addressController.onAddressChangedCallback != null) {
      widget.addressController.onAddressChangedCallback!();
    }

    setState(() => isValidating = false);
    addressHasChanged = false;
    if (!mounted) return null;

    setState(() {});
    return null;
  }

  // coverage:ignore-start
  void _showAddress(context) async {
    if (_address == null) return;

    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(widget.title ?? 'Adresse'),
            content: SingleChildScrollView(
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 1 / 2,
                width: MediaQuery.of(context).size.width * 2 / 3,
                child: ShowAddressDialog(_address!),
              ),
            ),
          ),
    );
  }
  // coverage:ignore-end

  bool _isValid() {
    if (widget.addressController._textController.text == '') {
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
              controller: widget.addressController._textController,
              decoration: InputDecoration(
                labelText:
                    '${widget.isMandatory ? '* ' : ''}${widget.title ?? 'Adresse'}',
                labelStyle: widget.titleStyle ?? TextStyle(color: Colors.black),
                // Add an invisible icon so the text wraps
                suffixIcon: Icon(
                  addressHasChanged ? Icons.search : Icons.map,
                  color: Colors.white,
                ),
                disabledBorder: InputBorder.none,
              ),
              style: widget.contentStyle ?? TextStyle(color: Colors.black),
              enabled: widget.enabled && !isValidating,
              maxLines: null,
              onSaved: (newAddress) => validate(),
              validator:
                  (_) => _isValid() ? null : 'Entrer une adresse valide.',
              keyboardType: TextInputType.streetAddress,
              onChanged:
                  (value) => setState(() {
                    addressHasChanged = true;
                  }),
            ),
            IconButton(
              onPressed:
                  addressHasChanged ? validate : () => _showAddress(context),
              icon: Icon(
                addressHasChanged ? Icons.search : Icons.map,
                color:
                    addressHasChanged
                        ? (widget.addressController._textController.text == ''
                            ? Colors.grey
                            : Theme.of(context).primaryColor)
                        : Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
