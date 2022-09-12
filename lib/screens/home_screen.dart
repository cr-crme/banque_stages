import 'package:flutter/material.dart';

import '/common/widgets/main_drawer.dart';
import '/screens/internship_forms/post_internship_evaluation_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  static const route = "/";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
      ),
      drawer: const MainDrawer(),
      body: Center(
        child: ElevatedButton(
          onPressed: () => Navigator.pushNamed(
              context, PostInternshipEvaluationScreen.route),
          child: const Text("Open internship evaluation"),
        ),
      ),
    );
  }
}
