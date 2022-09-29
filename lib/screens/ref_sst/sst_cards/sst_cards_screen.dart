import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'widgets/sst_card.dart';

class SSTCardsScreen extends StatefulWidget {
  const SSTCardsScreen({Key? key}) : super(key: key);

  static const route = "/sst-cards";

  @override
  State<SSTCardsScreen> createState() => _SSTCardsScreenState();
}

class _SSTCardsScreenState extends State<SSTCardsScreen> {
  bool _hideNotAvailable = false;

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
        body: ListView(
          padding: const EdgeInsets.all(8),
          children: <Widget>[
            SSTCard(),
            SSTCard(),
            SSTCard(),
            SSTCard(),
            SSTCard(),
            SSTCard(),
            SSTCard(),
            SSTCard(),
            SSTCard(),
            SSTCard(),
            SSTCard(),
            SSTCard(),
          ],
        ));
  }
}
