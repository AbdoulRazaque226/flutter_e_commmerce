import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/product_repository.dart';
import '../models/product.dart';

/// Options de tri disponibles pour le catalogue.
enum SortOption { none, priceAsc, priceDesc, ratingDesc, nameAsc }

extension SortOptionLabel on SortOption {
  String get label {
    switch (this) {
      case SortOption.none:
        return 'Par défaut';
      case SortOption.priceAsc:
        return 'Prix croissant';
      case SortOption.priceDesc:
        return 'Prix décroissant';
      case SortOption.ratingDesc:
        return 'Mieux notés';
      case SortOption.nameAsc:
        return 'Nom (A-Z)';
    }
  }
}

/// État immuable du filtre/tri appliqué au catalogue.
class FilterState {
  final String? category; // null = toutes catégories
  final String searchQuery;
  final SortOption sortOption;

  const FilterState({
    this.category,
    this.searchQuery = '',
    this.sortOption = SortOption.none,
  });

  FilterState copyWith({
    String? category,
    bool clearCategory = false,
    String? searchQuery,
    SortOption? sortOption,
  }) {
    return FilterState(
      category: clearCategory ? null : (category ?? this.category),
      searchQuery: searchQuery ?? this.searchQuery,
      sortOption: sortOption ?? this.sortOption,
    );
  }
}

/// StateNotifier pour piloter le filtre/tri depuis l'UI (barre de filtres).
class FilterNotifier extends StateNotifier<FilterState> {
  FilterNotifier() : super(const FilterState());

  void setCategory(String? category) {
    if (category == null) {
      state = state.copyWith(clearCategory: true);
    } else {
      state = state.copyWith(category: category);
    }
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setSortOption(SortOption option) {
    state = state.copyWith(sortOption: option);
  }

  void reset() => state = const FilterState();
}

// ---------------------------------------------------------------------
// PROVIDERS
// ---------------------------------------------------------------------

/// Provider #1 — instance unique du repository.
/// Passe `simulateError: true` ici pour tester l'écran d'erreur.
final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return const ProductRepository(simulateError: false);
});

/// Provider #2 — récupère les produits de façon asynchrone.
/// FutureProvider expose directement un AsyncValue<List<Product>>,
/// géré nativement par l'UI (.when : loading / error / data).
final productsProvider = FutureProvider<List<Product>>((ref) async {
  final repository = ref.watch(productRepositoryProvider);
  return repository.fetchProducts();
});

/// Provider #3 — état du filtre/tri courant.
final filterProvider = StateNotifierProvider<FilterNotifier, FilterState>((ref) {
  return FilterNotifier();
});

/// Provider dérivé — combine productsProvider + filterProvider.
/// C'est un Provider "calculé" : il se recalcule automatiquement dès que
/// productsProvider OU filterProvider change. Aucune logique de filtrage
/// ne vit dans les widgets.
final filteredProductsProvider = Provider<AsyncValue<List<Product>>>((ref) {
  final productsAsync = ref.watch(productsProvider);
  final filter = ref.watch(filterProvider);

  return productsAsync.whenData((products) {
    var result = products.where((p) {
      final matchesCategory =
          filter.category == null || p.category == filter.category;
      final matchesSearch = filter.searchQuery.isEmpty ||
          p.name.toLowerCase().contains(filter.searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();

    switch (filter.sortOption) {
      case SortOption.priceAsc:
        result.sort((a, b) => a.price.compareTo(b.price));
        break;
      case SortOption.priceDesc:
        result.sort((a, b) => b.price.compareTo(a.price));
        break;
      case SortOption.ratingDesc:
        result.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case SortOption.nameAsc:
        result.sort((a, b) => a.name.compareTo(b.name));
        break;
      case SortOption.none:
        break;
    }

    return result;
  });
});

/// Provider family — récupère un produit précis par son id, pour l'écran
/// de détail. `.family` permet de paramétrer un provider par un argument
/// (ici productId) tout en gardant le cache par Riverpod.
final productByIdProvider =
    FutureProvider.family<Product, String>((ref, productId) async {
  final repository = ref.watch(productRepositoryProvider);
  return repository.fetchProductById(productId);
});

/// Provider utilitaire — liste des catégories disponibles (pour les chips
/// de filtre), dérivée elle aussi des produits chargés.
final categoriesProvider = Provider<AsyncValue<List<String>>>((ref) {
  final productsAsync = ref.watch(productsProvider);
  return productsAsync.whenData(
    (products) => products.map((p) => p.category).toSet().toList()..sort(),
  );
});