import 'package:crcrme_banque_stages/dummy_data.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '/router.dart';

class GenerateDebugDataScreen extends StatelessWidget {
  const GenerateDebugDataScreen({super.key});

  Future<bool> _populateWithDebugData(context) async {
    try {
      // Wait for the data to arrive if needed
      await Future.delayed(const Duration(seconds: 1));
      if (!hasDummyData(context)) {
        await addAllDummyData(context);
      }
    } catch (e) {
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<bool>(
          future: _populateWithDebugData(context),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child:
                    Text('Svp, attendre pendant que les données sont générées'),
              );
            }
            if (!snapshot.data!) {
              return const Center(
                child:
                    Text('Un problème est survenu lors de la génération des\n'
                        'données, svp redémarrer le serveur'),
              );
            }

            Future.microtask(() => GoRouter.of(context).goNamed(Screens.home));
            return const Center(
              child: Text(
                  'Données chargées, nous vous redirigeons vers le programme'),
            );
          }),
    );
  }
}
