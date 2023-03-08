import 'package:flutter/material.dart';
import 'widgets/tile_job_risk.dart';
import 'widgets/tile_job_skill.dart';

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

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
          appBar: AppBar(
            title: Text(widget.id),
            bottom: TabBar(tabs: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text('Risques', style: TextStyle(fontSize: 16)),
                    SizedBox(width: 10),
                    Icon(Icons.warning),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text('Compétences', style: TextStyle(fontSize: 16)),
                    SizedBox(width: 10),
                    Icon(Icons.school),
                  ],
                ),
              ),
            ]),
          ),
          body: TabBarView(children: [
            ListView.separated(
              physics: const ScrollPhysics(),
              shrinkWrap: true,
              itemCount: 5,
              padding: const EdgeInsets.all(16.0),
              itemBuilder: (context, i) => const TileJobRisk(),
              separatorBuilder: (BuildContext context, int index) {
                return const Divider(
                  color: Colors.grey,
                  height: 16,
                );
              },
            ),
            ListView.separated(
              physics: const ScrollPhysics(),
              shrinkWrap: true,
              itemCount: 5,
              padding: const EdgeInsets.all(16.0),
              itemBuilder: (context, i) => const TileJobSkill(),
              separatorBuilder: (BuildContext context, int index) {
                return const Divider(
                  color: Colors.grey,
                  height: 16,
                );
              },
            )
          ])),
    );
  }
}
