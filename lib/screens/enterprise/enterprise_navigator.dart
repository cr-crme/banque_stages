import 'package:flutter/material.dart';

import 'enterprise_informations.dart';
import 'enterprise_job.dart';
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

        switch (settings.name) {
          case EnterpriseOverview.route:
            page = EnterpriseOverview(enterpriseId: enterpriseId, exit: _exit);
            break;
          case EnterpriseInformations.route:
            page = EnterpriseInformations(
              enterpriseId: enterpriseId,
            );
            break;
          case EnterpriseJob.route:
            page = EnterpriseJob(
              enterpriseId: enterpriseId,
            );
            break;
        }

        return MaterialPageRoute(
            builder: (context) => page, settings: settings);
      },
    );
  }
}
