import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'screens/main_shell.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(
    // ProviderScope = racine obligatoire pour que Riverpod fonctionne.
    // Tous les providers de l'app vivent dans cet arbre.
    const ProviderScope(child: MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'E-commerce Riverpod',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const MainShell(),
    );
  }
}