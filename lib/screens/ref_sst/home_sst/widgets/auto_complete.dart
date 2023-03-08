import 'package:crcrme_banque_stages/misc/job_data_file_service.dart';
import 'package:flutter/material.dart';

import '../../job_list_risks_and_skills/job_list_screen.dart';

class AutocompleteSearch extends StatelessWidget {
  const AutocompleteSearch({super.key});

  static TextEditingValue textEditingValue = const TextEditingValue();

  @override
  Widget build(BuildContext context) {
    final options = filledList(context);

    return ListTile(
      title: Autocomplete<String>(
        optionsBuilder: (value) {
          if (value.text == '') {
            textEditingValue = value;
            return const Iterable<String>.empty();
          }
          return options.where((String option) {
            textEditingValue = value;

            return option.toString().contains(value.text.toLowerCase());
          });
        },
        onSelected: (choice) => goTo(context, choice, options),
        optionsViewBuilder: (context, onSelected, options) {
          return Align(
            alignment: Alignment.topLeft,
            child: Material(
              child: SizedBox(
                width: 275,
                height: 200,
                child: ListView.builder(
                    scrollDirection: Axis.vertical,
                    padding: const EdgeInsets.all(10.0),
                    itemCount: options.length,
                    itemBuilder: (BuildContext ctx, int index) {
                      final String option = options.elementAt(index);

                      return GestureDetector(
                        onTap: () => onSelected(option),
                        child: ListTile(
                          title: Text(option),
                        ),
                      );
                    }),
              ),
            ),
          );
        },
      ),
      trailing: IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {
            goTo(context, textEditingValue.text, options);
          }),
    );
  }

  goTo(BuildContext context, String choice, List<String> options) {
    if (options.contains(choice)) {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => JobListScreen(id: choice),
      ));
    } else {
      showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Erreur'),
          content: const Text('Le métier saisie n\'est pas disponible'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, 'OK'),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  List<String> filledList(BuildContext context) {
    List<Specialization> out = [];
    for (final sector in JobDataFileService.sectors) {
      for (final specialization in sector.specializations) {
        // If there is no risk, it does not mean this specialization
        // is risk-free, it means it was not evaluated
        var hasRisks = false;
        for (final skill in specialization.skills) {
          if (hasRisks) break;
          hasRisks = skill.risks.isNotEmpty;
        }
        if (hasRisks) out.add(specialization);
      }
    }
    return out.map<String>((e) => e.name).toList();
  }
}
