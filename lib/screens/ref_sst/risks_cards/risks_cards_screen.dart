import 'package:flutter/material.dart';

class RisksCardsScreen extends StatefulWidget {
  const RisksCardsScreen(this.nmb, {super.key});
  final int nmb;
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
          title: Text("Fiche ${widget.nmb}"),
        ),
        body: ListView());
  }
}
