import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ecommerce_app/providers/favorites_provider.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    container = ProviderContainer();
  });

  tearDown(() => container.dispose());

  test('aucun favori au démarrage', () async {
    // Laisse le temps au chargement asynchrone depuis SharedPreferences.
    await Future<void>.delayed(Duration.zero);
    expect(container.read(favoritesProvider), isEmpty);
  });

  test('toggle ajoute puis retire un produit des favoris', () async {
    await Future<void>.delayed(Duration.zero);
    final notifier = container.read(favoritesProvider.notifier);

    notifier.toggle('p1');
    expect(container.read(favoritesProvider), contains('p1'));

    notifier.toggle('p1');
    expect(container.read(favoritesProvider), isNot(contains('p1')));
  });

  test('les favoris persistent entre deux instances du notifier', () async {
    await Future<void>.delayed(Duration.zero);
    container.read(favoritesProvider.notifier).toggle('p1');

    // Laisse le temps à la sauvegarde asynchrone de s'exécuter.
    await Future<void>.delayed(Duration.zero);

    // Nouvelle instance : simule un redémarrage de l'app.
    final freshContainer = ProviderContainer();
    await Future<void>.delayed(Duration.zero);

    expect(freshContainer.read(favoritesProvider), contains('p1'));
    freshContainer.dispose();
  });

  test('isFavoriteProvider reflète correctement l\'état d\'un produit', () async {
    await Future<void>.delayed(Duration.zero);
    container.read(favoritesProvider.notifier).toggle('p1');

    expect(container.read(isFavoriteProvider('p1')), isTrue);
    expect(container.read(isFavoriteProvider('p2')), isFalse);
  });
}