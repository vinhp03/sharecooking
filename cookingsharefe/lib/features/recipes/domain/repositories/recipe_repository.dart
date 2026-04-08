import '../models/recipe.dart';

abstract class RecipeRepository {
  Future<List<Recipe>> getAllRecipes();
  Future<Recipe> getRecipeById(String id);
  Future<List<Recipe>> getRecipesByUser(String userId);
  Future<List<Recipe>> searchRecipes({
    String? keyword,
    List<String>? ingredients,
    List<String>? tags,
  });
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
  });
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
  });
  Future<bool> deleteRecipe(String id);
  Future<Recipe> toggleReaction(String recipeId);
  Future<Recipe> addComment({
    required String recipeId,
    required String content,
  });
  Future<bool> deleteComment({
    required String recipeId,
    required String commentId,
  });
  Future<List<RecipeComment>> getComments(String recipeId);
}
