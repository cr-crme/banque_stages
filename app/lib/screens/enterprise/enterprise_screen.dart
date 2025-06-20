import 'package:common/models/enterprises/enterprise.dart';
import 'package:common_flutter/helpers/responsive_service.dart';
import 'package:common_flutter/providers/auth_provider.dart';
import 'package:common_flutter/providers/enterprises_provider.dart';
import 'package:common_flutter/widgets/show_snackbar.dart';
import 'package:crcrme_banque_stages/common/extensions/enterprise_extension.dart';
import 'package:crcrme_banque_stages/common/extensions/job_extension.dart';
import 'package:crcrme_banque_stages/common/widgets/dialogs/confirm_exit_dialog.dart';
import 'package:crcrme_banque_stages/common/widgets/main_drawer.dart';
import 'package:crcrme_banque_stages/screens/internship_enrollment/internship_enrollment_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'pages/about_page.dart';
import 'pages/contact_page.dart';
import 'pages/internships_page.dart';
import 'pages/jobs_page.dart';

class EnterpriseScreen extends StatefulWidget {
  const EnterpriseScreen(
      {super.key, required this.id, required this.pageIndex});

  static const route = '/enterprise';

  final String id;
  final int pageIndex;

  @override
  State<EnterpriseScreen> createState() => _EnterpriseScreenState();
}

class _EnterpriseScreenState extends State<EnterpriseScreen>
    with SingleTickerProviderStateMixin {
  late final _tabController =
      TabController(initialIndex: widget.pageIndex, length: 4, vsync: this);

  late IconButton _actionButton;

  final _aboutPageKey = GlobalKey<EnterpriseAboutPageState>();
  final _contactPageKey = GlobalKey<ContactPageState>();
  final _jobsPageKey = GlobalKey<JobsPageState>();
  final _stagePageKey = GlobalKey<InternshipsPageState>();

  bool get _editing =>
      (_aboutPageKey.currentState?.editing ?? false) ||
      (_contactPageKey.currentState?.editing ?? false) ||
      (_jobsPageKey.currentState?.isEditing ?? false);

  void cancelEditing() {
    if (_aboutPageKey.currentState?.editing != null) {
      _aboutPageKey.currentState!.toggleEdit(save: false);
    }
    if (_contactPageKey.currentState?.editing != null) {
      _contactPageKey.currentState!.toggleEdit(save: false);
    }
    if (_jobsPageKey.currentState?.isEditing != null) {
      _jobsPageKey.currentState!.cancelEditing();
    }
    setState(() {});
  }

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
    _actionButton = IconButton(
      icon: icon,
      onPressed: () async {
        if (_tabController.index == 0) {
          _aboutPageKey.currentState?.toggleEdit();
        } else if (_tabController.index == 1) {
          await _contactPageKey.currentState?.toggleEdit();
        } else if (_tabController.index == 2) {
          if (_jobsPageKey.currentState!.isEditing) {
            if (!await ConfirmExitDialog.show(context,
                content: Text.rich(TextSpan(children: [
                  const TextSpan(
                      text: '** Vous quittez la page sans avoir '
                          'cliqué sur Enregistrer '),
                  WidgetSpan(
                      child: SizedBox(
                    height: 22,
                    width: 22,
                    child: Icon(
                      Icons.save,
                      color: Theme.of(context).primaryColor,
                    ),
                  )),
                  const TextSpan(
                    text: '. **\n\nToutes vos modifications seront perdues.',
                  ),
                ])))) {
              return;
            }
            cancelEditing();
          }
          await _jobsPageKey.currentState?.addJob();
        } else if (_tabController.index == 3) {
          await _stagePageKey.currentState?.addStage();
        }

        _updateActionButton();
      },
    );
    setState(() {});
  }

  Future<void> addInternship(Enterprise enterprise) async {
    final schoolId = Provider.of<AuthProvider>(context, listen: false).schoolId;
    if (schoolId == null) {
      showSnackBar(context, message: 'Vous n\'êtes pas connecté à une école');
      return;
    }

    if (enterprise.availablejobs(context).fold<int>(
            0,
            (prev, e) =>
                prev + e.positionsRemaining(context, schoolId: schoolId)) ==
        0) {
      await showDialog(
        context: context,
        builder: (ctx) => const AlertDialog(
          title: Text('Plus de stage disponible'),
          content:
              Text('Il n\'y a plus de stage disponible dans cette entreprise'),
        ),
      );
      return;
    }

    await showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) => Dialog(
            child: InternshipEnrollmentScreen(enterpriseId: enterprise.id)));
  }

  @override
  void initState() {
    super.initState();
    _updateActionButton();
    _tabController.addListener(() => _updateActionButton());
  }

  @override
  Widget build(BuildContext context) {
    return Selector<EnterprisesProvider, Enterprise?>(
      builder: (context, enterprise, _) {
        if (enterprise == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return ResponsiveService.scaffoldOf(
          context,
          smallDrawer: null,
          mediumDrawer: MainDrawer.medium,
          largeDrawer: MainDrawer.large,
          appBar: ResponsiveService.appBarOf(
            context,
            title: Text(enterprise.name),
            actions: [_actionButton],
            leading:
                ResponsiveService.getScreenSize(context) == ScreenSize.small
                    ? null
                    : SizedBox.shrink(),
            bottom: TabBar(
              onTap: (index) async {
                if (!_editing || !_tabController.indexIsChanging) return;

                _tabController.index = _tabController.previousIndex;
                if (await ConfirmExitDialog.show(context,
                    content: Text.rich(TextSpan(children: [
                      const TextSpan(
                          text: '** Vous quittez la page sans avoir '
                              'cliqué sur Enregistrer '),
                      WidgetSpan(
                          child: SizedBox(
                        height: 22,
                        width: 22,
                        child: Icon(
                          Icons.save,
                          color: Theme.of(context).primaryColor,
                        ),
                      )),
                      const TextSpan(
                        text:
                            '. **\n\nToutes vos modifications seront perdues.',
                      ),
                    ])))) {
                  cancelEditing();
                  _tabController.animateTo(index);
                }
              },
              controller: _tabController,
              tabs: const [
                Tab(icon: Icon(Icons.info_outlined), text: 'À propos'),
                Tab(icon: Icon(Icons.contact_phone), text: 'Contact'),
                Tab(icon: Icon(Icons.business_center_rounded), text: 'Postes'),
                Tab(icon: Icon(Icons.assignment), text: 'Stages'),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            physics: _editing ? const NeverScrollableScrollPhysics() : null,
            children: [
              EnterpriseAboutPage(
                key: _aboutPageKey,
                enterprise: enterprise,
                onAddInternshipRequest: addInternship,
              ),
              ContactPage(key: _contactPageKey, enterprise: enterprise),
              JobsPage(key: _jobsPageKey, enterprise: enterprise),
              InternshipsPage(
                key: _stagePageKey,
                enterprise: enterprise,
                onAddInternshipRequest: addInternship,
              ),
            ],
          ),
        );
      },
      selector: (context, enterprises) => enterprises.fromIdOrNull(widget.id),
    );
  }
}
