import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ecommerce_app/models/product.dart';
import 'package:ecommerce_app/providers/cart_provider.dart';

void main() {
  const product1 = Product(
    id: 'p1',
    name: 'Produit 1',
    description: 'Description 1',
    price: 1000,
    imageUrl: 'https://example.com/1.png',
    category: 'Test',
    rating: 4.5,
    stock: 5,
  );

  const product2 = Product(
    id: 'p2',
    name: 'Produit 2',
    description: 'Description 2',
    price: 2000,
    imageUrl: 'https://example.com/2.png',
    category: 'Test',
    rating: 4.0,
    stock: 1,
  );

  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
  });

  tearDown(() => container.dispose());

  test('le panier est vide au démarrage', () {
    final cart = container.read(cartProvider);
    expect(cart.isEmpty, isTrue);
    expect(cart.totalItems, 0);
    expect(cart.totalPrice, 0);
  });

  test('addProduct ajoute un nouveau produit avec quantité 1', () {
    container.read(cartProvider.notifier).addProduct(product1);
    final cart = container.read(cartProvider);

    expect(cart.items.length, 1);
    expect(cart.items.first.quantity, 1);
    expect(cart.totalPrice, 1000);
  });

  test('addProduct sur un produit déjà présent incrémente sa quantité', () {
    final notifier = container.read(cartProvider.notifier);
    notifier.addProduct(product1);
    notifier.addProduct(product1);

    final cart = container.read(cartProvider);
    expect(cart.items.length, 1);
    expect(cart.items.first.quantity, 2);
    expect(cart.totalPrice, 2000);
  });

  test('incrementQuantity ne dépasse jamais le stock disponible', () {
    final notifier = container.read(cartProvider.notifier);
    notifier.addProduct(product2); // stock = 1
    notifier.incrementQuantity(product2.id);

    final cart = container.read(cartProvider);
    expect(cart.items.first.quantity, 1); // bloqué au stock max
  });

  test('decrementQuantity supprime l\'article quand la quantité atteint 0', () {
    final notifier = container.read(cartProvider.notifier);
    notifier.addProduct(product1);
    notifier.decrementQuantity(product1.id);

    final cart = container.read(cartProvider);
    expect(cart.isEmpty, isTrue);
  });

  test('removeProduct retire le bon article', () {
    final notifier = container.read(cartProvider.notifier);
    notifier.addProduct(product1);
    notifier.addProduct(product2);
    notifier.removeProduct(product1.id);

    final cart = container.read(cartProvider);
    expect(cart.items.length, 1);
    expect(cart.items.first.product.id, product2.id);
  });

  test('clearCart vide entièrement le panier', () {
    final notifier = container.read(cartProvider.notifier);
    notifier.addProduct(product1);
    notifier.addProduct(product2);
    notifier.clearCart();

    expect(container.read(cartProvider).isEmpty, isTrue);
  });

  test('cartItemCountProvider reflète le nombre total d\'articles', () {
    final notifier = container.read(cartProvider.notifier);
    notifier.addProduct(product1);
    notifier.addProduct(product1);
    notifier.addProduct(product2);

    expect(container.read(cartItemCountProvider), 3);
  });
}