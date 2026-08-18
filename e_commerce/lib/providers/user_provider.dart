import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user_profile.dart';

final userProvider = FutureProvider<UserProfile>((ref) async {
  await Future.delayed(const Duration(milliseconds: 500));

  return const UserProfile(
    id: 'u001',
    fullName: 'Abdoul Traoré',
    email: 'abdoul.traore@example.com',
    avatarUrl: 'https://picsum.photos/seed/user001/300/300',
    memberSince: 'Membre depuis Janvier 2024',
  );
});