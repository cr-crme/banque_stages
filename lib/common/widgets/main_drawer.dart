import 'package:crcrme_banque_stages/common/widgets/numbered_tablet.dart';
import 'package:crcrme_banque_stages/dummy_data.dart';
import 'package:crcrme_banque_stages/initialize_program.dart';
import 'package:crcrme_banque_stages/router.dart';
import 'package:crcrme_banque_stages/screens/tasks_to_do/tasks_to_do_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Scaffold(
        appBar: AppBar(title: const Text('Banque de Stages')),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
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
                // _DrawerItem(
                //   titleText: 'Se déconnecter',
                //   icon: Icons.logout,
                //   onTap: () => auth.signOut(),
                // ),
              ],
            ),
            if (useDatabaseEmulator)
              _DrawerItem(
                titleText: 'Réinitialiser la base de données',
                icon: Icons.restore_from_trash_outlined,
                onTap: () async {
                  await resetDummyData(context);
                  if (context.mounted) Navigator.pop(context);
                },
                tileColor: Colors.red,
              ),
          ],
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
    this.tileColor,
  }) : assert(
          (route != null || onTap != null) && (route == null || onTap == null),
          'One parameter has to be null while the other one is not.',
        );

  final String? route;
  final IconData? icon;
  final String titleText;
  final void Function()? onTap;
  final Widget? trailing;
  final Color? tileColor;

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
            : tileColor,
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
