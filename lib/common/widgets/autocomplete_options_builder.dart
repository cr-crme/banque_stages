import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class OptionsBuilderForAutocomplete<T extends Object> extends StatelessWidget {
  const OptionsBuilderForAutocomplete({
    super.key,
    required this.onSelected,
    required this.options,
    required this.optionToString,
  });

  final AutocompleteOnSelected<T> onSelected;
  final Iterable<T> options;
  final String Function(T) optionToString;

  @override
  Widget build(BuildContext context) {
    final scrollController = ScrollController();
    return Align(
      alignment: Alignment.topLeft,
      child: Material(
        elevation: 4.0,
        child: ConstrainedBox(
          constraints: BoxConstraints(
              maxHeight: 200,
              maxWidth: MediaQuery.of(context).size.width * 5 / 6),
          child: RawScrollbar(
            controller: scrollController,
            thumbVisibility: true,
            thickness: 7,
            minThumbLength: 75,
            thumbColor: Theme.of(context).primaryColor,
            radius: const Radius.circular(20),
            child: SingleChildScrollView(
              controller: scrollController,
              child: ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final T option = options.elementAt(index);
                  return InkWell(
                    onTap: () => onSelected(option),
                    child: Builder(builder: (ctx) {
                      final bool highlight =
                          AutocompleteHighlightedOption.of(ctx) == index;
                      if (highlight) {
                        SchedulerBinding.instance
                            .addPostFrameCallback((timeStamp) {
                          Scrollable.ensureVisible(ctx, alignment: 0.5);
                        });
                      }
                      return Container(
                        color: highlight ? Theme.of(ctx).focusColor : null,
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          RawAutocomplete.defaultStringForOption(
                              optionToString(option)),
                        ),
                      );
                    }),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
