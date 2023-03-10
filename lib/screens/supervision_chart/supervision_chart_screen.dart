import 'package:flutter/material.dart';

import '/common/widgets/main_drawer.dart';

class SupervisionChart extends StatelessWidget {
  const SupervisionChart({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final iconSize = screenSize.width / 16;

    return Scaffold(
      appBar: AppBar(
        title: const Padding(
          padding: EdgeInsets.only(top: 5.0, bottom: 5),
          child: Text('Élèves à superviser'),
        ),
        bottom: PreferredSize(
            preferredSize: Size(screenSize.width, iconSize),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _TabIcon(
                      screenSize: screenSize,
                      iconSize: iconSize,
                      onTap: () {},
                      icon: Icons.person_search_sharp),
                  _TabIcon(
                      screenSize: screenSize,
                      iconSize: iconSize,
                      onTap: () {},
                      icon: Icons.search),
                  _TabIcon(
                      screenSize: screenSize,
                      iconSize: iconSize,
                      onTap: () {},
                      icon: Icons.filter_alt_sharp),
                ])),
      ),
      body: Container(),
      drawer: const MainDrawer(),
    );
  }
}

class _TabIcon extends StatelessWidget {
  const _TabIcon({
    Key? key,
    required this.screenSize,
    required this.iconSize,
    required this.icon,
    this.onTap,
  }) : super(key: key);

  final Size screenSize;
  final double iconSize;
  final IconData icon;
  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        width: screenSize.width / 3,
        height: iconSize * 1.5,
        child: Icon(
          icon,
          size: iconSize,
        ),
      ),
    );
  }
}
