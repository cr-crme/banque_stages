import 'package:flutter/material.dart';

import '/common/models/enterprise.dart';
import '/screens/internship_enrollment/internship_enrollment_screen.dart';

class InternshipsPage extends StatefulWidget {
  const InternshipsPage({
    super.key,
    required this.enterprise,
  });

  final Enterprise enterprise;

  @override
  State<InternshipsPage> createState() => InternshipsPageState();
}

class InternshipsPageState extends State<InternshipsPage> {
  void addStage() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const InternshipEnrollmentScreen(),
        settings: RouteSettings(arguments: widget.enterprise.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          ListTile(
            title: Text(
              "Historique des stages",
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          const Divider(),
        ],
      ),
    );
  }
}
