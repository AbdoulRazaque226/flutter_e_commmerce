import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/cart_provider.dart';
import 'cart_screen.dart';
import 'catalog_screen.dart';
import 'favorites_screen.dart';
import 'profile_screen.dart';

/// Provider #13 — index de l'onglet actif dans la bottom nav bar.
/// StateProvider : le cas d'usage le plus simple de Riverpod pour un état
/// primitif (int) modifiable depuis l'UI, sans passer par setState.
final currentTabProvider = StateProvider<int>((ref) => 0);

/// Conteneur principal avec navigation par onglets (bottom nav bar).
/// ConsumerWidget (pas Stateful) : aucun état local, tout passe par
/// currentTabProvider — cohérent avec l'exigence "exclusivement Riverpod".
class MainShell extends ConsumerWidget {
  const MainShell({super.key});

  static const _screens = [
    CatalogScreen(),
    FavoritesScreen(),
    CartScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(currentTabProvider);
    final cartCount = ref.watch(cartItemCountProvider);

    return Scaffold(
      // IndexedStack conserve l'état de chaque onglet (pas de rebuild complet
      // quand on change d'onglet, ex: le scroll du catalogue est conservé).
      body: IndexedStack(index: currentIndex, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) =>
            ref.read(currentTabProvider.notifier).state = index,
        destinations: [
          const NavigationDestination(icon: Icon(Icons.storefront_outlined), label: 'Catalogue'),
          const NavigationDestination(icon: Icon(Icons.favorite_border), label: 'Favoris'),
          NavigationDestination(
            icon: Badge(
              label: Text('$cartCount'),
              isLabelVisible: cartCount > 0,
              child: const Icon(Icons.shopping_cart_outlined),
            ),
            label: 'Panier',
          ),
          const NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profil'),
        ],
      ),
    );
  }
}