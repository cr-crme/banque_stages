import 'package:flutter/material.dart';

import '/common/models/student.dart';

class InternshipsPage extends StatefulWidget {
  const InternshipsPage({
    super.key,
    required this.student,
  });

  final Student student;

  @override
  State<InternshipsPage> createState() => InternshipsPageState();
}

class InternshipsPageState extends State<InternshipsPage> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
