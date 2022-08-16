import 'package:crcrme_banque_stages/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/common/providers/auth_provider.dart';
import '/screens/enterprises_list_screen.dart';
import '/screens/login_screen.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, provider, _) => Drawer(
        child: Scaffold(
          appBar: AppBar(title: const Text("Banque de Stages")),
          body: SingleChildScrollView(
            child: Column(
              children: [
                const _DrawerItem(
                  titleText: "Accueil",
                  icon: Icon(Icons.home_rounded),
                  route: HomeScreen.route,
                ),
                const _DrawerItem(
                  titleText: "Mes élèves",
                  icon: Icon(Icons.school_rounded),
                  route: EnterprisesListScreen.route,
                ),
                const _DrawerItem(
                  titleText: "Toutes les entreprises",
                  icon: Icon(Icons.business_center_rounded),
                  route: EnterprisesListScreen.route,
                ),
                const _DrawerItem(
                  titleText: "Documents",
                  icon: Icon(Icons.document_scanner_rounded),
                  route: EnterprisesListScreen.route,
                ),
                const _DrawerItem(
                  titleText: "Tableau des supervisions",
                  icon: Icon(Icons.table_chart_rounded),
                  route: EnterprisesListScreen.route,
                ),
                const _DrawerItem(
                  titleText: "Référentiel SST",
                  icon: Icon(Icons.warning_rounded),
                  route: EnterprisesListScreen.route,
                ),
                provider.currentUser == null
                    ? const _DrawerItem(
                        titleText: "Se connecter",
                        icon: Icon(Icons.login),
                        route: LoginScreen.route,
                      )
                    : _DrawerItem(
                        titleText: "Se déconnecter",
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
    Key? key,
  }) : super(key: key);

  final String? route;
  final Icon? icon;
  final String titleText;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap ?? () => Navigator.popAndPushNamed(context, route ?? "/"),
        leading: icon,
        title: Text(
          titleText,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
    );
  }
}
