import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ecommerce_app/screens/profile_screen.dart';

void main() {
  testWidgets('ProfileScreen affiche le nom et l\'email de l\'utilisateur mocké',
      (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: ProfileScreen()),
      ),
    );

    // État initial : chargement (AsyncValue.loading).
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Laisse le FutureProvider (userProvider) se résoudre.
    await tester.pumpAndSettle();

    expect(find.text('Abdoul Traoré'), findsOneWidget);
    expect(find.text('abdoul.traore@example.com'), findsOneWidget);
    expect(find.text('Produits favoris'), findsOneWidget);
  });
}