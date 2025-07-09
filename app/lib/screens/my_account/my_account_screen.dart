import 'package:common_flutter/helpers/responsive_service.dart';
import 'package:crcrme_banque_stages/common/widgets/main_drawer.dart';
import 'package:flutter/material.dart';

class MyAccountScreen extends StatelessWidget {
  const MyAccountScreen({super.key});

  static const String route = '/my-account';

  @override
  Widget build(BuildContext context) {
    return ResponsiveService.scaffoldOf(
      context,
      appBar: ResponsiveService.appBarOf(
        context,
        title: const Text('Mon compte'),
      ),
      smallDrawer: MainDrawer.small,
      mediumDrawer: MainDrawer.medium,
      largeDrawer: MainDrawer.large,
      body: Text('TODO'),
    );
  }
}
