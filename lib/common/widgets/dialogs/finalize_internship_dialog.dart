import 'package:flutter/material.dart';

import 'package:crcrme_banque_stages/common/providers/internships_provider.dart';

class FinalizeInternshipDialog extends StatelessWidget {
  const FinalizeInternshipDialog({super.key, required this.internshipId});

  final String internshipId;

  void _saveInternship(context, GlobalKey<FormState> formKey,
      TextEditingController textController) async {
    final internship =
        InternshipsProvider.of(context, listen: false)[internshipId];
    if (!formKey.currentState!.validate()) return;

    final internships = InternshipsProvider.of(context, listen: false);
    internships.replace(internship.copyWith(
        endDate: DateTime.now(),
        achievedLength: int.parse(textController.text)));

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final internship =
        InternshipsProvider.of(context, listen: false)[internshipId];
    final hourController = TextEditingController(
        text: internship.achievedLength < 0
            ? '0'
            : internship.achievedLength.toString());

    return PopScope(
      child: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: AlertDialog(
            title: const Text('Mettre fin au stage?'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                    'Attention, les informations pour ce stage ne seront plus modifiables.\n\n'
                    'Bien vous assurer que le nombre d\'heures réalisées est correct\n'),
                Row(
                  children: [
                    const Flexible(
                      child: Padding(
                        padding: EdgeInsets.only(right: 24.0),
                        child: Text('Nombre d\'heures de stage faites'),
                      ),
                    ),
                    SizedBox(
                      width: 100,
                      child: TextFormField(
                        validator: (value) {
                          return int.tryParse(hourController.text) == null ||
                                  int.parse(hourController.text) == 0
                              ? 'Entrer une valeur'
                              : null;
                        },
                        textAlign: TextAlign.right,
                        controller: hourController,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const Text('h'),
                  ],
                ),
              ],
            ),
            actions: [
              OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Non')),
              TextButton(
                  onPressed: () =>
                      _saveInternship(context, formKey, hourController),
                  child: const Text('Oui')),
            ],
          ),
        ),
      ),
    );
  }
}
