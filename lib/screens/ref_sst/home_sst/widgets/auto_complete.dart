import 'dart:developer';

import 'package:flutter/material.dart';

import '../../job_list_risks_and_skills/job_list_screen.dart';

class AutocompleteBasicExample extends StatelessWidget {
  const AutocompleteBasicExample({super.key});

  static const List<String> _kOptions = <String>[
    'aardvark',
    'bobcat',
    'chameleon',
  ];

  @override
  Widget build(BuildContext context) {
    TextEditingValue textEditingValue = TextEditingValue();
    return
      ListTile(  title: Autocomplete<String>(
        optionsBuilder: (value) {
          if (value.text == '') {
            textEditingValue = value;
            return const Iterable<String>.empty();
          }
          return _kOptions.where((String option) {
            textEditingValue = value;
            return option.contains(value.text.toLowerCase());
          });
        },
        onSelected: (String selection) {
          debugPrint('You just selected $selection');
        },
      ),
        trailing: IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {GoTo(context, textEditingValue.text);
          },
        ),);
  }

  GoTo(BuildContext context, String job){
      bool value_in_list = false;


      for(String val in _kOptions){
        log("val");
        if( job == val){
          log("value trouver");
          value_in_list = true;
        }

      }

    if(value_in_list){
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => JobListScreen(result: job),
      ));
    }else{
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
}
