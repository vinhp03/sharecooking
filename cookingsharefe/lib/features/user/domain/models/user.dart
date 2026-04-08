import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  @JsonKey(name: '_id')
  final String id;
  final String username;
  final String email;
  final List<String> following;
  final List<String> followers;
  @JsonKey(name: 'favouriterecipe')
  final List<String> favoriteRecipes;
  @JsonKey(name: 'favouritecount')
  final int favoriteCount;
  final int followersCount;
  final int followingCount;
  @JsonKey(name: 'updatedAt')
  final DateTime updatedAt;
  @JsonKey(defaultValue: '')
  final String? avatar;
  @JsonKey(defaultValue: '')
  final String? bio;
  @JsonKey(defaultValue: false)
  final bool isFollowing;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.following,
    required this.followers,
    required this.favoriteRecipes,
    required this.favoriteCount,
    required this.followersCount,
    required this.followingCount,
    required this.updatedAt,
    this.avatar,
    this.bio,
    this.isFollowing = false,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);

  User copyWith({
    String? id,
    String? username,
    String? email,
    List<String>? following,
    List<String>? followers,
    List<String>? favoriteRecipes,
    int? favoriteCount,
    int? followersCount,
    int? followingCount,
    DateTime? updatedAt,
    String? avatar,
    String? bio,
    bool? isFollowing,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      following: following ?? this.following,
      followers: followers ?? this.followers,
      favoriteRecipes: favoriteRecipes ?? this.favoriteRecipes,
      favoriteCount: favoriteCount ?? this.favoriteCount,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      updatedAt: updatedAt ?? this.updatedAt,
      avatar: avatar ?? this.avatar,
      bio: bio ?? this.bio,
      isFollowing: isFollowing ?? this.isFollowing,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          username == other.username &&
          email == other.email &&
          avatar == other.avatar &&
          bio == other.bio &&
          updatedAt == other.updatedAt &&
          followersCount == other.followersCount &&
          followingCount == other.followingCount &&
          favoriteCount == other.favoriteCount &&
          isFollowing == other.isFollowing;

  @override
  int get hashCode =>
      id.hashCode ^
      username.hashCode ^
      email.hashCode ^
      avatar.hashCode ^
      bio.hashCode ^
      updatedAt.hashCode ^
      followersCount.hashCode ^
      followingCount.hashCode ^
      favoriteCount.hashCode ^
      isFollowing.hashCode;
}
