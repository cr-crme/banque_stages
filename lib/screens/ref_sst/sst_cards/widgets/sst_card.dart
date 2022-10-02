//import 'dart:js_util';

import 'package:flutter/material.dart';

class SSTCard extends StatelessWidget {
  //const SSTCard(int nmb, String title, {super.key});
  SSTCard(this.nmb, this.title);
  final int nmb;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0.5,
      child: InkWell(
        onTap: () =>
            print("Clicked"), //() => onTap(enterprise), //ON TAP SST CARD
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Fiche $nmb", style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  children: [
                    Text(title,
                        style: Theme.of(context).textTheme.titleMedium,
                        textAlign: TextAlign.left),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Icon(
                Icons.chevron_right,
                color: Theme.of(context).hintColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
