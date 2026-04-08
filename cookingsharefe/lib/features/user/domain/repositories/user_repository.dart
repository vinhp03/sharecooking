import '../models/user.dart';

abstract class UserRepository {
  Future<User?> getCurrentUser();
  Future<User> getProfile(String userId);
  Future<User> getUserById(String id);
  Future<User> getUserByUsername(String username);
  Future<List<User>> getFollowers(String userId);
  Future<List<User>> getFollowing(String userId);
  Future<bool> followUser(String userId);
  Future<bool> unfollowUser(String userId);
  Future<bool> updateProfile({
    String? username,
    String? email,
    String? avatarUrl,
  });
  Future<bool> updatePassword({
    required String currentPassword,
    required String newPassword,
  });
}
