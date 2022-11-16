import 'package:flutter/material.dart';
import 'auto_complete.dart';

class SearchBar extends StatelessWidget with PreferredSizeWidget {
  const SearchBar({Key? key, required this.controller}) : super(key: key);

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Card(
        elevation: 0,
        child: AutocompleteBasicExample(),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(72);
}
