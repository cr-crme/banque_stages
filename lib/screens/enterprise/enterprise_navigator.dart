import 'package:flutter/material.dart';

import 'enterprise_contact.dart';
import 'enterprise_general_informations.dart';
import 'enterprise_job_exigences.dart';
import 'enterprise_job_sst.dart';
import 'enterprise_job_task.dart';
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
          case EnterpriseGeneralInformation.route:
            page = EnterpriseGeneralInformation(
              enterpriseId: enterpriseId,
            );
            break;
          case EnterpriseContact.route:
            page = EnterpriseContact(
              enterpriseId: enterpriseId,
            );
            break;
          case EnterpriseJobTask.route:
            page = EnterpriseJobTask(
              enterpriseId: enterpriseId,
            );
            break;
          case EnterpriseJobSST.route:
            page = EnterpriseJobSST(
              enterpriseId: enterpriseId,
            );
            break;
          case EnterpriseJobExigences.route:
            page = EnterpriseJobExigences(
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
