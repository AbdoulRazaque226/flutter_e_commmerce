import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/favorites_service.dart';

class FavoritesNotifier extends StateNotifier<Set<String>> {
  final FavoritesService _service;

  FavoritesNotifier(this._service) : super({}) {
    _loadFromDisk();
  }

  Future<void> _loadFromDisk() async {
    final saved = await _service.loadFavorites();
    state = saved;
  }

  bool isFavorite(String productId) => state.contains(productId);

  void toggle(String productId) {
    final updated = Set<String>.from(state);
    if (updated.contains(productId)) {
      updated.remove(productId);
    } else {
      updated.add(productId);
    }
    state = updated;
    _service.saveFavorites(updated); // persistance en arrière-plan
  }
}

final favoritesServiceProvider = Provider<FavoritesService>((ref) {
  return FavoritesService();
});


final favoritesProvider =
    StateNotifierProvider<FavoritesNotifier, Set<String>>((ref) {
  final service = ref.watch(favoritesServiceProvider);
  return FavoritesNotifier(service);
});


final isFavoriteProvider = Provider.family<bool, String>((ref, productId) {
  final favorites = ref.watch(favoritesProvider);
  return favorites.contains(productId);
});