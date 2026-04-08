class ApiConstants {
  static const String baseUrl = 'http://localhost:3000/api';

  // Auth endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/signup';
  static const String refreshToken = '/auth/refresh';
  static const String logout = '/auth/logout';

  // Recipe endpoints
  static const String recipes = '/recipes';
  static const String getRecipes = '/recipes/get';
  static const String searchRecipes = '/recipes/search';
  static const String recipeReaction = '/recipes/{id}/reaction';
  static const String recipeComment = '/recipes/{id}/comment';

  // User endpoints
  static const String userProfile = '/users/profile';
  static const String userFavorites = '/users/favorites';
}
