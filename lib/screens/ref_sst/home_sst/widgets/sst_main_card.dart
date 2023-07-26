import 'package:crcrme_banque_stages/common/widgets/sub_title.dart';
import 'package:flutter/material.dart';

class SstMainCard extends StatelessWidget {
  const SstMainCard({
    super.key,
    required this.title,
    required this.content,
    required this.onTap,
  });

  final String title;
  final Widget content;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 10,
      child: Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 12.0),
        child: ListTile(
          onTap: onTap,
          title: SubTitle(title, left: 0, top: 0),
          subtitle: content,
          subtitleTextStyle: Theme.of(context).textTheme.bodyLarge,
          textColor: Colors.black,
        ),
      ),
    );
  }
}
