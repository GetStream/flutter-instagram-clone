import 'dart:convert';

import 'package:flutter/material.dart';

/// Data model for a feed user's extra data.
@immutable
class StreamagramUser {
  /// Data model for a feed user's extra data.
  const StreamagramUser({
    required this.firstName,
    required this.lastName,
    required this.fullName,
    required this.profilePhoto,
    required this.profilePhotoResized,
    required this.profilePhotoThumbnail,
  });

  /// Converts a Map to this.
  factory StreamagramUser.fromMap(Map<String, dynamic> map) {
    return StreamagramUser(
      firstName: map['first_name'] as String? ?? 'No name',
      lastName: map['last_name'] as String? ?? 'No last name',
      fullName: map['full_name'] as String? ?? 'No full name',
      profilePhoto: map['profile_photo'] as String?,
      profilePhotoResized: map['profile_photo_resized'] as String?,
      profilePhotoThumbnail: map['profile_photo_thumbnail'] as String?,
    );
  }

  /// Converts json to this.
  factory StreamagramUser.fromJson(String source) =>
      StreamagramUser.fromMap(json.decode(source) as Map<String, dynamic>);

  /// User's first name
  final String firstName;

  /// User's last name
  final String lastName;

  /// User's full name
  final String fullName;

  /// URL to user's profile photo.
  final String? profilePhoto;

  /// A 500x500 version of the [profilePhoto].
  final String? profilePhotoResized;

  /// A small thumbnail version of the [profilePhoto].
  final String? profilePhotoThumbnail;

  /// Convenient method to replace certain fields.
  StreamagramUser copyWith({
    String? firstName,
    String? lastName,
    String? fullName,
    String? profilePhoto,
    String? profilePhotoResized,
    String? profilePhotoThumbnail,
  }) {
    return StreamagramUser(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      fullName: fullName ?? this.fullName,
      profilePhoto: profilePhoto ?? this.profilePhoto,
      profilePhotoResized: profilePhotoResized ?? this.profilePhotoResized,
      profilePhotoThumbnail:
          profilePhotoThumbnail ?? this.profilePhotoThumbnail,
    );
  }

  /// Converts this model to a Map.
  Map<String, dynamic> toMap() {
    return {
      'first_name': firstName,
      'last_name': lastName,
      'full_name': fullName,
      'profile_photo': profilePhoto,
      'profile_photo_resized': profilePhotoResized,
      'profile_photo_thumbnail': profilePhotoThumbnail,
    };
  }

  /// Converts this class to json.
  String toJson() => json.encode(toMap());

  @override
  String toString() {
    return '''UserData(firstName: $firstName, lastName: $lastName, fullName: $fullName, profilePhoto: $profilePhoto, profilePhotoResized: $profilePhotoResized, profilePhotoThumbnail: $profilePhotoThumbnail)''';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is StreamagramUser &&
        other.firstName == firstName &&
        other.lastName == lastName &&
        other.fullName == fullName &&
        other.profilePhoto == profilePhoto &&
        other.profilePhotoResized == profilePhotoResized &&
        other.profilePhotoThumbnail == profilePhotoThumbnail;
  }

  @override
  int get hashCode {
    return firstName.hashCode ^
        lastName.hashCode ^
        fullName.hashCode ^
        profilePhoto.hashCode ^
        profilePhotoResized.hashCode ^
        profilePhotoThumbnail.hashCode;
  }
}
