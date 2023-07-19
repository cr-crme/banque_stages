import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class WebSiteListTile extends StatefulWidget {
  const WebSiteListTile({
    super.key,
    this.title = 'Site web',
    this.initialValue,
    this.icon = Icons.link,
    this.onSaved,
    this.isMandatory = false,
    this.enabled = true,
    this.canVisit = true,
    this.controller,
  });

  final String title;
  final String? initialValue;
  final IconData icon;
  final Function(String?)? onSaved;
  final bool isMandatory;
  final bool enabled;
  final TextEditingController? controller;
  final bool canVisit;

  @override
  State<WebSiteListTile> createState() => _WebSiteListTileState();
}

class _WebSiteListTileState extends State<WebSiteListTile> {
  late final _websiteController = widget.controller ?? TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialValue != null) {
      _websiteController.text = widget.initialValue.toString();
    }
  }

  _visit() async => await launchUrl(Uri.parse(_websiteController.text));

  void _addHttp(String value) {
    if (widget.onSaved == null || _websiteController.text == '') return;

    if (!value.startsWith('http:') && !value.startsWith('https:')) {
      _websiteController.text = 'https://$value';
    }
    widget.onSaved!(_websiteController.text);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.enabled || _websiteController.text == '' ? null : _visit,
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          TextFormField(
            controller: _websiteController,
            decoration: InputDecoration(
              icon: const SizedBox(width: 30),
              labelText: '${widget.isMandatory ? '* ' : ''}${widget.title}',
              disabledBorder: InputBorder.none,
            ),
            enabled: widget.enabled,
            onSaved: (value) => _addHttp(value!),
            keyboardType: TextInputType.url,
          ),
          InkWell(
            onTap: widget.canVisit ? _visit : null,
            borderRadius: BorderRadius.circular(25),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                widget.icon,
                color: widget.canVisit
                    ? Theme.of(context).primaryColor
                    : Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
