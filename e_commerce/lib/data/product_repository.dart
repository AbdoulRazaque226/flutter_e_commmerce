import 'dart:math';
import 'mock_products.dart';

import '../models/product.dart';

class ProductFetchException implements Exception {
  final String message;
  const ProductFetchException(this.message);

  @override
  String toString() => message;
}

class ProductRepository {
  final bool simulateError;

  const ProductRepository({this.simulateError = false});

  Future<List<Product>> fetchProducts() async {
    await Future.delayed(Duration(milliseconds: 600 + Random().nextInt(600)));

    if (simulateError) {
      throw const ProductFetchException(
        'Impossible de charger les produits. Vérifie ta connexion.',
      );
    }

    return mockProducts;
  }

  Future<Product> fetchProductById(String id) async {
    await Future.delayed(const Duration(milliseconds: 400));

    final matches = mockProducts.where((p) => p.id == id);
    if (matches.isEmpty) {
      throw ProductFetchException('Produit "$id" introuvable.');
    }
    return matches.first;
  }
}