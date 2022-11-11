import 'package:flutter/material.dart';

class tile_job_risk extends StatelessWidget {
  const tile_job_risk({super.key});
/**
 * create the expansion tile widget
 */
  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
        title: Text('ExpansionTile 1'),
        subtitle: Text('Trailing expansion arrow icon'),
        children: [for (int i = 0; i < 5; i++) dropdown_obect()],
    );
  }
}

/**
 * Create the texte inside de expansion list tiles 
 */
class dropdown_obect extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListTile(title: Text('This is tile number 1'));
  }
}
