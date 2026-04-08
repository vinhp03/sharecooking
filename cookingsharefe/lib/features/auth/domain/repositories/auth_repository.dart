import '../models/auth_token.dart';

abstract class AuthRepository {
  Future<AuthToken> login({
    required String email,
    required String password,
  });

  Future<AuthToken> register({
    required String username,
    required String email,
    required String password,
  });

  Future<AuthToken> refreshToken(String refreshToken);

  Future<bool> logout();

  Future<bool> forgotPassword(String email);

  Future<bool> resetPassword({
    required String token,
    required String newPassword,
  });

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  });
}
