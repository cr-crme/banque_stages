import 'package:flutter/material.dart';

import 'enterprises_list_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  static const route = "/";

  void _navigateFromDrawer(BuildContext context, String route) {
    Navigator.pop(context);
    Navigator.pushNamed(context, route);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
      ),
      drawer: Drawer(
          child: Scaffold(
        appBar: AppBar(),
        body: ListTile(
            title: TextButton(
          onPressed: () =>
              _navigateFromDrawer(context, EnterprisesListScreen.route),
          child: const Text("Entreprises"),
        )),
      )),
    );
  }
}
