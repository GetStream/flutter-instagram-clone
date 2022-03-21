import 'package:flutter/material.dart';
import 'package:stream_feed_flutter_core/stream_feed_flutter_core.dart';
import 'models/models.dart';

import 'demo_users.dart';

/// State related to Stream-agram app.
///
/// Manages the connection and stores a references to the [StreamFeedClient]
/// and [StreamagramUser].
///
/// Provides various convenience methods.
class AppState extends ChangeNotifier {
  /// Create new [AppState].
  AppState({
    required StreamFeedClient client,
  }) : _client = client;

  late final StreamFeedClient _client;

  /// Stream Feed client.
  StreamFeedClient get client => _client;

  /// Stream Feed user - [StreamUser].
  StreamUser get user => _client.currentUser!;

  StreamagramUser? _streamagramUser;
  var isUploadingProfilePicture = false;

  /// The extraData from [user], mapped to an [StreamagramUser] object.
  StreamagramUser? get streamagramUser => _streamagramUser;

  /// Current user's [FlatFeed] with name 'user'.
  ///
  /// This feed contains all of a user's personal posts.
  FlatFeed get currentUserFeed => _client.flatFeed('user', user.id);

  /// Current user's [FlatFeed] with name 'timeline'.
  ///
  /// This contains all posts that a user has subscribed (followed) to.
  FlatFeed get currentTimelineFeed => _client.flatFeed('timeline', user.id);

  /// Connect to Stream Feed with one of the demo users, using a predefined,
  /// hardcoded token.
  ///
  /// THIS IS ONLY FOR DEMONSTRATIONS PURPOSES. USER TOKENS SHOULD NOT BE
  /// HARDCODED LIKE THIS.
  Future<bool> connect(DemoAppUser demoUser) async {
    final currentUser = await _client.setUser(
      User(id: demoUser.id),
      demoUser.token!,
      extraData: demoUser.data,
    );

    if (currentUser.data != null) {
      _streamagramUser = StreamagramUser.fromMap(currentUser.data!);
      await currentTimelineFeed.follow(currentUserFeed);
      notifyListeners();
      return true;
    } else {
      return false;
    }
  }

  /// Uploads a new profile picture from the given [filePath].
  ///
  /// This will call [notifyListeners] and update the local [_streamagramUser] state.
  Future<void> updateProfilePhoto(String filePath) async {
    // Upload the original image
    isUploadingProfilePicture = true;
    notifyListeners();

    final imageUrl = await client.images.upload(AttachmentFile(path: filePath));
    if (imageUrl == null) {
      debugPrint('Could not upload the image. Not setting profile picture');
      isUploadingProfilePicture = false;
      notifyListeners();
      return;
    }
    // Get resized images using the Stream Feed client.
    final results = await Future.wait([
      client.images.getResized(
        imageUrl,
        const Resize(500, 500),
      ),
      client.images.getResized(
        imageUrl,
        const Resize(50, 50),
      )
    ]);

    // Update the current user data state.
    _streamagramUser = _streamagramUser?.copyWith(
      profilePhoto: imageUrl,
      profilePhotoResized: results[0],
      profilePhotoThumbnail: results[1],
    );

    isUploadingProfilePicture = false;

    // Upload the new user data for the current user.
    if (_streamagramUser != null) {
      await client.currentUser!.update(_streamagramUser!.toMap());
    }

    notifyListeners();
  }
}
