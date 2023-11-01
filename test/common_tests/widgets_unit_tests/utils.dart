import 'package:crcrme_material_theme/crcrme_material_theme.dart';
import 'package:flutter/material.dart';

///
/// [loadTheme] will use the CR-CRME theme. This however connects to GoogleFonts
/// which is incompatible with true async tests.
Widget declareWidget(Widget child, {bool loadTheme = false}) {
  return MaterialApp(
    home: Scaffold(
      body: child,
    ),
    theme: loadTheme ? crcrmeMaterialTheme : null,
  );
}
