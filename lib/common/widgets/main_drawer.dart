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
          appBar: AppBar(title: const Text("Menu principal")),
          body: SingleChildScrollView(
            child: Column(
              children: [
                const _DrawerItem(
                  titleText: "Toutes les entreprises",
                  icon: Icon(Icons.business_center),
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
