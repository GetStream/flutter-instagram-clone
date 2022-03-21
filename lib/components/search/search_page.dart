import 'package:flutter/material.dart';
import 'package:stream_feed_flutter_core/stream_feed_flutter_core.dart';

import '../../app/app.dart';
import '../app_widgets/app_widgets.dart';

/// Page to find other users and follow/unfollow.
class SearchPage extends StatelessWidget {
  /// Create a new [SearchPage].
  const SearchPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final users = List<DemoAppUser>.from(DemoAppUser.values)
      ..removeWhere((it) => it.id == context.appState.user.id);
    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) {
        return _UserProfile(userId: users[index].id!);
      },
    );
  }
}

class _UserProfile extends StatefulWidget {
  const _UserProfile({
    Key? key,
    required this.userId,
  }) : super(key: key);

  final String userId;

  @override
  __UserProfileState createState() => __UserProfileState();
}

class __UserProfileState extends State<_UserProfile> {
  late StreamUser streamUser;
  late bool isFollowing;
  late Future<StreamagramUser> userDataFuture = getUser();

  Future<StreamagramUser> getUser() async {
    final userClient = context.appState.client.user(widget.userId);
    final futures = await Future.wait([
      userClient.get(),
      _isFollowingUser(widget.userId),
    ]);
    streamUser = futures[0] as StreamUser;
    isFollowing = futures[1] as bool;

    return StreamagramUser.fromMap(streamUser.data!);
  }

  /// Determine if the current authenticated user is following [user].
  Future<bool> _isFollowingUser(String userId) async {
    return FeedProvider.of(context).bloc.isFollowingFeed(followerId: userId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<StreamagramUser>(
      future: userDataFuture,
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return const SizedBox.shrink();
          default:
            if (snapshot.hasError) {
              return const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('Could not load profile'),
              );
            } else {
              final userData = snapshot.data;
              if (userData != null) {
                return _ProfileTile(
                  user: streamUser,
                  userData: userData,
                  isFollowing: isFollowing,
                );
              }
              return const SizedBox.shrink();
            }
        }
      },
    );
  }
}

class _ProfileTile extends StatefulWidget {
  const _ProfileTile({
    Key? key,
    required this.user,
    required this.userData,
    required this.isFollowing,
  }) : super(key: key);

  final StreamUser user;
  final StreamagramUser userData;
  final bool isFollowing;

  @override
  __ProfileTileState createState() => __ProfileTileState();
}

class __ProfileTileState extends State<_ProfileTile> {
  bool _isLoading = false;
  late bool _isFollowing = widget.isFollowing;

  Future<void> followOrUnfollowUser(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });
    if (_isFollowing) {
      final bloc = FeedProvider.of(context).bloc;
      await bloc.unfollowFeed(unfolloweeId: widget.user.id);
      _isFollowing = false;
    } else {
      await FeedProvider.of(context)
          .bloc
          .followFeed(followeeId: widget.user.id);
      _isFollowing = true;
    }
    FeedProvider.of(context).bloc.queryEnrichedActivities(
          feedGroup: 'timeline',
          flags: EnrichmentFlags()
            ..withOwnReactions()
            ..withRecentReactions()
            ..withReactionCounts(),
        );

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Avatar.medium(streamagramUser: widget.userData),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.user.id, style: AppTextStyle.textStyleBold),
              Text(
                widget.userData.fullName,
                style: AppTextStyle.textStyleFaded,
              ),
            ],
          ),
        ),
        const Spacer(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: _isLoading
              ? const CircularProgressIndicator(strokeWidth: 3)
              : OutlinedButton(
                  onPressed: () {
                    followOrUnfollowUser(context);
                  },
                  child: _isFollowing
                      ? const Text('Unfollow')
                      : const Text('Follow'),
                ),
        )
      ],
    );
  }
}
