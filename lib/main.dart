import 'package:flutter/material.dart';

import './screens/home.dart';
import './screens/entreprises/add.dart';

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
      initialRoute: AddEntreprise.route,
      routes: {
        Home.route: (context) => const Home(),
        AddEntreprise.route: (context) => const AddEntreprise()
      },
    );
  }
}
