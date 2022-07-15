import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/common/providers/enterprises_provider.dart';
import 'screens/enterprises/add_enterprise.dart';
import 'screens/enterprises/enterprise_details.dart';
import 'screens/enterprises/enterprises_list.dart';
import 'screens/home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<EnterprisesProvider>(
          create: (context) => EnterprisesProvider(),
        )
      ],
      child: MaterialApp(
        title: 'Banque de Stages',
        theme: null,
        initialRoute: EnterprisesList.route,
        routes: {
          Home.route: (context) => const Home(),
          EnterprisesList.route: (context) => const EnterprisesList(),
          EnterpriseDetails.route: (context) => const EnterpriseDetails(),
          AddEnterprise.route: (context) => const AddEnterprise()
        },
      ),
    );
  }
}
