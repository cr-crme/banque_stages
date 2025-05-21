import 'package:admin_app/dummy_data.dart';
import 'package:admin_app/providers/auth_provider.dart';
import 'package:admin_app/screens/router.dart';
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
                  titleText: 'Écoles',
                  icon: Icons.school_rounded,
                  route: Screens.schoolsListScreen,
                ),
                const _DrawerItem(
                  titleText: 'Enseignant·e·s',
                  icon: Icons.school_rounded,
                  route: Screens.teachersListScreen,
                ),
                _DrawerItem(
                  titleText: 'Se déconnecter',
                  icon: Icons.logout,
                  onTap: () {
                    AuthProvider.of(context).signOut();
                    GoRouter.of(context).goNamed(Screens.login);
                  },
                ),
              ],
            ),
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
    this.tileColor,
  }) : assert(
         (route != null || onTap != null) && (route == null || onTap == null),
         'One parameter has to be null while the other one is not.',
       );

  final String? route;
  final IconData? icon;
  final String titleText;
  final void Function()? onTap;
  final Color? tileColor;

  @override
  Widget build(BuildContext context) {
    final isCurrentlySelectedTile =
        ModalRoute.of(context)!.settings.name == route;
    return Card(
      child: ListTile(
        onTap:
            onTap ??
            () {
              if (isCurrentlySelectedTile) Navigator.pop(context);
              GoRouter.of(context).goNamed(route!);
            },
        tileColor:
            isCurrentlySelectedTile
                ? Theme.of(context).primaryColor.withAlpha(40)
                : tileColor,
        leading:
            icon == null
                ? null
                : Icon(
                  icon,
                  color:
                      isCurrentlySelectedTile
                          ? Theme.of(context).primaryColor
                          : null,
                ),
        title: Text(titleText, style: Theme.of(context).textTheme.titleMedium),
      ),
    );
  }
}
