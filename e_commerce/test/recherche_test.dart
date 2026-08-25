import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ecommerce_app/screens/catalog_screen.dart';
import 'package:ecommerce_app/widgets/filter_bar.dart';
void main() {
  testWidgets('CatalogScreen affiche la FilterBar et les produits mockés',
      (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: CatalogScreen()),
      ),
    );

    // La barre de filtres/recherche est présente dès le premier rendu.
    expect(find.byType(FilterBar), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget); // champ de recherche

    // Laisse le catalogue (FutureProvider) se charger.
    await tester.pumpAndSettle();

    // Au moins un produit mocké doit être affiché.
    expect(find.textContaining('FCFA'), findsWidgets);
  });

  testWidgets('taper dans la recherche filtre la liste affichée', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: CatalogScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'zzzzz_inexistant');
    await tester.pumpAndSettle();

    expect(find.text('Aucun produit ne correspond.'), findsOneWidget);
  });
}