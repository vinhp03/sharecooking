import 'package:cookingsharefe/core/services/api_service.dart';
import 'package:cookingsharefe/features/user/domain/models/user.dart';

class UserService {
  final ApiService _apiService;

  UserService(this._apiService);
  Future<User> getProfile(String userId) async {
    final response = await _apiService.post(
      '/users/profile',
      {
        'userId': userId,
      },
    );
    return User.fromJson(response['data']);
  }
}
