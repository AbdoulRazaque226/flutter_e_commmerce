import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ecommerce_app/models/product.dart';
import 'package:ecommerce_app/providers/product_providers.dart';

void main() {
  final testProducts = [
    const Product(
      id: 'a',
      name: 'Banane',
      description: '',
      price: 500,
      imageUrl: '',
      category: 'Fruits',
      rating: 3.0,
      stock: 10,
    ),
    const Product(
      id: 'b',
      name: 'Ananas',
      description: '',
      price: 1500,
      imageUrl: '',
      category: 'Fruits',
      rating: 4.5,
      stock: 5,
    ),
    const Product(
      id: 'c',
      name: 'Casque audio',
      description: '',
      price: 30000,
      imageUrl: '',
      category: 'Électronique',
      rating: 4.0,
      stock: 2,
    ),
  ];

  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer(
      overrides: [
        productsProvider.overrideWith((ref) async => testProducts),
      ],
    );
  });

  tearDown(() => container.dispose());

  test('sans filtre, tous les produits sont retournés', () async {
    // Attend la résolution du FutureProvider.
    await container.read(productsProvider.future);
    final result = container.read(filteredProductsProvider);

    expect(result.value?.length, 3);
  });

  test('le filtre par catégorie ne garde que les produits correspondants', () async {
    await container.read(productsProvider.future);
    container.read(filterProvider.notifier).setCategory('Fruits');

    final result = container.read(filteredProductsProvider);
    expect(result.value?.length, 2);
    expect(result.value!.every((p) => p.category == 'Fruits'), isTrue);
  });

  test('la recherche filtre par nom (insensible à la casse)', () async {
    await container.read(productsProvider.future);
    container.read(filterProvider.notifier).setSearchQuery('cas');

    final result = container.read(filteredProductsProvider);
    expect(result.value?.length, 1);
    expect(result.value!.first.name, 'Casque audio');
  });

  test('le tri par prix croissant trie correctement', () async {
    await container.read(productsProvider.future);
    container.read(filterProvider.notifier).setSortOption(SortOption.priceAsc);

    final result = container.read(filteredProductsProvider);
    final prices = result.value!.map((p) => p.price).toList();
    expect(prices, [500, 1500, 30000]);
  });

  test('le tri par note décroissante trie correctement', () async {
    await container.read(productsProvider.future);
    container.read(filterProvider.notifier).setSortOption(SortOption.ratingDesc);

    final result = container.read(filteredProductsProvider);
    final ratings = result.value!.map((p) => p.rating).toList();
    expect(ratings, [4.5, 4.0, 3.0]);
  });

  test('reset() remet le filtre à son état par défaut', () async {
    await container.read(productsProvider.future);
    final notifier = container.read(filterProvider.notifier);
    notifier.setCategory('Fruits');
    notifier.setSearchQuery('ana');
    notifier.reset();

    final state = container.read(filterProvider);
    expect(state.category, isNull);
    expect(state.searchQuery, isEmpty);
    expect(state.sortOption, SortOption.none);
  });
}