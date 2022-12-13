import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '/common/models/student.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({
    super.key,
    required this.student,
  });

  final Student student;

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  bool _editing = false;

  String? _name;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          ListTile(
            title: Text(
              AppLocalizations.of(context)!.generalInformations,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 140,
                      height: 105,
                      color: Theme.of(context).disabledColor,
                      child: widget.student.photo.isNotEmpty
                          ? Image.network(widget.student.photo)
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextFormField(
                            controller: TextEditingController(
                                text: widget.student.name),
                            decoration: InputDecoration(
                              labelText:
                                  AppLocalizations.of(context)!.student_name,
                            ),
                            enabled: _editing,
                            onSaved: (name) => _name = name,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            AppLocalizations.of(context)!.dateBirth,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          Text(
                            widget.student.dateBirth.toString(),
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text(
                          AppLocalizations.of(context)!.student_program,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        Text(
                          widget.student.program,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Text(
                          AppLocalizations.of(context)!.student_group,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        Text(
                          widget.student.group,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          ListTile(
            title: Text(
              AppLocalizations.of(context)!.generalInformations,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
        ],
      ),
    );
  }
}
