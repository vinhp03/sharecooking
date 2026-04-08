import 'package:json_annotation/json_annotation.dart';

part 'recipe.g.dart';

@JsonSerializable()
class Recipe {
  @JsonKey(name: '_id')
  final String id;
  final String title;
  final String description;
  final String? imageUrl;
  final List<String> ingredients;
  final List<String> instructions;
  final String? videoUrl;
  @JsonKey(name: 'user')
  final User? user;
  final List<String> tag;
  final int? prepTime;
  final int? cookTime;
  final String? difficulty;
  @JsonKey(name: 'averageRating', defaultValue: 0.0, fromJson: _ratingFromJson)
  double averageRating;
  @JsonKey(name: 'ratingCount', defaultValue: 0, fromJson: _ratingCountFromJson)
  int ratingCount;
  final DateTime createdAt;
  final List<RecipeComment> comments;
  final List<Reaction> reactions;
  @JsonKey(defaultValue: false)
  bool isReacted;
  @JsonKey(defaultValue: 0)
  int reactionCount;

  Recipe({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl,
    required this.ingredients,
    required this.instructions,
    this.videoUrl,
    this.user,
    required this.tag,
    this.prepTime,
    this.cookTime,
    this.difficulty,
    this.averageRating = 0.0,
    this.ratingCount = 0,
    required this.createdAt,
    required this.comments,
    required this.reactions,
    this.isReacted = false,
    this.reactionCount = 0,
  });

  static double _ratingFromJson(dynamic value) {
    if (value == null) return 0.0;
    if (value is int) return value.toDouble();
    if (value is double) return value;
    return double.tryParse(value.toString()) ?? 0.0;
  }

  static int _ratingCountFromJson(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }

  factory Recipe.fromJson(Map<String, dynamic> json) {
    // Xử lý trường user
    User? user;
    if (json['user'] != null) {
      if (json['user'] is Map<String, dynamic>) {
        user = User.fromJson(json['user'] as Map<String, dynamic>);
      } else if (json['user'] is String) {
        // Nếu user là string (ID), tạo một User object với ID đó
        user = User(
          id: json['user'] as String,
          username: 'Unknown',
          email: '',
        );
      }
    }

    // Xử lý trường comments
    List<RecipeComment> comments = [];
    if (json['comments'] != null) {
      comments = (json['comments'] as List).map((commentJson) {
        // Xử lý trường user trong comment
        if (commentJson['user'] is String) {
          commentJson = Map<String, dynamic>.from(commentJson);
          commentJson['user'] = {
            '_id': commentJson['user'],
            'username': 'Unknown',
            'email': '',
          };
        }
        return RecipeComment.fromJson(commentJson as Map<String, dynamic>);
      }).toList();
    }

    // Xử lý trường reactions
    List<Reaction> reactions = [];
    if (json['reactions'] != null) {
      reactions = (json['reactions'] as List).map((reactionJson) {
        // Xử lý trường user trong reaction
        if (reactionJson['user'] is String) {
          reactionJson = Map<String, dynamic>.from(reactionJson);
          reactionJson['user'] = {
            '_id': reactionJson['user'],
            'username': 'Unknown',
            'email': '',
          };
        }
        return Reaction.fromJson(reactionJson as Map<String, dynamic>);
      }).toList();
    }

    return Recipe(
      id: json['_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      imageUrl: json['imageUrl'] as String?,
      ingredients:
          (json['ingredients'] as List).map((e) => e as String).toList(),
      instructions:
          (json['instructions'] as List).map((e) => e as String).toList(),
      videoUrl: json['videoUrl'] as String?,
      user: user,
      tag: (json['tag'] as List).map((e) => e as String).toList(),
      prepTime: (json['prepTime'] as num?)?.toInt(),
      cookTime: (json['cookTime'] as num?)?.toInt(),
      difficulty: json['difficulty'] as String?,
      averageRating: Recipe._ratingFromJson(json['averageRating']),
      ratingCount: Recipe._ratingCountFromJson(json['ratingCount']),
      createdAt: DateTime.parse(json['createdAt'] as String),
      comments: comments,
      reactions: reactions,
      isReacted: json['isReacted'] as bool? ?? false,
      reactionCount: (json['reactionCount'] as num?)?.toInt() ?? 0,
    );
  }

  Recipe copyWith({
    String? id,
    String? title,
    String? description,
    List<String>? ingredients,
    List<String>? instructions,
    String? imageUrl,
    String? videoUrl,
    List<String>? tag,
    int? prepTime,
    int? cookTime,
    String? difficulty,
    User? user,
    DateTime? createdAt,
    List<RecipeComment>? comments,
    List<Reaction>? reactions,
    bool? isReacted,
    int? reactionCount,
    double? averageRating,
    int? ratingCount,
  }) {
    return Recipe(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      ingredients: ingredients ?? this.ingredients,
      instructions: instructions ?? this.instructions,
      imageUrl: imageUrl ?? this.imageUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      user: user ?? this.user,
      tag: tag ?? this.tag,
      prepTime: prepTime ?? this.prepTime,
      cookTime: cookTime ?? this.cookTime,
      difficulty: difficulty ?? this.difficulty,
      createdAt: createdAt ?? this.createdAt,
      comments: comments ?? this.comments,
      reactions: reactions ?? this.reactions,
      isReacted: isReacted ?? this.isReacted,
      reactionCount: reactionCount ?? this.reactionCount,
      averageRating: averageRating ?? this.averageRating,
      ratingCount: ratingCount ?? this.ratingCount,
    );
  }

  Map<String, dynamic> toJson() => _$RecipeToJson(this);
}

@JsonSerializable()
class User {
  @JsonKey(name: '_id')
  final String id;
  final String username;
  final String email;

  User({
    required this.id,
    required this.username,
    required this.email,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);
}

@JsonSerializable()
class RecipeComment {
  @JsonKey(name: '_id')
  final String id;
  final User? user;
  final String? content;
  final DateTime createdAt;

  RecipeComment({
    required this.id,
    this.user,
    this.content,
    required this.createdAt,
  });

  factory RecipeComment.fromJson(Map<String, dynamic> json) =>
      _$RecipeCommentFromJson(json);

  Map<String, dynamic> toJson() => _$RecipeCommentToJson(this);
}

@JsonSerializable()
class Reaction {
  final User user;
  final DateTime createdAt;

  Reaction({
    required this.user,
    required this.createdAt,
  });

  factory Reaction.fromJson(Map<String, dynamic> json) =>
      _$ReactionFromJson(json);

  Map<String, dynamic> toJson() => _$ReactionToJson(this);
}
