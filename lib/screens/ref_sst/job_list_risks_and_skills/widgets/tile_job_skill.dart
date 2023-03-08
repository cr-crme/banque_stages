import 'package:flutter/material.dart';

class TileJobSkill extends StatelessWidget {
  const TileJobSkill({super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
          textColor: Colors.black,
          collapsedTextColor: Colors.black,
          title: const Text(
              'Nom compétence - Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do',
              style: TextStyle(fontSize: 17)),
          trailing: Material(
            elevation: 10,
            borderRadius: BorderRadius.circular(100),
            child: Container(
                height: 30,
                width: 30,
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: const [
                      BoxShadow(
                        spreadRadius: 1,
                        blurRadius: 5,
                        color: Colors.grey,
                      )
                    ],
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(100)),
                child: const Center(
                  child: Text(
                    '00',
                    style: TextStyle(color: Colors.white),
                  ),
                )),
          ),
          children: [
            for (int i = 0; i < 5; i++)
              const ListTile(
                title: Text(
                    'Compétence - Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor',
                    style:
                        TextStyle(color: Color.fromARGB(255, 113, 111, 111))),
                minVerticalPadding: 20,
              ),
          ]),
    );
  }
}
