import 'package:flutter/material.dart';

import '/misc/job_data_file_service.dart';
import '../../job_list_risks_and_skills/job_list_screen.dart';

class AutocompleteSearch extends StatelessWidget {
  const AutocompleteSearch({super.key});

  static TextEditingValue textEditingValue = const TextEditingValue();

  @override
  Widget build(BuildContext context) {
    final options = JobDataFileService.specializations;

    return ListTile(
      title: Autocomplete<String>(
        optionsBuilder: (value) {
          if (value.text == '') return const Iterable<String>.empty();
          return options
              .map<String?>((e) =>
                  e.name.toLowerCase().contains(value.text.toLowerCase())
                      ? e.name
                      : null)
              .where((e) => e != null)
              .cast<String>();
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

  goTo(BuildContext context, String choice, List<Specialization> options) {
    final index = options.indexWhere((e) => e.name == choice);
    if (index < 0) {
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
      return;
    }

    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => JobListScreen(id: options[index].id),
    ));
  }
}
