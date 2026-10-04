class AuthenticatedUser {
  final String userId;
  final String email;
  final String role;

  AuthenticatedUser({
    required this.userId,
    required this.email,
    required this.role,
  });
}