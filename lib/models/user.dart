import 'package:mongo_dart/mongo_dart.dart';

class User {
  final ObjectId? id;
  final String name;
  final String email;
  final String password;
  final String role;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.role,
    required this.isActive,
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
      'isActive': isActive,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
