import 'dart:math';

import 'package:ecommerce_app/exceptions/exept.dart';

import '../models/product.dart';
import 'mock_products.dart';

abstract class ProductRepositoryInterface {
  Future<List<Product>> fetchProducts();
  Future<Product> fetchProductById(String id);
}

class ProductRepository implements ProductRepositoryInterface {
  
  final bool simulateError;

  const ProductRepository({this.simulateError = false});

  @override
  Future<List<Product>> fetchProducts() async {
    await Future.delayed(Duration(milliseconds: 600 + Random().nextInt(600)));

    if (simulateError) {
      throw const ProductFetchException();
    }

    return mockProducts;
  }

  @override
  Future<Product> fetchProductById(String id) async {
    await Future.delayed(const Duration(milliseconds: 400));

    final matches = mockProducts.where((p) => p.id == id);
    if (matches.isEmpty) {
      throw ProductNotFoundException(id);
    }
    return matches.first;
  }
}