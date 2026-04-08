// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
      id: json['_id'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      following:
          (json['following'] as List<dynamic>).map((e) => e as String).toList(),
      followers:
          (json['followers'] as List<dynamic>).map((e) => e as String).toList(),
      favoriteRecipes: (json['favouriterecipe'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      favoriteCount: (json['favouritecount'] as num).toInt(),
      followersCount: (json['followersCount'] as num).toInt(),
      followingCount: (json['followingCount'] as num).toInt(),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      avatar: json['avatar'] as String? ?? '',
      bio: json['bio'] as String? ?? '',
      isFollowing: json['isFollowing'] as bool? ?? false,
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      '_id': instance.id,
      'username': instance.username,
      'email': instance.email,
      'following': instance.following,
      'followers': instance.followers,
      'favouriterecipe': instance.favoriteRecipes,
      'favouritecount': instance.favoriteCount,
      'followersCount': instance.followersCount,
      'followingCount': instance.followingCount,
      'updatedAt': instance.updatedAt.toIso8601String(),
      'avatar': instance.avatar,
      'bio': instance.bio,
      'isFollowing': instance.isFollowing,
    };
