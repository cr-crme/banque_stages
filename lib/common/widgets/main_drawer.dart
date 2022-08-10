import 'package:flutter/material.dart';

import '/screens/enterprises_list_screen.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Scaffold(
        appBar: AppBar(title: const Text("Menu principal")),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Card(
                elevation: 1,
                child: ListTile(
                  onTap: () => Navigator.popAndPushNamed(
                      context, EnterprisesListScreen.route),
                  title: Text(
                    "Toutes les entreprises",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
