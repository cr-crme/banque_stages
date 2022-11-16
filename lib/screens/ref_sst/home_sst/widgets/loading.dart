import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../common/providers/students_provider.dart';
import '../home_sst_screen.dart';

class loading extends State<HomeSSTScreen> {
  Future<String> test = Future<String>.value("");

  @override
  void initState() {
    super.initState();

    final data =
    Provider.of<StudentsProvider>(context, listen: false);
    if (data.isEmpty) test = fetchRisks();
  }

  Future<String> fetchRisks() async {
    await const Duration(seconds: 1);
    return "";
  }

  @override
  Widget build(BuildContext context) {
    var data =
    Provider.of<StudentsProvider>(context, listen: true);
    if (data.isEmpty) {
      return FutureBuilder<String>(builder: (ctx, snapshot) {
        if (snapshot.hasData) data = snapshot.data! as StudentsProvider;

        return const CircularProgressIndicator();
      });
    } else {
      return build(context);
    }
  }
}
