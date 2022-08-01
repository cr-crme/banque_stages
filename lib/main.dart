import 'package:crcrme_banque_stages/crcrme_material_theme/lib/crcrme_material_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/common/providers/enterprises_provider.dart';
import 'dummy_data.dart';
import 'screens/add_enterprise_screen.dart';
import 'screens/enterprise/enterprise_screen.dart';
import 'screens/enterprises_list_screen.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (context) => dummyData(EnterprisesProvider())),
      ],
      child: MaterialApp(
        title: 'Banque de Stages',
        theme: crcrmeMaterialTheme,
        initialRoute: HomeScreen.route,
        routes: {
          HomeScreen.route: (context) => const HomeScreen(),
          EnterprisesListScreen.route: (context) =>
              const EnterprisesListScreen(),
          AddEnterpriseScreen.route: (context) => const AddEnterpriseScreen(),
          EnterpriseScreen.route: (context) => const EnterpriseScreen(),
        },
      ),
    );
  }
}
