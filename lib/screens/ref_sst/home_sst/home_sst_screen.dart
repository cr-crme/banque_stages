import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/common/models/enterprise.dart';
import '/common/providers/enterprises_provider.dart';
import '/dummy_data.dart';
import '/screens/add_enterprise/add_enterprise_screen.dart';
import '/screens/enterprise/enterprise_screen.dart';
import 'widgets/list_item.dart';
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
            Center(
                child: Container(
              color: Colors.blue,
              width: 48,
              height: 48,
              child: InkWell(
                onTap: () {
                  print("hello");
                },
              ),
            )
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
                )
          ],
        ));
  }
}
