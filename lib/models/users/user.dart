import 'package:mongo_dart/mongo_dart.dart';

class User {
  final ObjectId? id;
  final String name;
  final String email;
  final String? password;
  final String role;
  final String provider;
  final String? providerId;
  final bool isActive;
  final bool isEmailVerified;
  final DateTime? emailVerifiedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    this.id,
    required this.name,
    required this.email,
    this.password,
    required this.role,
    this.provider = 'LOCAL',
    this.providerId,
    required this.isActive,
    this.isEmailVerified = false,
    this.emailVerifiedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toDocument() {
    return {
      if (id != null) '_id': id,
      'name': name,
      'email': email,
      'password': password,
      'role': role,
      'provider': provider,
      'providerId': providerId,
      'isActive': isActive,
      'isEmailVerified': isEmailVerified,
      'emailVerifiedAt': emailVerifiedAt,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
