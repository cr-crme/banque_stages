import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/common/models/enterprise.dart';
import '/common/providers/enterprises_provider.dart';

class EnterpriseDetails extends StatefulWidget {
  const EnterpriseDetails({Key? key}) : super(key: key);

  static String route = "/enterprises/enterprise";

  @override
  State<EnterpriseDetails> createState() => _EnterpriseDetailsState();
}

class _EnterpriseDetailsState extends State<EnterpriseDetails> {
  late int enterpriseIndex = ModalRoute.of(context)!.settings.arguments as int;

  void modifyEnterprise(Enterprise newEnterprise) {
    context.read<EnterprisesProvider>()[enterpriseIndex] = newEnterprise;
  }

  @override
  Widget build(BuildContext context) {
    return Selector<EnterprisesProvider, Enterprise>(
        builder: (context, enterprise, child) => Scaffold(
              appBar: AppBar(
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),
                title: Text(enterprise.name),
              ),
              body: ElevatedButton(
                child: const Text("modify"),
                onPressed: () => modifyEnterprise(
                    enterprise.copyWith(name: "${enterprise.name} a")),
              ),
            ),
        selector: (context, enterprises) =>
            enterprises.enterprises[enterpriseIndex]);
  }
}
