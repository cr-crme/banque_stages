import 'package:crcrme_banque_stages/common/providers/auth_provider.dart';
import 'package:crcrme_banque_stages/common/widgets/numbered_tablet.dart';
import 'package:crcrme_banque_stages/router.dart';
import 'package:crcrme_banque_stages/screens/tasks_to_do/tasks_to_do_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

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
                  titleText: 'Mes élèves',
                  icon: Icons.school_rounded,
                  route: Screens.studentsList,
                ),
                const _DrawerItem(
                  titleText: 'Tableau des supervisions',
                  icon: Icons.table_chart_rounded,
                  route: Screens.supervisionChart,
                ),
                _DrawerItem(
                  titleText: 'Tâches à réaliser',
                  icon: Icons.checklist,
                  route: Screens.tasksToDo,
                  trailing: NumberedTablet(
                    number: numberOfTasksToDo(context),
                    hideIfEmpty: true,
                    color: const Color.fromARGB(255, 33, 86, 176),
                  ),
                ),
                const _DrawerItem(
                  titleText: 'Entreprises',
                  icon: Icons.location_city_rounded,
                  route: Screens.enterprisesList,
                ),
                const _DrawerItem(
                  titleText: 'Santé et Sécurité au PFAE',
                  icon: Icons.security,
                  route: Screens.homeSst,
                ),
                // _DrawerItem(
                //   titleText: 'Documents',
                //   icon: const Icon(Icons.document_scanner_rounded),
                //   route: Screens...,
                //   onTap: () {},
                // ),
                _DrawerItem(
                  titleText: 'Se déconnecter',
                  icon: Icons.logout,
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
    this.trailing,
  }) : assert(
          (route != null || onTap != null) && (route == null || onTap == null),
          'One parameter has to be null while the other one is not.',
        );

  final String? route;
  final IconData? icon;
  final String titleText;
  final void Function()? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final isCurrentlySelectedTile =
        ModalRoute.of(context)!.settings.name == route;
    return Card(
      child: ListTile(
        onTap: onTap ??
            () {
              if (isCurrentlySelectedTile) Navigator.pop(context);
              GoRouter.of(context).goNamed(route!);
            },
        tileColor: isCurrentlySelectedTile
            ? Theme.of(context).primaryColor.withAlpha(40)
            : null,
        leading: icon == null
            ? null
            : Icon(
                icon,
                color: isCurrentlySelectedTile
                    ? Theme.of(context).primaryColor
                    : null,
              ),
        title: Text(
          titleText,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        trailing: trailing,
      ),
    );
  }
}
