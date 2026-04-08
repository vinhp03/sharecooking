import 'package:shared_preferences/shared_preferences.dart';
import '../../features/auth/domain/models/auth_token.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';

class AuthService {
  final AuthRepositoryImpl _authRepository;
  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refreshToken';
  static const String _rememberMeKey = 'rememberMe';
  static const String _userIdKey = 'userId';

  AuthService(this._authRepository);

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<void> setToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_rememberMeKey);
    await prefs.remove(_userIdKey);
  }

  Future<AuthToken> refreshToken(String refreshToken) async {
    try {
      return await _authRepository.refreshToken(refreshToken);
    } catch (e) {
      print('Error refreshing token: $e');
      rethrow;
    }
  }

  Future<AuthToken?> login({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    try {
      final token = await _authRepository.login(
        email: email,
        password: password,
      );
      await _saveToken(token, rememberMe);
      return token;
    } catch (e) {
      print('Login error: $e');
      return null;
    }
  }

  Future<AuthToken?> register({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      final token = await _authRepository.register(
        username: username,
        email: email,
        password: password,
      );
      await _saveToken(token, false);
      return token;
    } catch (e) {
      print('Registration error: $e');
      return null;
    }
  }

  Future<bool> logout() async {
    try {
      final success = await _authRepository.logout();
      if (success) {
        await removeToken();
      }
      return success;
    } catch (e) {
      print('Error during logout: $e');
      return false;
    }
  }

  Future<AuthToken?> checkSavedCredentials() async {
    try {
      print('Checking saved credentials...');
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);
      final refreshToken = prefs.getString(_refreshTokenKey);
      final userId = prefs.getString(_userIdKey);
      final rememberMe = prefs.getBool(_rememberMeKey) ?? false;

      print(
          'Saved credentials: token=$token, refreshToken=$refreshToken, userId=$userId, rememberMe=$rememberMe');

      if (token != null && userId != null) {
        // Nếu có token và userId, trả về token hiện tại
        print('Using existing token');
        return AuthToken(
          token: token,
          refreshToken: refreshToken ?? '',
          userId: userId,
        );
      }

      if (refreshToken != null && rememberMe) {
        print('Refreshing token...');
        // Nếu có refresh token và rememberMe = true, thử refresh token
        final newToken = await _authRepository.refreshToken(refreshToken);
        await _saveToken(newToken, true);
        return newToken;
      }

      print('No valid credentials found');
      return null;
    } catch (e) {
      print('Error checking saved credentials: $e');
      // Xóa token cũ nếu có lỗi
      await removeToken();
      return null;
    }
  }

  Future<void> _saveToken(AuthToken token, bool rememberMe) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token.token);
    await prefs.setString(_userIdKey, token.userId);

    if (rememberMe) {
      await prefs.setString(_refreshTokenKey, token.refreshToken);
      await prefs.setBool(_rememberMeKey, true);
    } else {
      await prefs.remove(_refreshTokenKey);
      await prefs.setBool(_rememberMeKey, false);
    }
  }
}
