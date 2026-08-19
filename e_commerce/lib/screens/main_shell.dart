import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/cart_provider.dart';
import '../widgets/fly_to_cart_animation.dart';
import 'cart_screen.dart';
import 'catalog_screen.dart';
import 'favorites_screen.dart';
import 'profile_screen.dart';

final currentTabProvider = StateProvider<int>((ref) => 0);

final cartIconKeyProvider = Provider<GlobalKey>((ref) => GlobalKey());

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
    final cartIconKey = ref.watch(cartIconKeyProvider);

    return Scaffold(
      body: IndexedStack(index: currentIndex, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) =>
            ref.read(currentTabProvider.notifier).state = index,
        destinations: [
          const NavigationDestination(icon: Icon(Icons.storefront_outlined), label: 'Catalogue'),
          const NavigationDestination(icon: Icon(Icons.favorite_border), label: 'Favoris'),
          NavigationDestination(
            icon: Container(
              key: cartIconKey, // cible de l'animation "vol vers le panier"
              child: Badge(
                label: BouncingBadgeCount(value: cartCount),
                isLabelVisible: cartCount > 0,
                child: const Icon(Icons.shopping_cart_outlined),
              ),
            ),
            label: 'Panier',
          ),
          const NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profil'),
        ],
      ),
    );
  }
}