import 'package:crcrme_banque_stages/screens/ref_sst/risks_list/risks_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '/common/widgets/main_drawer.dart';
import '/router.dart';
import 'widgets/search_bar.dart';

class HomeSSTScreen extends StatefulWidget {
  const HomeSSTScreen({Key? key}) : super(key: key);

  @override
  State<HomeSSTScreen> createState() => _HomeSSTScreenState();
}

class _HomeSSTScreenState extends State<HomeSSTScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));
  }

  //Future<void> fetchRisks() async {
  //  await RiskDataFileService.loadData();
  //}

  bool test = true;

  @override
  Widget build(BuildContext context) {
    Widget body;
    body = ListView(
      children: [
        //Container for the search bar
        Center(
            child: Container(
          margin: const EdgeInsets.only(top: 50.0),
          width: 350,
          height: 280,
          padding: const EdgeInsets.all(17.0),
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            color: Colors.blue,
            boxShadow: [
              BoxShadow(color: Colors.grey, spreadRadius: 1, blurRadius: 15)
            ],
          ),
          child: InkWell(
              child: Column(
            children: const [
              Text("Analyse des risques par métier",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 25,
                      color: Colors.white,
                      fontFamily: "Noto Sans")),
              Padding(padding: EdgeInsets.only(top: 25.0), child: SearchBar()),
              Padding(
                padding: EdgeInsets.only(top: 30.0),
                child: Text(
                  "L'analyse des risques à la SST a été faite pour les 45 métiers les plus populaires du répertoires du Ministère de l'éducation.",
                  textAlign: TextAlign.justify,
                  style: TextStyle(
                      fontSize: 11,
                      color: Colors.white,
                      fontStyle: FontStyle.italic),
                ),
              )
            ],
          )),
        )),
        Center(
            child: Container(
          margin: const EdgeInsets.only(top: 35.0),
          child: InkWell(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => SSTCardsScreen(),
              ));
            },
            child: Ink(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                color: Colors.blue,
                boxShadow: [
                  BoxShadow(color: Colors.grey, spreadRadius: 1, blurRadius: 15)
                ],
              ),
              width: 350,
              height: 250,
              child: const Padding(
                padding: EdgeInsets.all(45.0),
                child: Center(
                  child: Text(
                    "Consulter les fiches de risques",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 25,
                        color: Colors.white,
                        fontFamily: "Noto Sans"),
                  ),
                ),
              ),
            ),
          ),
        )),
      ],
    );
    //}
    // To refresh the scaffold body after the data fetch
    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
    return Scaffold(
        appBar: AppBar(
          title: const Text("Référentiel SST"),
        ),
        drawer: const MainDrawer(),
        body: body);
  }
}
