import 'package:flutter/material.dart';

import 'enterprises/enterprises_list.dart';

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

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
          onPressed: () => _navigateFromDrawer(context, EnterprisesList.route),
          child: const Text("Entreprises"),
        )),
      )),
    );
  }
}
