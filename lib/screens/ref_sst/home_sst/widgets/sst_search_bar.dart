import 'package:flutter/material.dart';

import '/misc/job_data_file_service.dart';
import '../../specialization_list_risks_and_skills/specialization_list_screen.dart';

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

  List<Specialization> _evaluatedSpecializations() {
    List<Specialization> out = [];
    for (final sector in ActivitySectorsService.sectors) {
      for (final specialization in sector.specializations) {
        // If there is no risk, it does not mean this specialization
        // is risk-free, it means it was not evaluated
        var hasRisks = false;
        for (final skill in specialization.skills) {
          hasRisks = skill.risks.isNotEmpty;
          if (hasRisks) break;
        }
        if (hasRisks) out.add(specialization);
      }
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final options = _evaluatedSpecializations();
    options
        .sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    return RawAutocomplete<String>(
      textEditingController: _textController,
      focusNode: _focusNode,
      fieldViewBuilder: _fieldViewBuilder,
      optionsBuilder: (value) => _optionsBuilder(value, options),
      onSelected: (choice) {
        _focusNode.unfocus();
        goTo(context, choice, options);
      },
      optionsViewBuilder: (context, onSelected, options) =>
          _optionsViewBuilder(options, onSelected),
    );
  }

  goTo(BuildContext context, String choice, List<Specialization> options) {
    final index = options.indexWhere((e) => e.idWithName == choice);

    _clearText();
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => SpecializationListScreen(id: options[index].id),
    ));
  }
}
