import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/favorites_provider.dart';
import '../providers/user_provider.dart';
import '../widgets/async_error_view.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProvider);
    final favoritesCount = ref.watch(favoritesProvider).length;

    return Scaffold(
      appBar: AppBar(title: const Text('Mon profil')),
      body: userAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => AsyncErrorView(
          message: error.toString(),
          onRetry: () => ref.invalidate(userProvider),
        ),
        data: (user) => ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Center(
              child: CircleAvatar(
                radius: 48,
                backgroundImage: NetworkImage(user.avatarUrl),
              ),
            ),
            const SizedBox(height: 16),
            Text(user.fullName,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(user.email, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 4),
            Text(user.memberSince,
                textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 24),
            Card(
              child: ListTile(
                leading: const Icon(Icons.favorite, color: Colors.redAccent),
                title: const Text('Produits favoris'),
                trailing: Text('$favoritesCount', style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const Card(
              child: ListTile(
                leading: Icon(Icons.location_on_outlined),
                title: Text('Adresses de livraison'),
                trailing: Icon(Icons.chevron_right),
              ),
            ),
            const Card(
              child: ListTile(
                leading: Icon(Icons.payment_outlined),
                title: Text('Moyens de paiement'),
                trailing: Icon(Icons.chevron_right),
              ),
            ),
            const Card(
              child: ListTile(
                leading: Icon(Icons.logout, color: Colors.redAccent),
                title: Text('Se déconnecter', style: TextStyle(color: Colors.redAccent)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}