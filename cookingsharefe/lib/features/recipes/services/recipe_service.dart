import '../../../core/services/api_service.dart';
import '../domain/models/recipe.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';

class RecipeService {
  final ApiService _apiService;

  RecipeService({required ApiService apiService}) : _apiService = apiService;

  Future<List<Recipe>> getAllRecipes() async {
    try {
      final response = await _apiService.get('/recipes');
      return (response as List).map((json) => Recipe.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to get recipes: $e');
    }
  }

  Future<Recipe> getRecipeById(String id) async {
    try {
      final response = await _apiService.get('/recipes/$id');
      print('API Response for recipe $id:');
      print('Raw response: $response');
      print('averageRating: ${response['averageRating']}');
      print('ratingCount: ${response['ratingCount']}');
      return Recipe.fromJson(response);
    } catch (e) {
      throw Exception('Failed to get recipe: $e');
    }
  }

  Future<void> createRecipe({
    required String title,
    required String description,
    required dynamic imageFile,
    Uint8List? imageBytes,
    dynamic videoFile,
    Uint8List? videoBytes,
    required List<String> ingredients,
    required List<String> instructions,
    required String difficulty,
    required List<String> tag,
    required int prepTime,
    required int cookTime,
  }) async {
    try {
      final Map<String, String> files = {};
      final Map<String, Uint8List> fileBytes = {};

      if (kIsWeb) {
        if (imageBytes != null) {
          fileBytes['image'] = imageBytes;
        }
        if (videoBytes != null) {
          fileBytes['video'] = videoBytes;
        }
      } else {
        if (imageFile != null) {
          files['image'] = imageFile.path;
        }
        if (videoFile != null) {
          files['video'] = videoFile.path;
        }
      }

      // Convert arrays to JSON strings
      Map<String, String> formData = {
        'title': title,
        'description': description,
        'difficulty': difficulty,
        'prepTime': prepTime.toString(),
        'cookTime': cookTime.toString(),
        'ingredients': json.encode(ingredients),
        'instructions': json.encode(instructions),
        'tag': json.encode(tag),
      };

      final response = await _apiService.postMultipart(
        '/recipes',
        formData,
        files,
        fileBytes: fileBytes,
      );

      if (response == null) {
        throw Exception('Failed to create recipe');
      }
    } catch (e) {
      print('Error creating recipe: $e');
      rethrow;
    }
  }

  Future<bool> deleteRecipe(String id) async {
    try {
      await _apiService.delete('/recipes/$id');
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<Recipe>> searchRecipes({
    String? keyword,
    List<String>? ingredients,
    List<String>? tags,
  }) async {
    try {
      final queryParams = {
        if (keyword != null) 'keyword': keyword,
        if (ingredients != null) 'ingredients': ingredients.join(','),
        if (tags != null) 'tag': tags.join(','),
      };
      final response =
          await _apiService.get('/recipes/search', queryParams: queryParams);
      return (response as List)
          .map((json) => Recipe.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Search recipes error: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> getRecipeReactions(
      String recipeId, String? userId) async {
    try {
      final recipe = await getRecipeById(recipeId);
      if (recipe == null) {
        return {
          'isLiked': false,
          'reactionCount': 0,
        };
      }

      final bool isLiked = userId != null &&
          recipe.reactions.any((reaction) => reaction.user.id == userId);

      return {
        'isLiked': isLiked,
        'reactionCount': recipe.reactionCount,
      };
    } catch (e) {
      print('Get recipe reactions error: $e');
      return {
        'isLiked': false,
        'reactionCount': 0,
      };
    }
  }

  Future<Map<String, dynamic>> toggleReaction(String recipeId) async {
    try {
      final response = await _apiService.post(
        '/recipes/$recipeId/reaction',
        {},
      );
      final recipe = response['recipe'] as Map<String, dynamic>;
      return {
        'isLiked': recipe['isLiked'] as bool? ?? false,
        'reactionCount': recipe['reactionCount'] as int? ?? 0,
      };
    } catch (e) {
      print('Toggle reaction error: $e');
      rethrow;
    }
  }

  bool isRecipeLikedByUser(Recipe recipe, String? userId) {
    if (userId == null) return false;
    return recipe.reactions.any((reaction) => reaction.user.id == userId);
  }

  Future<Recipe?> addComment(String recipeId, String content) async {
    try {
      print('Sending comment request:');
      print('Recipe ID: $recipeId');
      print('Content: $content');

      // Gửi comment
      await _apiService.post(
        '/recipes/$recipeId/comment',
        {'comments': content},
      );

      // Sau khi comment thành công, lấy lại thông tin recipe mới nhất
      final response = await _apiService.get('/recipes/$recipeId');
      if (response != null) {
        return Recipe.fromJson(response as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('Add comment error: $e');
      print('Error stack trace: ${e is Error ? e.stackTrace : ''}');
      return null;
    }
  }

  Future<bool> deleteComment(String recipeId, String commentId) async {
    try {
      await _apiService.delete('/recipes/$recipeId/comment/$commentId');
      return true;
    } catch (e) {
      print('Delete comment error: $e');
      return false;
    }
  }

  Future<List<RecipeComment>> getComments(String recipeId) async {
    try {
      final response = await _apiService.get('/recipes/$recipeId/comment');
      return (response as List)
          .map((json) => RecipeComment.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Get comments error: $e');
      return [];
    }
  }

  Future<List<Recipe>> getFavoriteRecipes() async {
    try {
      final response = await _apiService.get('/users/profile');
      if (response is Map<String, dynamic> && response['user'] != null) {
        final user = response['user'] as Map<String, dynamic>;
        if (user['favouriterecipe'] != null &&
            user['favouriterecipe'] is List) {
          final List<String> favoriteIds =
              List<String>.from(user['favouriterecipe']);
          final List<Recipe> recipes = [];

          for (String id in favoriteIds) {
            final recipe = await getRecipeById(id);
            if (recipe.id != null) {
              recipes.add(recipe);
            }
          }

          return recipes;
        }
      }
      return [];
    } catch (e) {
      print('Get favorite recipes error: $e');
      return [];
    }
  }

  Future<bool> addToFavorites(String recipeId) async {
    try {
      await _apiService.post('/users/favorite/$recipeId', {});
      return true;
    } catch (e) {
      print('Add to favorites error: $e');
      return false;
    }
  }

  Future<bool> removeFromFavorites(String recipeId) async {
    try {
      await _apiService.delete('/users/favorite/$recipeId');
      return true;
    } catch (e) {
      print('Remove from favorites error: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>> getUserRating(String recipeId) async {
    try {
      final response = await _apiService.get('/recipes/$recipeId/rating');
      return {
        'rating': response['rating']['stars'].toDouble(),
        'averageRating': response['rating']['averageRating'].toDouble(),
        'ratingCount': response['rating']['ratingCount'],
      };
    } catch (e) {
      print('Get user rating error: $e');
      return {
        'rating': null,
        'averageRating': 0.0,
        'ratingCount': 0,
      };
    }
  }

  Future<Map<String, dynamic>> rateRecipe(
      String recipeId, double rating) async {
    try {
      final response = await _apiService.post(
        '/recipes/$recipeId/rating',
        {'stars': rating},
      );
      return {
        'averageRating': response['averageRating'] ?? 0.0,
        'ratingCount': response['ratingCount'] ?? 0,
      };
    } catch (e) {
      throw Exception('Failed to rate recipe: $e');
    }
  }

  Future<Map<String, dynamic>> deleteRating(String recipeId) async {
    try {
      final response = await _apiService.delete('/recipes/$recipeId/rating');
      return {
        'averageRating': response['averageRating'].toDouble(),
        'ratingCount': response['ratingCount'],
      };
    } catch (e) {
      print('Delete rating error: $e');
      rethrow;
    }
  }

  Future<bool> updateRecipe(String id, Map<String, dynamic> data) async {
    try {
      await _apiService.put('/recipes/$id', data);
      return true;
    } catch (e) {
      print('Update recipe error: $e');
      return false;
    }
  }
}
