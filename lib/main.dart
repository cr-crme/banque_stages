import 'package:crcrme_banque_stages/crcrme_material_theme/lib/crcrme_material_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/common/providers/enterprises_provider.dart';
import 'screens/add_enterprise.dart';
import 'screens/enterprise_details.dart';
import 'screens/enterprises_list.dart';
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
        theme: crcrmeMaterialTheme,
        initialRoute: Home.route,
        routes: {
          Home.route: (context) => const Home(),
          EnterprisesList.route: (context) => const EnterprisesList(),
          AddEnterprise.route: (context) => const AddEnterprise(),
          EnterpriseDetails.route: (context) => const EnterpriseDetails(),
        },
      ),
    );
  }
}
