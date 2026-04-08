import 'package:cookingsharefe/core/services/api_service.dart';
import '../../domain/models/user.dart';

abstract class UserRepository {
  Future<User> getProfile(String userId);
}

class UserRepositoryImpl implements UserRepository {
  final ApiService _apiService;

  UserRepositoryImpl(this._apiService);

  @override
  Future<User> getProfile(String userId) async {
    try {
      final response = await _apiService.get('/users/profile', queryParams: {});
      print('Profile response: $response');

      if (response != null && response['user'] != null) {
        final userData = Map<String, dynamic>.from(response['user']);

        // Thêm các trường mặc định nếu không có trong response
        userData['avatar'] ??= '';
        userData['bio'] ??= '';
        userData['isFollowing'] ??= false;
        userData['following'] ??= [];
        userData['followers'] ??= [];
        userData['favouriterecipe'] ??= [];
        userData['favouritecount'] ??= 0;
        userData['followersCount'] ??= userData['followers']?.length ?? 0;
        userData['followingCount'] ??= userData['following']?.length ?? 0;

        print('Processed user data: $userData');
        return User.fromJson(userData);
      }
      throw Exception('Không thể lấy thông tin người dùng');
    } catch (e) {
      print('Error getting profile: $e');
      rethrow;
    }
  }
}
