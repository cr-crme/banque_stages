import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '/common/providers/auth_provider.dart';
import '/router.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    if (context.watch<AuthProvider>().currentUser == null) {
      Future.microtask(() => GoRouter.of(context).goNamed(Screens.login));
    }

    return Consumer<AuthProvider>(
      builder: (context, provider, _) => Drawer(
        child: Scaffold(
          appBar: AppBar(title: const Text('Banque de Stages')),
          body: SingleChildScrollView(
            child: Column(
              children: [
                const _DrawerItem(
                  titleText: 'Tableau des supervisions',
                  icon: Icon(Icons.table_chart_rounded),
                  route: Screens.supervisionChart,
                ),
                const _DrawerItem(
                  titleText: 'Mes élèves',
                  icon: Icon(Icons.school_rounded),
                  route: Screens.studentsList,
                ),
                const _DrawerItem(
                  titleText: 'Toutes les entreprises',
                  icon: Icon(Icons.location_city_rounded),
                  route: Screens.enterprisesList,
                ),
                const _DrawerItem(
                  titleText: 'Documents',
                  icon: Icon(Icons.document_scanner_rounded),
                  route: Screens.enterprisesList,
                ),
                const _DrawerItem(
                  titleText: 'Référentiel SST',
                  icon: Icon(Icons.security),
                  route: Screens.homeSst,
                ),
                _DrawerItem(
                  titleText: 'Se déconnecter',
                  icon: const Icon(Icons.logout),
                  onTap: () => provider.signOut(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  const _DrawerItem({
    required this.titleText,
    this.icon,
    this.route,
    this.onTap,
  }) : assert(
          (route != null || onTap != null) && (route == null || onTap == null),
          'One parameter has to be null while the other one is not.',
        );

  final String? route;
  final Icon? icon;
  final String titleText;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap ?? () => GoRouter.of(context).goNamed(route!),
        leading: icon,
        title: Text(
          titleText,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
    );
  }
}
