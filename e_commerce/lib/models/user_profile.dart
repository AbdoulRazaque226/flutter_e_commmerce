/// Profil utilisateur mocké (pas d'authentification réelle).
class UserProfile {
  final String id;
  final String fullName;
  final String email;
  final String avatarUrl;
  final String memberSince;

  const UserProfile({
    required this.id,
    required this.fullName,
    required this.email,
    required this.avatarUrl,
    required this.memberSince,
  });
}