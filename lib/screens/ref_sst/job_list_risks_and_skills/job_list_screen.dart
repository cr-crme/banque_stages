import 'package:crcrme_banque_stages/screens/ref_sst/job_list_risks_and_skills/widgets/list_tile_job_risk.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'widgets/tile_job_risk.dart';

class JobListScreen extends StatefulWidget {
  const JobListScreen({Key? key}) : super(key: key);

  static const route = "/job_list_risks_skills";

  @override
  State<JobListScreen> createState() => _Job_list_screenState();
}

class _Job_list_screenState extends State<JobListScreen> {
  bool switch_value = true;
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
    setState(() {});
  }

  void testButton2() {
    elevationTile1 = 5;
    elevationTile2 = 0;
    textColor = Colors.blue;
    textColor2 = Colors.white;
    colorTile = Colors.blue;
    colorTile2 = Colors.white;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Nom métier'),
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
                      title: Text('Affichage par risque'),
                      subtitle: null,
                      trailing: Icon(Icons.warning),
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
                      title: Text('Affichage par compétence'),
                      trailing: Icon(Icons.school),
                      tileColor: colorTile,
                    ),
                  ),
                ),
                // Container(
                //   width: 100,
                //   height: 50,
                //   decoration: BoxDecoration(color: Colors.blue),
                // )

                // Text("Par risque"),
                // Switch(
                //     value: switch_value,
                //     onChanged: (bool value) {
                //       // This is called when the user toggles the switch.
                //       setState(() {
                //         switch_value = value;
                //       });
                //     }),
                // Text("Par compétence")
              ],
            ),
          ),
          ListTileJobRisk()
        ]));
  }
}
