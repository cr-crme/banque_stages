import 'package:flutter/material.dart';
import 'auto_complete.dart';

class SearchBar extends StatelessWidget with PreferredSizeWidget {
  const SearchBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: const Card(
        elevation: 20,
        child: AutocompleteSearch(),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(72);
}
