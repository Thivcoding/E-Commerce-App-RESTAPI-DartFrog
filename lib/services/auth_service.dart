import 'package:ecommerce_api/constants/role_constants.dart';
import 'package:ecommerce_api/dto/request/login_request.dart';
import 'package:ecommerce_api/dto/request/register_request.dart';
import 'package:ecommerce_api/dto/response/user_response.dart';
import 'package:ecommerce_api/models/user.dart';
import 'package:ecommerce_api/repositories/user_repository.dart';
import 'package:ecommerce_api/utils/jwt_util.dart';
import 'package:ecommerce_api/utils/password_util.dart';

class AuthService {
  final UserRepository repository;

  AuthService(this.repository);

  Future<UserResponse> register(
    RegisterRequest request,
  ) async {
    final name = request.name.trim();
    final email = request.email.trim().toLowerCase();
    final password = request.password;

    if (name.isEmpty) {
      throw Exception('Name is required');
    }

    if (email.isEmpty) {
      throw Exception('Email is required');
    }

    if (!_isValidEmail(email)) {
      throw Exception('Invalid email address');
    }

    if (password.isEmpty) {
      throw Exception('Password is required');
    }

    if (password.length < 6) {
      throw Exception(
        'Password must be at least 6 characters',
      );
    }

    if (password != request.confirmPassword) {
      throw Exception('Passwords do not match');
    }

    final existingUser = await repository.findByEmail(
      email,
    );

    if (existingUser != null) {
      throw Exception('Email already exists');
    }

    final hashedPassword = PasswordUtil.hash(
      password,
    );

    final now = DateTime.now();

    final user = User(
      name: name,
      email: email,
      password: hashedPassword,
      role: RoleConstants.user,
      isActive: true,
      createdAt: now,
      updatedAt: now,
    );

    final createdUser = await repository.create(
      user,
    );

    return UserResponse.fromUser(
      createdUser,
    );
  }

  Future<Map<String, dynamic>> login(
    LoginRequest request,
  ) async {
    final email = request.email.trim().toLowerCase();
    final password = request.password;

    if (email.isEmpty) {
      throw Exception('Email is required');
    }

    if (password.isEmpty) {
      throw Exception('Password is required');
    }

    final user = await repository.findByEmail(
      email,
    );

    if (user == null) {
      throw Exception(
        'Invalid email or password',
      );
    }

    if (!user.isActive) {
      throw Exception(
        'User account is inactive',
      );
    }

    final passwordValid = PasswordUtil.verify(
      password,
      user.password,
    );

    if (!passwordValid) {
      throw Exception(
        'Invalid email or password',
      );
    }

    if (user.id == null) {
      throw Exception(
        'User ID is missing',
      );
    }

    final userId = user.id!.oid;

    final accessToken = JwtUtil.generateAccessToken(
      userId: userId,
      email: user.email,
      role: user.role,
    );

    final refreshToken = JwtUtil.generateRefreshToken(
      userId: userId,
    );

    return {
      'user': UserResponse.fromUser(user).toJson(),
      'accessToken': accessToken,
      'refreshToken': refreshToken,
    };
  }

  Future<UserResponse> getMe(
    String userId,
  ) async {
    if (userId.isEmpty) {
      throw Exception('User ID is required');
    }

    final user = await repository.findById(
      userId,
    );

    if (user == null) {
      throw Exception('User not found');
    }

    if (!user.isActive) {
      throw Exception(
        'User account is inactive',
      );
    }

    return UserResponse.fromUser(
      user,
    );
  }

  Future<void> changePassword(
    String userId,
    String currentPassword,
    String newPassword,
  ) async {
    if (currentPassword.isEmpty) {
      throw Exception(
        'Current password is required',
      );
    }

    if (newPassword.isEmpty) {
      throw Exception(
        'New password is required',
      );
    }

    if (newPassword.length < 6) {
      throw Exception(
        'New password must be at least 6 characters',
      );
    }

    final user = await repository.findById(
      userId,
    );

    if (user == null) {
      throw Exception('User not found');
    }

    final valid = PasswordUtil.verify(
      currentPassword,
      user.password,
    );

    if (!valid) {
      throw Exception(
        'Current password is incorrect',
      );
    }

    final hashedPassword = PasswordUtil.hash(
      newPassword,
    );

    await repository.updateById(
      userId,
      {
        'password': hashedPassword,
      },
    );
  }

  bool _isValidEmail(String email) {
    return RegExp(
      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
    ).hasMatch(email);
  }
}
