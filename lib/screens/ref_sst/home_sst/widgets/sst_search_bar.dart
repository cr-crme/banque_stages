import 'package:flutter/material.dart';

import '/misc/job_data_file_service.dart';
import '../../job_list_risks_and_skills/job_list_screen.dart';

class SstSearchBar extends StatelessWidget {
  const SstSearchBar({super.key});

  static TextEditingValue textEditingValue = const TextEditingValue();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Card(
        elevation: 20,
        child: ListTile(
          title: _AutoCompleteSstSearchBar(),
        ),
      ),
    );
  }
}

class _AutoCompleteSstSearchBar extends StatelessWidget {
  const _AutoCompleteSstSearchBar();

  @override
  Widget build(BuildContext context) {
    final options = JobDataFileService.specializations;
    options
        .sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    return Autocomplete<String>(
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
    );
  }

  goTo(BuildContext context, String choice, List<Specialization> options) {
    final index = options.indexWhere((e) => e.name == choice);
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => JobListScreen(id: options[index].id),
    ));
  }
}
