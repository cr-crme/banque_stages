import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/common/models/enterprise.dart';
import '/common/providers/enterprises_provider.dart';
import 'widgets/about_page.dart';
import 'widgets/contact_page.dart';
import 'widgets/jobs_page.dart';
import 'widgets/stage_page.dart';

class EnterpriseDetails extends StatefulWidget {
  const EnterpriseDetails({Key? key}) : super(key: key);

  static const String route = "/enterprise-details";

  @override
  State<EnterpriseDetails> createState() => _EnterpriseDetailsState();
}

class _EnterpriseDetailsState extends State<EnterpriseDetails>
    with SingleTickerProviderStateMixin {
  late final _enterpriseId =
      ModalRoute.of(context)!.settings.arguments as String;

  late final TabController _tabController;
  IconButton? _actionButton;

  final _aboutPageKey = GlobalKey<AboutPageState>();
  final _contactPageKey = GlobalKey<ContactPageState>();
  final _jobsPageKey = GlobalKey<JobsPageState>();
  final _stagePageKey = GlobalKey<StagePageState>();

  void _updateActionButton() {
    late void Function()? onPressed;
    late Icon? icon;

    switch (_tabController.index) {
      case 0:
        onPressed = _aboutPageKey.currentState?.actionButtonOnPressed;
        icon = _aboutPageKey.currentState?.actionButtonIcon;
        break;
      case 1:
        onPressed = _contactPageKey.currentState?.actionButtonOnPressed;
        icon = _contactPageKey.currentState?.actionButtonIcon;
        break;
      case 2:
        onPressed = _jobsPageKey.currentState?.actionButtonOnPressed;
        icon = _jobsPageKey.currentState?.actionButtonIcon;
        break;
      case 3:
        onPressed = _stagePageKey.currentState?.actionButtonOnPressed;
        icon = _stagePageKey.currentState?.actionButtonIcon;
        break;
    }

    setState(() {
      if (onPressed == null || icon == null) {
        _actionButton = null;
      } else {
        _actionButton = IconButton(
          onPressed: () {
            onPressed!();
            _updateActionButton();
          },
          icon: icon,
        );
      }
    });
  }

  @override
  void initState() {
    super.initState();

    _tabController = TabController(initialIndex: 3, length: 4, vsync: this);
    _tabController.addListener(() => _updateActionButton());

    // This line makes sure that [_updateActionButton] is called while the pages are initialised
    _tabController.animateTo(0, duration: const Duration(microseconds: 1));
  }

  @override
  Widget build(BuildContext context) {
    return Selector<EnterprisesProvider, Enterprise>(
      builder: (context, enterprise, _) => Scaffold(
        appBar: AppBar(
          title: Text(enterprise.name),
          actions: [_actionButton ?? const SizedBox.square(dimension: 56)],
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(icon: Icon(Icons.info_outline), text: "À propos"),
              Tab(icon: Icon(Icons.person), text: "Contact"),
              Tab(icon: Icon(Icons.location_city_rounded), text: "Métiers"),
              Tab(
                icon: Icon(Icons.notes_rounded),
                text: "Stages",
              ),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
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
