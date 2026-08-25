
abstract class AppException implements Exception {
  final String message;
  const AppException(this.message);

  @override
  String toString() => message;
}

class ProductFetchException extends AppException {
  const ProductFetchException([
    super.message = 'Impossible de charger les produits. Vérifie ta connexion.',
  ]);
}

class ProductNotFoundException extends AppException {
  final String productId;

  ProductNotFoundException(this.productId)
      : super('Produit "$productId" introuvable.');
}

class PersistenceException extends AppException {
  const PersistenceException([
    super.message = 'Impossible d\'accéder au stockage local.',
  ]);
}