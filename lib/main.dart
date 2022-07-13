import 'package:flutter/material.dart';

import 'screens/home.dart';
import 'screens/enterprises/enterprises_list.dart';
import 'screens/enterprises/add_enterprise.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Banque de Stages',
      theme: null,
      initialRoute: EnterprisesList.route,
      routes: {
        Home.route: (context) => const Home(),
        EnterprisesList.route: (context) => const EnterprisesList(),
        AddEnterprise.route: (context) => const AddEnterprise()
      },
    );
  }
}
