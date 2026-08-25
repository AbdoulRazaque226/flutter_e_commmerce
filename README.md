E-commerce App — Flutter + Riverpod

Application e-commerce mobile développée en Flutter, utilisant Riverpod comme unique solution de state management. Projet réalisé pour valider la maîtrise du state management via une architecture en couches.

Fonctionnalités
Catalogue de produits — liste (grille) + écran de détail
Panier d'achat — ajout, suppression, incrémentation/décrémentation de quantité
Favoris persistés localement — survivent au redémarrage de l'app (SharedPreferences)
Filtrage et tri — recherche par nom, filtre par catégorie, tri (prix, note, nom)
Profil utilisateur (mocké) — infos personnelles + nombre de favoris

Architecture

Le projet suit une architecture en couches, avec une séparation stricte entre logique métier et UI :

lib/
├── main.dart                  # Point d'entrée, ProviderScope
├── models/                    # Structures de données immuables
│   ├── product.dart
│   ├── cart_item.dart         # CartItem + CartState
│   └── user_profile.dart
├── data/                      # Accès aux données (source unique de vérité)
│   ├── mockProducts.dart      # Jeu de données mocké (12 produits, 5 catégories)
│   └── productRepository.dart # Simule un appel réseau (latence + erreurs)
├── services/                  # Services techniques transverses
│   └── favorites_service.dart # Persistance des favoris (SharedPreferences)
├── providers/                 # Toute la logique d'état (Riverpod)
│   ├── product_providers.dart
│   ├── cart_provider.dart
│   ├── favorites_provider.dart
│   └── user_provider.dart
├── theme/
│   └── app_theme.dart
├── widgets/                   # Composants UI réutilisables, sans logique métier
│   ├── product_card.dart
│   ├── cart_item_tile.dart
│   ├── filter_bar.dart
│   └── async_error_view.dart
└── screens/                   # Écrans, assemblent widgets + providers
    ├── catalog_screen.dart
    ├── product_detail_screen.dart
    ├── cart_screen.dart
    ├── favorites_screen.dart
    ├── profile_screen.dart
    └── main_shell.dart        # Navigation par onglets (bottom nav bar)