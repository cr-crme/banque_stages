import 'package:flutter/material.dart';
import 'widgets/tile_job_risk.dart';

class JobListScreen extends StatefulWidget {
  final String id;
  const JobListScreen({super.key, required this.id});

  @override
  State<JobListScreen> createState() => _JobListScreenState();
}

class _JobListScreenState extends State<JobListScreen> {
  bool switchValue = true;
  bool switchRisk = true;
  Color colorTile = Colors.blue;
  Color textColor = Colors.blue;
  Color textColor2 = Colors.white;
  Color colorTile2 = Colors.white;
  double elevationTile1 = 5;
  double elevationTile2 = 0;

  get onChanged => null;

  @override
  void initState() {
    super.initState();
  }

  void testButton() {
    elevationTile1 = 0;
    elevationTile2 = 5;
    textColor = Colors.white;
    textColor2 = Colors.blue;
    colorTile = Colors.white;
    colorTile2 = Colors.blue;
    switchRisk = false;
    setState(() {});
  }

  void testButton2() {
    elevationTile1 = 5;
    elevationTile2 = 0;
    textColor = Colors.blue;
    textColor2 = Colors.white;
    colorTile = Colors.blue;
    colorTile2 = Colors.white;
    switchRisk = true;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.id),
        ),
        body: ListView(children: [
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  width: 192.273,
                  height: 50,
                  child: Material(
                    elevation: elevationTile1,
                    child: ListTile(
                      textColor: textColor,
                      iconColor: textColor,
                      title: const Text('Affichage par risque'),
                      subtitle: null,
                      trailing: const Icon(Icons.warning),
                      tileColor: colorTile2,
                      onTap: (testButton2),
                      horizontalTitleGap: 16,
                    ),
                  ),
                ),
                SizedBox(
                  //192
                  width: 200,
                  height: 50,
                  child: Material(
                    elevation: elevationTile2,
                    child: ListTile(
                      textColor: textColor2,
                      iconColor: textColor2,
                      onTap: (testButton),
                      title: const Text('Affichage par compétence'),
                      trailing: const Icon(Icons.school),
                      tileColor: colorTile,
                    ),
                  ),
                ),
                // Container(
                //   width: 100,
                //   height: 50,
                //   decoration: BoxDecoration(color: Colors.blue),
                // )

                // Text('Par risque'),
                // Switch(
                //     value: switch_value,
                //     onChanged: (bool value) {
                //       // This is called when the user toggles the switch.
                //       setState(() {
                //         switch_value = value;
                //       });
                //     }),
                // Text('Par compétence')
              ],
            ),
          ),
          ListView.separated(
            physics: const ScrollPhysics(),
            shrinkWrap: true,
            itemCount: 5,
            padding: const EdgeInsets.all(16.0),
            itemBuilder: (context, i) {
              return TileJobRisk(switchRisk);
              // call the expansion tile constuctor list
            },
            separatorBuilder: (BuildContext context, int index) {
              return const Divider(
                color: Colors.grey,
                height: 16,
              );
            },
          )
        ]));
  }
}
