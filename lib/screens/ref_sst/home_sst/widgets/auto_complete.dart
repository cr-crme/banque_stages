import 'dart:developer';

import 'package:flutter/material.dart';

import '../../job_list_risks_and_skills/job_list_screen.dart';

class AutocompleteSearch extends StatelessWidget {
  const AutocompleteSearch({super.key});

  static List<String> options = filledList();

  static TextEditingValue textEditingValue = const TextEditingValue();

  @override
  Widget build(BuildContext context) {
    //TextEditingValue textEditingValue = TextEditingValue();
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
        onSelected: (String option) {
          debugPrint('You just selected $option');
          goTo(context, option);
        },
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
            goTo(context, textEditingValue.text);
          }),
    );
  }

  goTo(BuildContext context, String job) {
    bool valueInList = false;

    for (String val in options) {
      log("in list val : $val");

      if (job == val) {
        log("value trouver");
        valueInList = true;
      }
      log(job);
    }
    if (valueInList) {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => JobListScreen(id: job),
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

  static List<String> filledList() {
    List<String> list = [];
    for (int i = 0; i < 50; i++) {
      list.add("job $i");
    }
    return list;
  }
}
