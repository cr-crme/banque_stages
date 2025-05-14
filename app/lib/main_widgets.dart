// coverage:ignore-start
import 'package:crcrme_banque_stages/common/widgets/form_fields/job_form_field_list_tile.dart';
import 'package:flutter/material.dart';

void main() async {
  runApp(const BanqueStagesApp());
}

// coverage:ignore-end
class BanqueStagesApp extends StatelessWidget {
  const BanqueStagesApp({super.key});

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    return MaterialApp(
      title: 'Banque de Stages test Widgets',
      home: Scaffold(
        body: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: const JobFormFieldListTile(),
          ),
        ),
      ),
    );
  }
}
