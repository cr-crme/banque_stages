import 'package:flutter/material.dart';

class RisksCardsScreen extends StatefulWidget {
  const RisksCardsScreen({Key? key}) : super(key: key);

  static const route = "/risks-cards";

  @override
  State<RisksCardsScreen> createState() => _RisksCardsScreenState();
}

class _RisksCardsScreenState extends State<RisksCardsScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Fiche XX"),
        ),
        body: ListView());
  }
}
