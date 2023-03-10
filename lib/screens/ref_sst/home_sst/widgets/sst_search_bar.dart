import 'package:flutter/material.dart';

import '/misc/job_data_file_service.dart';
import '../../job_list_risks_and_skills/job_list_screen.dart';

class SstSearchBar extends StatelessWidget {
  const SstSearchBar({super.key});

  static TextEditingValue textEditingValue = const TextEditingValue();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8), color: Colors.white),
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
      child: const ListTile(
        title: _AutoCompleteSstSearchBar(),
      ),
    );
  }
}

class _AutoCompleteSstSearchBar extends StatelessWidget {
  const _AutoCompleteSstSearchBar();

  Widget _fieldViewBuilder(
      BuildContext context,
      TextEditingController textEditingController,
      FocusNode focusNode,
      VoidCallback onFieldSubmitted) {
    return TextFormField(
      decoration: const InputDecoration(
        icon: Icon(Icons.search),
        labelText: 'Chercher un métier',
      ),
      controller: textEditingController,
      focusNode: focusNode,
      onFieldSubmitted: (String value) {
        onFieldSubmitted();
      },
    );
  }

  Iterable<String> _optionsBuilder(value, List<Specialization> options) {
    if (value.text == '') return const Iterable<String>.empty();
    return options
        .map<String?>((e) =>
            e.name.toLowerCase().contains(value.text.toLowerCase())
                ? e.name
                : null)
        .where((e) => e != null)
        .cast<String>();
  }

  Align _optionsViewBuilder(
      Iterable<String> options, AutocompleteOnSelected<String> onSelected) {
    final scrollController = ScrollController();
    return Align(
      alignment: Alignment.topLeft,
      child: Material(
        child: SizedBox(
          width: 275,
          height: 200,
          child: Scrollbar(
            thumbVisibility: true,
            controller: scrollController,
            child: ListView.builder(
                controller: scrollController,
                scrollDirection: Axis.vertical,
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final options = JobDataFileService.specializations;
    options
        .sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    return RawAutocomplete<String>(
      fieldViewBuilder: _fieldViewBuilder,
      optionsBuilder: (value) => _optionsBuilder(value, options),
      onSelected: (choice) => goTo(context, choice, options),
      optionsViewBuilder: (context, onSelected, options) =>
          _optionsViewBuilder(options, onSelected),
    );
  }

  goTo(BuildContext context, String choice, List<Specialization> options) {
    final index = options.indexWhere((e) => e.name == choice);
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => JobListScreen(id: options[index].id),
    ));
  }
}
