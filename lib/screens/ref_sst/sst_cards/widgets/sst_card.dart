import 'package:flutter/material.dart';

class SSTCard extends StatelessWidget {
  const SSTCard({super.key});
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
              Text("Fiche XX", style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      "Lorem ipsum dolor sit amet, consectetur adipiscing elit",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
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
