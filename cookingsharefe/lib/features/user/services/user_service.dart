import 'package:cookingsharefe/core/services/api_service.dart';
import 'package:cookingsharefe/features/user/domain/models/user.dart';

class UserService {
  final ApiService _apiService;

  UserService({required ApiService apiService}) : _apiService = apiService;

  Future<User?> getCurrentUser() async {
    try {
      final response = await _apiService.get('/users/profile', queryParams: {});
      return User.fromJson(response['user']);
    } catch (e) {
      print('Error getting current user: $e');
      return null;
    }
  }

  Future<User?> getProfile(String userId) async {
    try {
      final response = await _apiService.get('/users/$userId', queryParams: {});
      return User.fromJson(response['user']);
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    try {
      await _apiService.put('/users/profile', data);
    } catch (e) {
      print('Error updating profile: $e');
      rethrow;
    }
  }

  Future<bool> followUser(String userId) async {
    // Implementation needed
    throw UnimplementedError();
  }

  Future<bool> unfollowUser(String userId) async {
    // Implementation needed
    throw UnimplementedError();
  }
}
