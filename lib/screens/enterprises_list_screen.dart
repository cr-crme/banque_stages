import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/common/models/enterprise.dart';
import '/common/providers/enterprises_provider.dart';
import '/common/widgets/disponibility_circle.dart';
import '/dummy_data.dart';
import 'add_enterprise_screen.dart';
import 'enterprise/enterprise_screen.dart';

class EnterprisesListScreen extends StatefulWidget {
  const EnterprisesListScreen({Key? key}) : super(key: key);

  static const route = "/enterprises-list";

  @override
  State<EnterprisesListScreen> createState() => _EnterprisesListScreenState();
}

class _EnterprisesListScreenState extends State<EnterprisesListScreen> {
  bool _hideNotAvailable = true;

  final _searchController = TextEditingController();

  void _openEnterpriseScreen(Enterprise enterprise) {
    Navigator.pushNamed(context, EnterpriseScreen.route,
        arguments: enterprise.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Entreprises"),
        actions: [
          IconButton(
            onPressed: () =>
                Navigator.pushNamed(context, AddEnterpriseScreen.route),
            tooltip: "Ajouter une entreprise",
            icon: const Icon(Icons.add),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(72),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Card(
              elevation: 0,
              child: ListTile(
                leading: const Icon(Icons.search),
                title: TextField(
                  decoration: const InputDecoration(
                    hintText: "Rechercher",
                    border: InputBorder.none,
                  ),
                  controller: _searchController,
                  onChanged: (query) => setState(() {}),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => setState(() => _searchController.text = ""),
                ),
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          SwitchListTile(
            title: const Text("Cacher les stages indisponibles"),
            value: _hideNotAvailable,
            onChanged: (value) => setState(() => _hideNotAvailable = value),
          ),
          Expanded(
            child: Selector<EnterprisesProvider, List<Enterprise>>(
              builder: (context, enterprises, child) => ListView.builder(
                shrinkWrap: true,
                itemCount: enterprises.length,
                itemBuilder: (context, index) => EnterpriseListItem(
                  enterprise: enterprises.elementAt(index),
                  onTap: _openEnterpriseScreen,
                ),
              ),
              selector: (context, enterprises) => enterprises
                  .where(
                    (enterprise) => enterprise.name
                        .toLowerCase()
                        .startsWith(_searchController.text.toLowerCase()),
                  )
                  .toList(),
            ),
          ),
          Consumer<EnterprisesProvider>(
            builder: (context, enterprises, child) => Visibility(
              visible: enterprises.isEmpty,
              child: ElevatedButton(
                  onPressed: () => addDummyEnterprises(enterprises),
                  child: const Text("Add dummy enterprises")),
            ),
          ),
        ],
      ),
    );
  }
}

class EnterpriseListItem extends StatelessWidget {
  const EnterpriseListItem({
    Key? key,
    required this.enterprise,
    required this.onTap,
  }) : super(key: key);

  final Enterprise enterprise;
  final void Function(Enterprise enterprise) onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0.5,
      child: InkWell(
        onTap: () => onTap(enterprise),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 80,
                height: 60,
                color: Theme.of(context).disabledColor,
                child: enterprise.photo.isNotEmpty
                    ? Image.network(enterprise.photo)
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      enterprise.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(enterprise.address),
                    Column(
                      children: enterprise.jobs
                          .map((job) => Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Row(
                                  children: [
                                    DisponibilityCircle(
                                        availableSlots: job.totalSlot,
                                        occupiedSlots: job.occupiedSlot),
                                    const SizedBox(width: 8),
                                    Text(
                                      job.specialization.toString(),
                                    ),
                                  ],
                                ),
                              ))
                          .toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Icon(
                Icons.chevron_right,
                color: Theme.of(context).hintColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
