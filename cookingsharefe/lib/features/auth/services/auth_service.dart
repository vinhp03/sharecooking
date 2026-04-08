import 'package:cookingsharefe/core/services/api_service.dart';
import 'package:cookingsharefe/features/user/domain/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final ApiService _apiService;
  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userIdKey = 'user_id';

  AuthService({required ApiService apiService}) : _apiService = apiService;

  Future<User?> getCurrentUser() async {
    try {
      final response = await _apiService.get('/users/profile');
      if (response == null || response['user'] == null) {
        print('getCurrentUser: Response or user is null');
        return null;
      }
      return User.fromJson(response['user']);
    } catch (e) {
      print('Get current user error: $e');
      return null;
    }
  }

  Future<User?> login({
    required String email,
    required String password,
  }) async {
    try {
      print('Attempting login with email: $email');
      final response = await _apiService.post(
        '/auth/login',
        {
          'email': email,
          'password': password,
        },
      );

      print('Login response: $response');

      if (response == null) {
        print('Login failed: Response is null');
        return null;
      }

      if (response['token'] != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_tokenKey, response['token']);
        if (response['refreshToken'] != null) {
          await prefs.setString(_refreshTokenKey, response['refreshToken']);
        }
        if (response['userId'] != null) {
          await prefs.setString(_userIdKey, response['userId']);
        }

        // Lấy thông tin user từ profile API
        return await getCurrentUser();
      } else {
        print('Login failed: No token in response');
        return null;
      }
    } catch (e) {
      print('Login error: $e');
      return null;
    }
  }

  Future<User?> register({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiService.post(
        '/auth/signup',
        {
          'username': username,
          'email': email,
          'password': password,
        },
      );

      print('Register response: $response');

      if (response == null) {
        print('Register failed: Response is null');
        return null;
      }

      if (response['token'] != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_tokenKey, response['token']);
        if (response['refreshToken'] != null) {
          await prefs.setString(_refreshTokenKey, response['refreshToken']);
        }
        if (response['userId'] != null) {
          await prefs.setString(_userIdKey, response['userId']);
        }

        // Lấy thông tin user từ profile API
        return await getCurrentUser();
      }
      return null;
    } catch (e) {
      print('Register error: $e');
      return null;
    }
  }

  Future<void> logout() async {
    try {
      await _apiService.post('/auth/logout', {});
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_refreshTokenKey);
      await prefs.remove(_userIdKey);
    } catch (e) {
      print('Logout error: $e');
    }
  }

  Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_userIdKey);
  }
}
