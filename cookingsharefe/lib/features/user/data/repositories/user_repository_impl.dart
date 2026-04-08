import 'package:cookingsharefe/core/services/api_service.dart';
import '../../domain/models/user.dart';
import '../../domain/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final ApiService _apiService;

  UserRepositoryImpl(this._apiService);

  @override
  Future<User?> getCurrentUser() async {
    try {
      final response = await _apiService.get('/users/profile');
      if (response != null && response['user'] != null) {
        final userData = Map<String, dynamic>.from(response['user']);
        return User.fromJson(userData);
      }
      return null;
    } catch (e) {
      print('Error getting current user: $e');
      return null;
    }
  }

  @override
  Future<User> getProfile(String userId) async {
    try {
      final response = await _apiService.get('/users/profile');
      if (response != null && response['user'] != null) {
        final userData = Map<String, dynamic>.from(response['user']);
        userData['avatar'] ??= '';
        userData['bio'] ??= '';
        userData['isFollowing'] ??= false;
        userData['following'] ??= [];
        userData['followers'] ??= [];
        userData['favouriterecipe'] ??= [];
        userData['favouritecount'] ??= 0;
        userData['followersCount'] ??= userData['followers']?.length ?? 0;
        userData['followingCount'] ??= userData['following']?.length ?? 0;
        return User.fromJson(userData);
      }
      throw Exception('Không thể lấy thông tin người dùng');
    } catch (e) {
      print('Error getting profile: $e');
      rethrow;
    }
  }

  @override
  Future<User> getUserById(String id) async {
    try {
      final response = await _apiService.get('/users/$id');
      return User.fromJson(response);
    } catch (e) {
      throw Exception('Failed to get user: $e');
    }
  }

  @override
  Future<User> getUserByUsername(String username) async {
    final response = await _apiService.get('/users/username/$username');
    return User.fromJson(response);
  }

  @override
  Future<List<User>> getFollowers(String userId) async {
    final response = await _apiService.get('/users/$userId/followers');
    return (response as List).map((json) => User.fromJson(json)).toList();
  }

  @override
  Future<List<User>> getFollowing(String userId) async {
    final response = await _apiService.get('/users/$userId/following');
    return (response as List).map((json) => User.fromJson(json)).toList();
  }

  @override
  Future<bool> updateProfile({
    String? username,
    String? email,
    String? avatarUrl,
  }) async {
    try {
      final data = {
        if (username != null) 'username': username,
        if (email != null) 'email': email,
        if (avatarUrl != null) 'avatarUrl': avatarUrl,
      };
      await _apiService.put('/users/profile', data);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> followUser(String userId) async {
    try {
      await _apiService.post('/users/$userId/follow');
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> unfollowUser(String userId) async {
    try {
      await _apiService.delete('/users/$userId/follow');
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _apiService.put('/users/password', {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      });
      return true;
    } catch (e) {
      return false;
    }
  }
}
