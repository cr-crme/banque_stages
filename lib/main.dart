import 'package:flutter/material.dart';

import 'screens/home.dart';
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
      initialRoute: AddEnterprise.route,
      routes: {
        Home.route: (context) => const Home(),
        AddEnterprise.route: (context) => const AddEnterprise()
      },
    );
  }
}
