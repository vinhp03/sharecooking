import 'package:cookingsharefe/core/services/api_service.dart';
import 'package:cookingsharefe/core/constants/api_constants.dart';
import '../../domain/models/auth_token.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final ApiService _apiService;

  AuthRepositoryImpl(this._apiService);

  @override
  Future<AuthToken> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiService.post(
      ApiConstants.login,
      {
        'email': email,
        'password': password,
      },
    );
    return AuthToken.fromJson(response);
  }

  @override
  Future<AuthToken> register({
    required String username,
    required String email,
    required String password,
  }) async {
    final response = await _apiService.post(
      ApiConstants.register,
      {
        'username': username,
        'email': email,
        'password': password,
      },
    );
    return AuthToken.fromJson(response);
  }

  @override
  Future<AuthToken> refreshToken(String refreshToken) async {
    final response = await _apiService.post(
      ApiConstants.refreshToken,
      {
        'refreshToken': refreshToken,
      },
    );
    return AuthToken.fromJson(response);
  }

  @override
  Future<bool> logout() async {
    try {
      await _apiService.post(ApiConstants.logout, {});
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> forgotPassword(String email) async {
    try {
      await _apiService.post(
        '/auth/forgot-password',
        {
          'email': email,
        },
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      await _apiService.post(
        '/auth/reset-password',
        {
          'token': token,
          'newPassword': newPassword,
        },
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _apiService.post(
        '/auth/change-password',
        {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        },
      );
      return true;
    } catch (e) {
      return false;
    }
  }
}
