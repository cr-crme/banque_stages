import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '/common/models/enterprise.dart';
import '/common/models/internship.dart';
import '/common/providers/internships_provider.dart';
import '/router.dart';

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
    GoRouter.of(context).goNamed(
      Screens.internshipEnrollement,
      params: Screens.withId(widget.enterprise.id),
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
          ListView.builder(
            shrinkWrap: true,
            itemCount: widget.enterprise.internshipIds.length,
            itemBuilder: (context, index) =>
                Selector<InternshipsProvider, Internship>(
              builder: (context, internship, _) => ListTile(
                title: Text(internship.id),
              ),
              selector: (context, internships) =>
                  internships[widget.enterprise.internshipIds[index]],
            ),
          ),
        ],
      ),
    );
  }
}
