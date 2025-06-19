import 'package:common_flutter/providers/auth_provider.dart';
import 'package:common_flutter/providers/enterprises_provider.dart';
import 'package:common_flutter/providers/internships_provider.dart';
import 'package:common_flutter/providers/school_boards_provider.dart';
import 'package:common_flutter/providers/students_provider.dart';
import 'package:common_flutter/providers/teachers_provider.dart';
import 'package:crcrme_banque_stages/common/widgets/numbered_tablet.dart';
import 'package:crcrme_banque_stages/router.dart';
import 'package:crcrme_banque_stages/screens/tasks_to_do/tasks_to_do_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer(
      {super.key,
      this.iconOnly = false,
      this.showTitle = true,
      this.canPop = true});

  static MainDrawer get small => const MainDrawer();
  static MainDrawer get medium =>
      const MainDrawer(iconOnly: true, showTitle: false, canPop: false);
  static MainDrawer get large =>
      const MainDrawer(showTitle: false, canPop: false);

  final bool showTitle;
  final bool iconOnly;
  final bool canPop;

  void _logOut(BuildContext context) async {
    await AuthProvider.of(context).signOut();
    if (!context.mounted) return;

    await SchoolBoardsProvider.of(context, listen: false).disconnect();
    if (!context.mounted) return;
    InternshipsProvider.of(context, listen: false).disconnect();
    if (!context.mounted) return;
    await Future.wait([
      SchoolBoardsProvider.of(context, listen: false).disconnect(),
      InternshipsProvider.of(context, listen: false).disconnect(),
      StudentsProvider.of(context, listen: false).disconnect(),
      EnterprisesProvider.of(context, listen: false).disconnect(),
      TeachersProvider.of(context, listen: false).disconnect(),
    ]);
    if (!context.mounted) return;

    // Pop the drawer and navigate to the login screen
    if (canPop) Navigator.pop(context);
    GoRouter.of(context).goNamed(Screens.login);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = AuthProvider.of(context, listen: false);

    return Drawer(
      width: iconOnly ? 100.0 : null,
      child: Scaffold(
        appBar:
            showTitle ? AppBar(title: const Text('Banque de Stages')) : null,
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (authProvider.isFullySignedIn)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _DrawerItem(
                          titleText: 'Mes élèves',
                          icon: Icons.school_rounded,
                          route: Screens.studentsList,
                          iconOnly: iconOnly,
                          canPop: canPop,
                        ),
                        _DrawerItem(
                          titleText: 'Tableau des supervisions',
                          icon: Icons.table_chart_rounded,
                          route: Screens.supervisionChart,
                          iconOnly: iconOnly,
                          canPop: canPop,
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
                          iconOnly: iconOnly,
                          canPop: canPop,
                        ),
                        _DrawerItem(
                          titleText: 'Entreprises',
                          icon: Icons.location_city_rounded,
                          route: Screens.enterprisesList,
                          iconOnly: iconOnly,
                          canPop: canPop,
                        ),
                        _DrawerItem(
                          titleText: 'Santé et Sécurité au PFAE',
                          icon: Icons.security,
                          route: Screens.homeSst,
                          iconOnly: iconOnly,
                          canPop: canPop,
                        ),
                        // _DrawerItem(
                        //   titleText: 'Documents',
                        //   icon: const Icon(Icons.document_scanner_rounded),
                        //   route: Screens...,
                        //   onTap: () {},
                        //   iconOnly: iconOnly,
                        //   canPop: canPop,
                        // ),
                      ],
                    ),
                  if (authProvider.isAuthenticatorSignedIn)
                    _DrawerItem(
                      titleText: 'Se déconnecter',
                      icon: Icons.logout,
                      onTap: () => _logOut(context),
                      iconOnly: iconOnly,
                      canPop: canPop,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  const _DrawerItem({
    required this.titleText,
    required this.icon,
    this.route,
    this.onTap,
    this.trailing,
    required this.iconOnly,
    required this.canPop,
  }) : assert(
          (route != null || onTap != null) && (route == null || onTap == null),
          'One parameter has to be null while the other one is not.',
        );

  final String? route;
  final IconData icon;
  final String titleText;
  final void Function()? onTap;
  final Widget? trailing;
  final bool iconOnly;
  final bool canPop;

  @override
  Widget build(BuildContext context) {
    final isCurrentlySelectedTile =
        ModalRoute.of(context)!.settings.name == route;

    final onPressed = onTap ??
        () {
          if (isCurrentlySelectedTile && canPop) Navigator.pop(context);
          GoRouter.of(context).goNamed(route!);
        };

    final leadingIcon = Icon(
      icon,
      color: isCurrentlySelectedTile
          ? Theme.of(context).primaryColor
          : Colors.black54,
    );

    return Card(
      child: Container(
        decoration: BoxDecoration(
          color: isCurrentlySelectedTile
              ? Theme.of(context).primaryColor.withAlpha(40)
              : null,
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: iconOnly
            ? IconButton(
                onPressed: onPressed,
                icon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 4.0, right: 4.0, bottom: 4.0, left: 6.0),
                      child: leadingIcon,
                    ),
                    trailing ?? const SizedBox.shrink(),
                  ],
                ))
            : ListTile(
                onTap: onPressed,
                leading: leadingIcon,
                title: Text(
                  titleText,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                trailing: trailing,
              ),
      ),
    );
  }
}
