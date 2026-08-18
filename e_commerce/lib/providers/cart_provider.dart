import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/cart_item.dart';
import '../models/product.dart';

/// Logique métier du panier : ajout, suppression, changement de quantité.
/// Aucun widget ne manipule directement CartState — tout passe par ces
/// méthodes, ce qui garde la logique testable indépendamment de l'UI.
class CartNotifier extends StateNotifier<CartState> {
  CartNotifier() : super(const CartState());

  void addProduct(Product product) {
    final existingIndex =
        state.items.indexWhere((item) => item.product.id == product.id);

    if (existingIndex >= 0) {
      incrementQuantity(product.id);
      return;
    }

    state = state.copyWith(
      items: [...state.items, CartItem(product: product, quantity: 1)],
    );
  }

  void removeProduct(String productId) {
    state = state.copyWith(
      items: state.items.where((item) => item.product.id != productId).toList(),
    );
  }

  void incrementQuantity(String productId) {
    state = state.copyWith(
      items: state.items.map((item) {
        if (item.product.id == productId) {
          final maxStock = item.product.stock;
          final newQty =
              item.quantity < maxStock ? item.quantity + 1 : item.quantity;
          return item.copyWith(quantity: newQty);
        }
        return item;
      }).toList(),
    );
  }

  void decrementQuantity(String productId) {
    final item = state.items.firstWhere((i) => i.product.id == productId);
    if (item.quantity <= 1) {
      removeProduct(productId);
      return;
    }
    state = state.copyWith(
      items: state.items.map((i) {
        if (i.product.id == productId) {
          return i.copyWith(quantity: i.quantity - 1);
        }
        return i;
      }).toList(),
    );
  }

  void clearCart() {
    state = const CartState();
  }
}

/// Provider #4 — état global du panier, accessible partout dans l'app.
final cartProvider = StateNotifierProvider<CartNotifier, CartState>((ref) {
  return CartNotifier();
});

/// Provider dérivé — nombre total d'articles, pour le badge sur l'icône
/// panier. Ne se recalcule que quand le panier change, pas à chaque frame.
final cartItemCountProvider = Provider<int>((ref) {
  return ref.watch(cartProvider).totalItems;
});