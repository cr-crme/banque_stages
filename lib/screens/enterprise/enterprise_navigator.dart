import 'package:flutter/material.dart';

import 'enterprise_contact.dart';
import 'enterprise_general_informations.dart';
import 'enterprise_overview.dart';

class EnterpriseNavigator extends StatefulWidget {
  const EnterpriseNavigator({Key? key}) : super(key: key);

  static const String route = "/enterprise/";

  @override
  State<EnterpriseNavigator> createState() => _EnterpriseNavigatorState();
}

class _EnterpriseNavigatorState extends State<EnterpriseNavigator> {
  final _navigatorKey = GlobalKey<NavigatorState>();

  late String enterpriseId =
      ModalRoute.of(context)!.settings.arguments as String;

  void _exit() {
    // _navigatorKey.currentState!.pop();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: _navigatorKey,
      initialRoute: EnterpriseOverview.route,
      onGenerateRoute: (settings) {
        late Widget page;

        if (EnterpriseOverview.route == settings.name) {
          page = EnterpriseOverview(enterpriseId: enterpriseId, exit: _exit);
        } else if (EnterpriseGeneralInformation.route == settings.name) {
          page = EnterpriseGeneralInformation(
            enterpriseId: enterpriseId,
          );
        } else if (EnterpriseContact.route == settings.name) {
          page = EnterpriseContact(
            enterpriseId: enterpriseId,
          );
        }

        return MaterialPageRoute(
            builder: (context) => page, settings: settings);
      },
    );
  }
}
