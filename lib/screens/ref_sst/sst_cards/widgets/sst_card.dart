//import 'dart:js_util';

import 'package:flutter/material.dart';

//SST
class SSTCard extends StatelessWidget {
  //params and variables
  const SSTCard(this.nmb, this.title, {super.key});
  final int nmb;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0.5,
      child: InkWell(
        //onTap should redirect to the risk
        onTap: () => print("Clicked"), //() => onTap(),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //Card number
              Text("Fiche $nmb", style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  children: [
                    //Card title
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
