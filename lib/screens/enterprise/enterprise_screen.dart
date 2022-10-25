import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/common/models/enterprise.dart';
import '/common/providers/enterprises_provider.dart';
import '/common/widgets/dialogs/confirm_pop_dialog.dart';
import 'pages/about_page.dart';
import 'pages/contact_page.dart';
import 'pages/jobs_page.dart';
import 'pages/stage_page.dart';

class EnterpriseScreen extends StatefulWidget {
  const EnterpriseScreen({super.key});

  static const String route = "/enterprise-details";

  @override
  State<EnterpriseScreen> createState() => _EnterpriseScreenState();
}

class _EnterpriseScreenState extends State<EnterpriseScreen>
    with SingleTickerProviderStateMixin {
  late final _enterpriseId =
      ModalRoute.of(context)!.settings.arguments as String;

  late final _tabController =
      TabController(initialIndex: 0, length: 4, vsync: this);

  late IconButton _actionButton;

  final _aboutPageKey = GlobalKey<AboutPageState>();
  final _contactPageKey = GlobalKey<ContactPageState>();
  final _jobsPageKey = GlobalKey<JobsPageState>();
  final _stagePageKey = GlobalKey<StagePageState>();

  bool get _editing =>
      (_aboutPageKey.currentState?.editing ?? false) ||
      (_contactPageKey.currentState?.editing ?? false);

  void _updateActionButton() {
    late Icon icon;

    if (_tabController.index == 0) {
      icon = _aboutPageKey.currentState?.editing ?? false
          ? const Icon(Icons.save)
          : const Icon(Icons.edit);
    } else if (_tabController.index == 1) {
      icon = _contactPageKey.currentState?.editing ?? false
          ? const Icon(Icons.save)
          : const Icon(Icons.edit);
    } else if (_tabController.index == 2) {
      icon = const Icon(Icons.add);
    } else if (_tabController.index == 3) {
      icon = const Icon(Icons.add);
    }

    setState(() {
      _actionButton = IconButton(
        icon: icon,
        onPressed: () {
          if (_tabController.index == 0) {
            _aboutPageKey.currentState?.toggleEdit();
          } else if (_tabController.index == 1) {
            _contactPageKey.currentState?.toggleEdit();
          } else if (_tabController.index == 2) {
            _jobsPageKey.currentState?.addJob();
          } else if (_tabController.index == 3) {
            _stagePageKey.currentState?.addStage();
          }

          _updateActionButton();
        },
      );
    });
  }

  @override
  void initState() {
    super.initState();
    _updateActionButton();
    _tabController.addListener(() => _updateActionButton());
  }

  @override
  Widget build(BuildContext context) {
    return Selector<EnterprisesProvider, Enterprise>(
      builder: (context, enterprise, _) => Scaffold(
        appBar: AppBar(
          title: Text(enterprise.name),
          actions: [_actionButton],
          bottom: TabBar(
            onTap: (index) async {
              if (!_editing || !_tabController.indexIsChanging) return;

              _tabController.index = _tabController.previousIndex;
              if (await showDialog(
                  context: context,
                  builder: (context) => const ConfirmPopDialog())) {
                _tabController.animateTo(index);
              }
            },
            controller: _tabController,
            tabs: const [
              Tab(icon: Icon(Icons.info_outlined), text: "À propos"),
              Tab(icon: Icon(Icons.person), text: "Contact"),
              Tab(icon: Icon(Icons.handyman), text: "Métiers"),
              Tab(icon: Icon(Icons.assignment), text: "Stages"),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          physics: _editing ? const NeverScrollableScrollPhysics() : null,
          children: [
            AboutPage(key: _aboutPageKey, enterprise: enterprise),
            ContactPage(key: _contactPageKey, enterprise: enterprise),
            JobsPage(key: _jobsPageKey, enterprise: enterprise),
            StagePage(key: _stagePageKey, enterprise: enterprise),
          ],
        ),
      ),
      selector: (context, enterprises) => enterprises[_enterpriseId],
    );
  }
}
