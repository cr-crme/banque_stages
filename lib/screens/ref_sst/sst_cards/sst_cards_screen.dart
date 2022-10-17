// ignore_for_file: non_constant_identifier_names
//import 'dart:js_util';

import 'package:flutter/material.dart';

import '../sst_cache.dart';
import 'widgets/sst_card.dart';
import 'dart:convert';
import '../common/risk_sst.dart';

class SSTCardsScreen extends StatefulWidget {
  const SSTCardsScreen({Key? key}) : super(key: key);

  static const route = "/sst-cards";

  @override
  State<SSTCardsScreen> createState() => _SSTCardsScreenState();
}

class _SSTCardsScreenState extends State<SSTCardsScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Fiches de risques"),
        ),
        body: SSTCache().getListViewRisk());
  }
}
