import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/common/providers/enterprises_provider.dart';
import 'screens/enterprises/add_enterprise.dart';
import 'screens/enterprise/enterprise_navigator.dart';
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
        initialRoute: Home.route,
        onGenerateRoute: (settings) {
          late Widget page;
          if (Home.route == settings.name) {
            page = const Home();
          } else if (EnterprisesList.route == settings.name) {
            page = const EnterprisesList();
          } else if (AddEnterprise.route == settings.name) {
            page = const AddEnterprise();
          } else if (settings.name!.startsWith(EnterpriseNavigator.route)) {
            page = const EnterpriseNavigator();
          } else {
            throw Exception('Unknown route: ${settings.name}');
          }

          return MaterialPageRoute(
            builder: (context) => page,
            settings: settings,
          );
        },
      ),
    );
  }
}
