import 'package:flutter/material.dart';
import 'CustomSearchDelegate.dart';

class SearchBar extends StatelessWidget with PreferredSizeWidget {
  const SearchBar({Key? key, required this.controller}) : super(key: key);

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Card(
        elevation: 0,
        child: ListTile(
          leading: IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // method to show the search bar
              showSearch(
                  context: context,
                  // delegate to customize the search bar
                  delegate: CustomSearchDelegate()
              );
            },
          ),
          title: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: "Rechercher",
              border: InputBorder.none,
            ),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.clear),
             onPressed: () => controller.text = "",
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(72);
}
