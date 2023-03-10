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

class _AutoCompleteSstSearchBar extends StatefulWidget {
  const _AutoCompleteSstSearchBar();

  @override
  State<_AutoCompleteSstSearchBar> createState() =>
      _AutoCompleteSstSearchBarState();
}

class _AutoCompleteSstSearchBarState extends State<_AutoCompleteSstSearchBar> {
  final _textController = TextEditingController();
  final _focusNode = FocusNode();

  void _clearText() => _textController.text = '';

  Widget _fieldViewBuilder(
      BuildContext context,
      TextEditingController textEditingController,
      FocusNode focusNode,
      VoidCallback onFieldSubmitted) {
    return TextFormField(
      decoration: InputDecoration(
          icon: const Icon(Icons.search),
          labelText: 'Rechercher un métier',
          suffixIcon:
              IconButton(onPressed: _clearText, icon: const Icon(Icons.clear))),
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
        .map<String?>((e) => e.name
                    .toLowerCase()
                    .contains(value.text.toLowerCase()) ||
                e.id.contains(value.text) ||
                e.idWithName.toLowerCase().contains(value.text.toLowerCase())
            ? e.idWithName
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
      textEditingController: _textController,
      focusNode: _focusNode,
      fieldViewBuilder: _fieldViewBuilder,
      optionsBuilder: (value) => _optionsBuilder(value, options),
      onSelected: (choice) => goTo(context, choice, options),
      optionsViewBuilder: (context, onSelected, options) =>
          _optionsViewBuilder(options, onSelected),
    );
  }

  goTo(BuildContext context, String choice, List<Specialization> options) {
    final index = options.indexWhere((e) => e.idWithName == choice);

    _clearText();
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => JobListScreen(id: options[index].id),
    ));
  }
}
