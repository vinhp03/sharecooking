// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipe.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Recipe _$RecipeFromJson(Map<String, dynamic> json) => Recipe(
      id: json['_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      imageUrl: json['imageUrl'] as String?,
      ingredients: (json['ingredients'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      instructions: (json['instructions'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      videoUrl: json['videoUrl'] as String?,
      user: json['user'] == null
          ? null
          : User.fromJson(json['user'] as Map<String, dynamic>),
      tag: (json['tag'] as List<dynamic>).map((e) => e as String).toList(),
      prepTime: (json['prepTime'] as num?)?.toInt(),
      cookTime: (json['cookTime'] as num?)?.toInt(),
      difficulty: json['difficulty'] as String?,
      averageRating: json['averageRating'] == null
          ? 0.0
          : Recipe._ratingFromJson(json['averageRating']),
      ratingCount: json['ratingCount'] == null
          ? 0
          : Recipe._ratingCountFromJson(json['ratingCount']),
      createdAt: DateTime.parse(json['createdAt'] as String),
      comments: (json['comments'] as List<dynamic>)
          .map((e) => RecipeComment.fromJson(e as Map<String, dynamic>))
          .toList(),
      reactions: (json['reactions'] as List<dynamic>)
          .map((e) => Reaction.fromJson(e as Map<String, dynamic>))
          .toList(),
      isReacted: json['isReacted'] as bool? ?? false,
      reactionCount: (json['reactionCount'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$RecipeToJson(Recipe instance) => <String, dynamic>{
      '_id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'imageUrl': instance.imageUrl,
      'ingredients': instance.ingredients,
      'instructions': instance.instructions,
      'videoUrl': instance.videoUrl,
      'user': instance.user,
      'tag': instance.tag,
      'prepTime': instance.prepTime,
      'cookTime': instance.cookTime,
      'difficulty': instance.difficulty,
      'averageRating': instance.averageRating,
      'ratingCount': instance.ratingCount,
      'createdAt': instance.createdAt.toIso8601String(),
      'comments': instance.comments,
      'reactions': instance.reactions,
      'isReacted': instance.isReacted,
      'reactionCount': instance.reactionCount,
    };

User _$UserFromJson(Map<String, dynamic> json) => User(
      id: json['_id'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      '_id': instance.id,
      'username': instance.username,
      'email': instance.email,
    };

RecipeComment _$RecipeCommentFromJson(Map<String, dynamic> json) =>
    RecipeComment(
      id: json['_id'] as String,
      user: json['user'] == null
          ? null
          : User.fromJson(json['user'] as Map<String, dynamic>),
      content: json['content'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$RecipeCommentToJson(RecipeComment instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'user': instance.user,
      'content': instance.content,
      'createdAt': instance.createdAt.toIso8601String(),
    };

Reaction _$ReactionFromJson(Map<String, dynamic> json) => Reaction(
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$ReactionToJson(Reaction instance) => <String, dynamic>{
      'user': instance.user,
      'createdAt': instance.createdAt.toIso8601String(),
    };
