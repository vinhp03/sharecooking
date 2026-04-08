import 'package:cookingsharefe/core/services/api_service.dart';
import 'package:cookingsharefe/core/constants/api_constants.dart';
import '../../domain/models/recipe.dart';
import '../../domain/repositories/recipe_repository.dart';

class RecipeRepositoryImpl implements RecipeRepository {
  final ApiService _apiService;

  RecipeRepositoryImpl(this._apiService);

  @override
  Future<List<Recipe>> getAllRecipes() async {
    try {
      final response = await _apiService.get('/recipes/get');
      return (response as List).map((json) => Recipe.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to get recipes: $e');
    }
  }

  @override
  Future<Recipe> getRecipeById(String id) async {
    try {
      final response = await _apiService.get('/recipes/$id');
      return Recipe.fromJson(response);
    } catch (e) {
      throw Exception('Failed to get recipe: $e');
    }
  }

  @override
  Future<List<Recipe>> getRecipesByUser(String userId) async {
    final response =
        await _apiService.get('${ApiConstants.recipes}/user/$userId');
    return (response as List).map((json) => Recipe.fromJson(json)).toList();
  }

  @override
  Future<List<Recipe>> searchRecipes({
    String? keyword,
    List<String>? ingredients,
    List<String>? tags,
  }) async {
    final queryParams = {
      if (keyword != null) 'keyword': keyword,
      if (ingredients != null) 'ingredients': ingredients.join(','),
      if (tags != null) 'tags': tags.join(','),
    };
    final response = await _apiService.get(
      ApiConstants.searchRecipes,
      queryParams: queryParams,
    );
    return (response as List).map((json) => Recipe.fromJson(json)).toList();
  }

  @override
  Future<Recipe> createRecipe({
    required String title,
    required String description,
    required String imageUrl,
    required List<String> ingredients,
    required List<String> instructions,
    required String difficulty,
    required List<String> tag,
    int? prepTime,
    int? cookTime,
    String? videoUrl,
  }) async {
    try {
      final data = {
        'title': title,
        'description': description,
        'imageUrl': imageUrl,
        'ingredients': ingredients,
        'instructions': instructions,
        'difficulty': difficulty,
        'tag': tag,
        if (prepTime != null) 'prepTime': prepTime,
        if (cookTime != null) 'cookTime': cookTime,
        if (videoUrl != null) 'videoUrl': videoUrl,
      };
      final response = await _apiService.post('/recipes', data);
      return Recipe.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create recipe: $e');
    }
  }

  @override
  Future<Recipe> updateRecipe({
    required String id,
    String? title,
    String? description,
    String? imageUrl,
    List<String>? ingredients,
    List<String>? instructions,
    String? difficulty,
    List<String>? tag,
    int? prepTime,
    int? cookTime,
    String? videoUrl,
  }) async {
    try {
      final data = {
        if (title != null) 'title': title,
        if (description != null) 'description': description,
        if (imageUrl != null) 'imageUrl': imageUrl,
        if (ingredients != null) 'ingredients': ingredients,
        if (instructions != null) 'instructions': instructions,
        if (difficulty != null) 'difficulty': difficulty,
        if (tag != null) 'tag': tag,
        if (prepTime != null) 'prepTime': prepTime,
        if (cookTime != null) 'cookTime': cookTime,
        if (videoUrl != null) 'videoUrl': videoUrl,
      };
      final response = await _apiService.put('/recipes/$id', data);
      return Recipe.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update recipe: $e');
    }
  }

  @override
  Future<bool> deleteRecipe(String id) async {
    try {
      await _apiService.delete('/recipes/$id');
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<Recipe> toggleReaction(String recipeId) async {
    final response = await _apiService.post(
      '${ApiConstants.recipes}/$recipeId/reaction',
      {},
    );
    return Recipe.fromJson(response['recipe']);
  }

  @override
  Future<Recipe> addComment({
    required String recipeId,
    required String content,
  }) async {
    final response = await _apiService.post(
      '${ApiConstants.recipes}/$recipeId/comments',
      {'content': content},
    );
    return Recipe.fromJson(response['recipe']);
  }

  @override
  Future<bool> deleteComment({
    required String recipeId,
    required String commentId,
  }) async {
    try {
      await _apiService
          .delete('${ApiConstants.recipes}/$recipeId/comments/$commentId');
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<List<RecipeComment>> getComments(String recipeId) async {
    final response =
        await _apiService.get('${ApiConstants.recipes}/$recipeId/comments');
    return (response as List)
        .map((json) => RecipeComment.fromJson(json))
        .toList();
  }
}
