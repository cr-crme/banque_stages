import 'package:flutter/material.dart';

import 'package:crcrme_banque_stages/common/widgets/main_drawer.dart';
import 'package:crcrme_banque_stages/screens/ref_sst/risks_list/risks_list_screen.dart';
import 'widgets/sst_search_bar.dart';

class HomeSstScreen extends StatefulWidget {
  const HomeSstScreen({Key? key}) : super(key: key);

  static const route = '/home-sst';

  @override
  State<HomeSstScreen> createState() => _HomeSstScreenState();
}

class _HomeSstScreenState extends State<HomeSstScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));
  }

  bool test = true;

  @override
  Widget build(BuildContext context) {
    Widget body;
    body = ListView(
      children: [
        // Container for the search bar
        Center(
            child: Container(
          margin: const EdgeInsets.only(top: 50.0),
          width: 350,
          height: 280,
          padding: const EdgeInsets.all(17.0),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            color: Theme.of(context).colorScheme.primary,
            boxShadow: const [
              BoxShadow(color: Colors.grey, spreadRadius: 1, blurRadius: 15)
            ],
          ),
          child: const InkWell(
              child: Column(
            children: [
              Text('Analyse des risques \npar métier',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 25,
                      color: Colors.white,
                      fontFamily: 'Noto Sans')),
              Padding(
                  padding: EdgeInsets.only(top: 25.0), child: SstSearchBar()),
              Padding(
                padding: EdgeInsets.only(top: 30.0),
                child: Text(
                  'Seuls les 45 métiers du répertoire du Ministère de l\'éducation, '
                  'qui ont été analysés, apparaissent dans la liste.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 12,
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
                builder: (_) => const SstCardsScreen(),
              ));
            },
            child: Ink(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                color: Theme.of(context).colorScheme.primary,
                boxShadow: const [
                  BoxShadow(color: Colors.grey, spreadRadius: 1, blurRadius: 15)
                ],
              ),
              width: 350,
              height: 250,
              child: const Padding(
                padding: EdgeInsets.all(45.0),
                child: Center(
                  child: Text(
                    'Fiches de risques',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 25,
                        color: Colors.white,
                        fontFamily: 'Noto Sans'),
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
          title: const Text('Référentiel SST'),
        ),
        drawer: const MainDrawer(),
        body: body);
  }
}
