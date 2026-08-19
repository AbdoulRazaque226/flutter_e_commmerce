import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../providers/favorites_provider.dart';
import '../providers/product_providers.dart';
import '../screens/main_shell.dart';
import '../theme/app_theme.dart';
import '../widgets/async_error_view.dart';
import '../widgets/fly_to_cart_animation.dart';

class ProductDetailScreen extends ConsumerWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productAsync = ref.watch(productByIdProvider(productId));

    return Scaffold(
      appBar: AppBar(title: const Text('Détail produit')),
      body: productAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => AsyncErrorView(
          message: error.toString(),
          onRetry: () => ref.invalidate(productByIdProvider(productId)),
        ),
        data: (product) => _ProductDetailBody(product: product),
      ),
    );
  }
}

class _ProductDetailBody extends ConsumerStatefulWidget {
  final Product product;
  const _ProductDetailBody({required this.product});

  @override
  ConsumerState<_ProductDetailBody> createState() => _ProductDetailBodyState();
}

class _ProductDetailBodyState extends ConsumerState<_ProductDetailBody> {

  final GlobalKey _addButtonKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final isFavorite = ref.watch(isFavoriteProvider(product.id));

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AspectRatio(
                  aspectRatio: 1,
                  child: Image.network(
                    product.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.broken_image_outlined, size: 48),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(product.name,
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          ),
                          IconButton(
                            icon: Icon(
                              isFavorite ? Icons.favorite : Icons.favorite_border,
                              color: isFavorite ? Colors.redAccent : Colors.black54,
                            ),
                            onPressed: () =>
                                ref.read(favoritesProvider.notifier).toggle(product.id),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star, size: 18, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text('${product.rating}'),
                          const SizedBox(width: 12),
                          Chip(label: Text(product.category), visualDensity: VisualDensity.compact),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(formatPrice(product.price),
                          style: const TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.primary)),
                      const SizedBox(height: 16),
                      Text(product.description, style: const TextStyle(height: 1.5)),
                      const SizedBox(height: 8),
                      Text(
                        product.inStock ? '${product.stock} en stock' : 'Rupture de stock',
                        style: TextStyle(
                          color: product.inStock ? Colors.green.shade700 : Colors.redAccent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                key: _addButtonKey,
                icon: const Icon(Icons.add_shopping_cart),
                label: Text(product.inStock ? 'Ajouter au panier' : 'Indisponible'),
                onPressed: product.inStock
                    ? () {
                        // Animation bonus : vol de la miniature vers l'icône panier.
                        showFlyToCartAnimation(
                          context,
                          startKey: _addButtonKey,
                          endKey: ref.read(cartIconKeyProvider),
                          imageUrl: product.imageUrl,
                        );
                        ref.read(cartProvider.notifier).addProduct(product);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${product.name} ajouté au panier'),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      }
                    : null,
              ),
            ),
          ),
        ),
      ],
    );
  }
}