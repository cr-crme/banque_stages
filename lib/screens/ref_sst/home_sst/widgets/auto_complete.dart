import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/number_symbols_data.dart';

import '../../job_list_risks_and_skills/job_list_screen.dart';

class AutocompleteSearch extends StatelessWidget {
  const AutocompleteSearch({super.key});

  static List<String> Options = filledList();

  static TextEditingValue textEditingValue = TextEditingValue();


  @override
  Widget build(BuildContext context) {
    //TextEditingValue textEditingValue = TextEditingValue();
    return ListTile(
      title: Autocomplete<String>(optionsBuilder: (value) {
        if (value.text == '') {
          textEditingValue = value;
          return const Iterable<String>.empty();
        }
        return Options.where((String option) {
          textEditingValue = value;

          return option
              .toString()
              .contains(value.text.toLowerCase());
        });
      },

      onSelected: (String Option) {
        print('You just selected $Option');
        GoTo(context, Option);
      },

      optionsViewBuilder: (context, onSelected, options) {
          return Align(
            alignment: Alignment.topLeft,
            child : Material(
            child: SizedBox(
              width: 275,
              height: 200,
              child:
              ListView.builder(

                  padding: EdgeInsets.all(10.0),
                  itemCount: options.length,
                  itemBuilder: (BuildContext, int index) {
                    final String option = options.elementAt(index);

                    return GestureDetector (
                      onTap: () => onSelected(option),
                      child: ListTile (
                      title: Text(option),
                    ),
                    );

                  }

              ),
            ),
          ),
          );

        },
      ),
      trailing: IconButton(
      icon: const Icon(Icons.search),
        onPressed: () {GoTo(context, textEditingValue.text);
      }
    ),
    );

  }

  GoTo(BuildContext context, String job) {
    bool value_in_list = false;


    for (String val in Options) {
      log("in list val : " + val);

      if (job == val) {
        log("value trouver");
        value_in_list = true;
      }
      log(job);
    }
    if (value_in_list) {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => JobListScreen(result: job),
      ));
    } else {
      showDialog<String>(
        context: context,
        builder: (BuildContext context) =>
            AlertDialog(
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
