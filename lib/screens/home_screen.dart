import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/common/providers/enterprises_provider.dart';
import '/common/widgets/main_drawer.dart';
import '/screens/internship_forms/post_internship_evaluation_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
      ),
      drawer: const MainDrawer(),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            final enterprise = context.read<EnterprisesProvider>().first;
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => PostInternshipEvaluationScreen(
                  enterpriseId: enterprise.id,
                  jobId: enterprise.jobs.first.id,
                ),
              ),
            );
          },
          child: const Text("Open internship evaluation"),
        ),
      ),
    );
  }
}
