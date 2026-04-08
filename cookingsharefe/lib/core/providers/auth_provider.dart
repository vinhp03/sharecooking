import 'package:flutter/foundation.dart';
import '../../features/auth/services/auth_service.dart';
import '../../features/user/services/user_service.dart';
import '../../features/user/domain/models/user.dart';

class AuthProvider extends ChangeNotifier {
  final UserService _userService;
  final AuthService _authService;
  User? _currentUser;
  bool _isLoading = false;

  AuthProvider({
    required UserService userService,
    required AuthService authService,
  })  : _userService = userService,
        _authService = authService {
    _initializeAuth();
  }

  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;
  User? get currentUser => _currentUser;

  Future<void> _initializeAuth() async {
    await loadAuthData();
  }

  Future<bool> loadAuthData() async {
    if (_isLoading) return false;

    _isLoading = true;
    notifyListeners();

    try {
      final user = await _authService.getCurrentUser();
      if (user != null) {
        _currentUser = user;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Error loading auth data: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    if (_isLoading) return false;

    _isLoading = true;
    notifyListeners();

    try {
      final user = await _authService.login(
        email: email,
        password: password,
      );

      if (user != null) {
        _currentUser = user;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Login error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register({
    required String username,
    required String email,
    required String password,
  }) async {
    if (_isLoading) return false;

    _isLoading = true;
    notifyListeners();

    try {
      final user = await _authService.register(
        username: username,
        email: email,
        password: password,
      );

      if (user != null) {
        _currentUser = user;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Register error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    if (_isLoading) return;

    _isLoading = true;
    notifyListeners();

    try {
      await _authService.logout();
      _currentUser = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
