import 'package:ecommerce_api/models/users/user.dart';

class UserResponse {
  final String id;
  final String name;
  final String email;
  final String role;

  final bool isActive;
  final bool isEmailVerified;
  final DateTime? emailVerifiedAt;

  final DateTime createdAt;
  final DateTime updatedAt;

  UserResponse({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.isActive,
    required this.isEmailVerified,
    this.emailVerifiedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserResponse.fromUser(User user) {
    return UserResponse(
      id: user.id?.oid ?? '',
      name: user.name,
      email: user.email,
      role: user.role,
      isActive: user.isActive,
      isEmailVerified: user.isEmailVerified,
      emailVerifiedAt: user.emailVerifiedAt,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'isActive': isActive,
      'isEmailVerified': isEmailVerified,
      'emailVerifiedAt': emailVerifiedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
