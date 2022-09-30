import 'package:crcrme_banque_stages/screens/ref_sst/sst_cards/sst_cards_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/common/models/enterprise.dart';
import '/common/providers/enterprises_provider.dart';
import '/dummy_data.dart';
import '/screens/add_enterprise/add_enterprise_screen.dart';
import '/screens/enterprise/enterprise_screen.dart';
import 'widgets/search_bar.dart';

final ButtonStyle raisedButtonStyle = ElevatedButton.styleFrom(
  onPrimary: Colors.black87,
  primary: Colors.grey[300],
  padding: EdgeInsets.symmetric(horizontal: 16),
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(2)),
  ),
);

class HomeSSTScreen extends StatefulWidget {
  const HomeSSTScreen({Key? key}) : super(key: key);

  static const route = "/home-sst";

  @override
  State<HomeSSTScreen> createState() => _HomeSSTScreenState();
}

class _HomeSSTScreenState extends State<HomeSSTScreen> {
  bool _hideNotAvailable = false;

  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Référentiel SST"),
          // actions: [
          //   IconButton(
          //     onPressed: () =>
          //         Navigator.pushNamed(context, AddEnterpriseScreen.route),
          //     tooltip: "Ajouter une entreprise",
          //     icon: const Icon(Icons.add),
          //   ),
          // ],
          //bottom: SearchBar(controller: _searchController),
        ),
        body: Column(
          //mainAxisAlignment: MainAxisAlignment.center,
          //crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 35),
            Center(
              child: InkWell(
                onTap: () {
                  print("Clicked on sst cards list");
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => SSTCardsScreen(),
                  ));
                },
                child: Ink(
                  color: Colors.blue,
                  width: 300,
                  height: 260,
                ),
              ),

              //Test button
              //Center(
              // ElevatedButton(
              //   style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              //   onPressed: () {
              //     print('Hello');
              //   },
              //   child: const Text(
              //     'Consulter les fiches de risques',
              //     //textAlign: TextAlign.center,
              //     // overflow: TextOverflow.visible,
              //     //style: TextStyle(fontWeight: FontWeight.bold),
              //   ),
              // ),
              //),
              //Button connected to fiches de risques
              //Center(
              // ElevatedButton(
              //   child: const Text('Bonjour!'),
              //   onPressed: () {
              //     print('Hello');
              //   },
              // )
              //),
            ),
            SizedBox(height: 50),
            Center(
                child: InkWell(
              onTap: () {
                print("hello");
              },
              child: Ink(
                color: Colors.blue,
                width: 300,
                height: 260,
              ),
            ))
          ],
        ));
  }
}
