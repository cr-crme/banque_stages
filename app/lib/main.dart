import 'dart:async';

import 'package:common/services/backend_helpers.dart';
import 'package:common_flutter/widgets/sticky_head_expansion_panel_list.dart';
import 'package:common_flutter/providers/auth_provider.dart';
import 'package:common_flutter/providers/enterprises_provider.dart';
import 'package:common_flutter/providers/internships_provider.dart';
import 'package:common_flutter/providers/school_boards_provider.dart';
import 'package:common_flutter/providers/students_provider.dart';
import 'package:common_flutter/providers/teachers_provider.dart';
import 'package:crcrme_banque_stages/program_helpers.dart';
import 'package:crcrme_banque_stages/router.dart';
import 'package:crcrme_material_theme/crcrme_material_theme.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

// coverage:ignore-start
void main() async {
  BugReporter.loggerSetup();
  const showDebugElements = true;
  const useMockers = false;
  final backendUri = BackendHelpers.backendUri(isSecured: false, isDev: true);
  final errorReportUri =
      BackendHelpers.backendUriForBugReport(isSecured: false);

  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      await ProgramInitializer.initialize(
          showDebugElements: showDebugElements, mockMe: useMockers);

      runApp(BanqueStagesApp(useMockers: useMockers, backendUri: backendUri));
    },
    (error, stackTrace) =>
        BugReporter.report(error, stackTrace, errorReportUri: errorReportUri),
  );
}
// coverage:ignore-end

class BanqueStagesApp extends StatelessWidget {
  const BanqueStagesApp(
      {super.key, this.useMockers = false, required this.backendUri});

  final bool useMockers;
  final Uri backendUri;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ScrollableExpansionPanelExample(),
    );

    // MultiProvider(
    //   providers: [
    //     ChangeNotifierProvider(
    //         create: (context) => AuthProvider(mockMe: useMockers)),
    //     ChangeNotifierProxyProvider<AuthProvider, SchoolBoardsProvider>(
    //       create: (context) =>
    //           SchoolBoardsProvider(uri: backendUri, mockMe: useMockers),
    //       update: (context, auth, previous) => previous!..initializeAuth(auth),
    //     ),
    //     ChangeNotifierProxyProvider<AuthProvider, EnterprisesProvider>(
    //       create: (context) =>
    //           EnterprisesProvider(uri: backendUri, mockMe: useMockers),
    //       update: (context, auth, previous) => previous!..initializeAuth(auth),
    //     ),
    //     ChangeNotifierProxyProvider<AuthProvider, InternshipsProvider>(
    //       create: (context) =>
    //           InternshipsProvider(uri: backendUri, mockMe: useMockers),
    //       update: (context, auth, previous) => previous!..initializeAuth(auth),
    //     ),
    //     ChangeNotifierProxyProvider<AuthProvider, TeachersProvider>(
    //       create: (context) =>
    //           TeachersProvider(uri: backendUri, mockMe: useMockers),
    //       update: (context, auth, previous) => previous!..initializeAuth(auth),
    //     ),
    //     ChangeNotifierProxyProvider<AuthProvider, StudentsProvider>(
    //       create: (context) =>
    //           StudentsProvider(uri: backendUri, mockMe: useMockers),
    //       update: (context, auth, previous) => previous!..initializeAuth(auth),
    //     ),
    //   ],
    //   child: MaterialApp.router(
    //     onGenerateTitle: (context) => 'Banque de stages',
    //     theme: crcrmeMaterialTheme,
    //     routerConfig: router,
    //     localizationsDelegates: const [
    //       GlobalMaterialLocalizations.delegate,
    //       GlobalWidgetsLocalizations.delegate,
    //       GlobalCupertinoLocalizations.delegate,
    //     ],
    //     supportedLocales: const [
    //       Locale('fr', 'CA'),
    //     ],
    //   ),
    // );
  }
}

class ScrollableExpansionPanelExample extends StatefulWidget {
  const ScrollableExpansionPanelExample({super.key});

  @override
  State<ScrollableExpansionPanelExample> createState() =>
      _ScrollableExpansionPanelExampleState();
}

class _ScrollableExpansionPanelExampleState
    extends State<ScrollableExpansionPanelExample> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    final ScrollController outerScrollController = ScrollController();

    return Scaffold(
      appBar: AppBar(title: Text('Sticky Header ExpansionPanel')),
      body: SingleChildScrollView(
        controller: outerScrollController,
        child: Column(
          children: [
            SizedBox(
              height: 100,
              child: Text('coucou'),
            ),
            SizedBox(
              height: 100,
              child: Text('coucou'),
            ),
            SizedBox(
              height: 100,
              child: Text('coucou'),
            ),
            SizedBox(
              height: 100,
              child: Text('coucou'),
            ),
            SizedBox(
              height: 100,
              child: Text('coucou'),
            ),
            SizedBox(
              height: 100,
              child: Text('coucou'),
            ),
            SizedBox(
              height: 100,
              child: Text('coucou'),
            ),
            SizedBox(
              height: 100,
              child: Text('coucou'),
            ),
            SizedBox(
              height: 100,
              child: Text('coucou'),
            ),
            SizedBox(
              height: 100,
              child: Text('coucou'),
            ),
            SizedBox(
              height: 100,
              child: Text('coucou'),
            ),
            StickyHeadExpansionPanelList(
              outerScrollController: outerScrollController,
              headerStickyTarget: 100,
              headerHeight: 50,
              expansionCallback: (int index, bool isExpanded) {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              children: [
                StickyHeadExpansionPanel(
                    headerBuilder: (context, headerKey, isExpanded) {
                      return ListTile(
                        key: headerKey,
                        title: const Text('Tap to expand'),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: List.generate(
                          50,
                          (index) => ListTile(title: Text('Item $index')),
                        ),
                      ),
                    ),
                    isExpanded: _isExpanded),
              ],
            ),
            SizedBox(
              height: 100,
              child: Text('coucou'),
            ),
            SizedBox(
              height: 100,
              child: Text('coucou'),
            ),
            SizedBox(
              height: 100,
              child: Text('coucou'),
            ),
            SizedBox(
              height: 100,
              child: Text('coucou'),
            ),
            SizedBox(
              height: 100,
              child: Text('coucou'),
            ),
            SizedBox(
              height: 100,
              child: Text('coucou'),
            ),
            SizedBox(
              height: 100,
              child: Text('coucou'),
            ),
            SizedBox(
              height: 100,
              child: Text('coucou'),
            ),
            SizedBox(
              height: 100,
              child: Text('coucou'),
            ),
            SizedBox(
              height: 100,
              child: Text('coucou'),
            ),
            SizedBox(
              height: 100,
              child: Text('coucou'),
            ),
            SizedBox(
              height: 100,
              child: Text('coucou'),
            ),
            SizedBox(
              height: 100,
              child: Text('coucou'),
            ),
            SizedBox(
              height: 100,
              child: Text('coucou'),
            ),
            SizedBox(
              height: 100,
              child: Text('coucou'),
            ),
            SizedBox(
              height: 100,
              child: Text('coucou'),
            ),
            SizedBox(
              height: 100,
              child: Text('coucou'),
            ),
            SizedBox(
              height: 100,
              child: Text('coucou'),
            ),
            SizedBox(
              height: 100,
              child: Text('coucou'),
            ),
            SizedBox(
              height: 100,
              child: Text('coucou'),
            ),
            SizedBox(
              height: 100,
              child: Text('coucou'),
            ),
          ],
        ),
      ),
    );
  }
}
