import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stream_agram/components/profile/edit_profile_screen.dart';
import 'package:stream_feed_flutter_core/stream_feed_flutter_core.dart';

import '../../app/app.dart';
import '../app_widgets/app_widgets.dart';
import '../new_post/new_post.dart';

/// {@template profile_page}
/// User profile page. List of user created posts.
/// {@endtemplate}
class ProfilePage extends StatefulWidget {
  /// {@macro profile_page}
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isPaginating = false;

  static const _feedGroup = 'user';

  Future<void> _loadMore() async {
    // Ensure we're not already loading more activities.
    if (!_isPaginating) {
      _isPaginating = true;
      context.feedBloc
          .loadMoreEnrichedActivities(feedGroup: _feedGroup)
          .whenComplete(() {
        _isPaginating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FlatFeedCore(
      feedGroup: _feedGroup,
      limit: 12,
      loadingBuilder: (context) =>
          const Center(child: CircularProgressIndicator()),
      errorBuilder: (context, error) => const Center(
        child: Text('Error loading profile'),
      ),
      emptyBuilder: (context) => const CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _ProfileHeader(
              numberOfPosts: 0,
            ),
          ),
          SliverToBoxAdapter(
            child: _EditProfileButton(),
          ),
          SliverFillRemaining(child: _NoPostsMessage())
        ],
      ),
      feedBuilder: (context, activities) {
        return RefreshIndicator(
          onRefresh: () async {
            // Refresh follow counts
            await FeedProvider.of(context)
                .bloc
                .currentUser!
                .get(withFollowCounts: true);
            // Refresh activities
            if (!mounted) return;
            return FeedProvider.of(context)
                .bloc
                .refreshPaginatedEnrichedActivities(feedGroup: _feedGroup);
          },
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: _ProfileHeader(
                  numberOfPosts: activities.length,
                ),
              ),
              const SliverToBoxAdapter(
                child: _EditProfileButton(),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: 24),
              ),
              SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 1,
                  mainAxisSpacing: 1,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    // Pagination (Infinite scroll)
                    bool shouldLoadMore = activities.length - 3 == index;
                    if (shouldLoadMore) {
                      _loadMore();
                    }
                    final activity = activities[index];
                    final url =
                        activity.extraData!['resized_image_url'] as String;
                    return GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          HeroDialogRoute(
                            builder: (context) {
                              return _PictureViewer(activity: activity);
                            },
                          ),
                        );
                      },
                      child: Hero(
                        tag: 'hero-image-${activity.id}',
                        child: CachedNetworkImage(
                          key: ValueKey('image-${activity.id}'),
                          width: 200,
                          height: 200,
                          fit: BoxFit.cover,
                          imageUrl: url,
                        ),
                      ),
                    );
                  },
                  childCount: activities.length,
                ),
              )
            ],
          ),
        );
      },
    );
  }
}

class _EditProfileButton extends StatelessWidget {
  const _EditProfileButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: OutlinedButton(
        onPressed: () {
          Navigator.of(context).push(EditProfileScreen.route);
        },
        child: const Text('Edit Profile'),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    Key? key,
    required this.numberOfPosts,
  }) : super(key: key);

  final int numberOfPosts;

  static const _statitisticsPadding =
      EdgeInsets.symmetric(horizontal: 12, vertical: 8.0);

  @override
  Widget build(BuildContext context) {
    final feedState = context.watch<AppState>();
    final streamagramUser = feedState.streamagramUser;
    if (streamagramUser == null) return const SizedBox.shrink();
    return Column(
      children: [
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Avatar.big(
                streamagramUser: streamagramUser,
              ),
            ),
            const Spacer(),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: _statitisticsPadding,
                  child: Column(
                    children: [
                      Text(
                        '$numberOfPosts',
                        style: AppTextStyle.textStyleBold,
                      ),
                      const Text(
                        'Posts',
                        style: AppTextStyle.textStyleLight,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: _statitisticsPadding,
                  child: Column(
                    children: [
                      Text(
                        '${FeedProvider.of(context).bloc.currentUser?.followersCount ?? 0}',
                        style: AppTextStyle.textStyleBold,
                      ),
                      const Text(
                        'Followers',
                        style: AppTextStyle.textStyleLight,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: _statitisticsPadding,
                  child: Column(
                    children: [
                      Text(
                        '${FeedProvider.of(context).bloc.currentUser?.followingCount ?? 0}',
                        style: AppTextStyle.textStyleBold,
                      ),
                      const Text(
                        'Following',
                        style: AppTextStyle.textStyleLight,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(streamagramUser.fullName,
                style: AppTextStyle.textStyleBoldMedium),
          ),
        ),
      ],
    );
  }
}

class _NoPostsMessage extends StatelessWidget {
  const _NoPostsMessage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('This is too empty'),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).push(NewPostScreen.route); // ADD THIS
          },
          child: const Text('Add a post'),
        )
      ],
    );
  }
}

class _PictureViewer extends StatelessWidget {
  const _PictureViewer({
    Key? key,
    required this.activity,
  }) : super(key: key);

  final EnrichedActivity activity;

  @override
  Widget build(BuildContext context) {
    final resizedUrl = activity.extraData!['resized_image_url'] as String?;
    final fullSizeUrl = activity.extraData!['image_url'] as String;
    final aspectRatio = activity.extraData!['aspect_ratio'] as double?;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      extendBodyBehindAppBar: true,
      body: InteractiveViewer(
        child: Center(
          child: Hero(
            tag: 'hero-image-${activity.id}',
            createRectTween: (begin, end) {
              return CustomRectTween(begin: begin, end: end);
            },
            child: AspectRatio(
              aspectRatio: aspectRatio ?? 1,
              child: CachedNetworkImage(
                fadeInDuration: Duration.zero,
                placeholder: (resizedUrl != null)
                    ? (context, url) => CachedNetworkImage(
                          imageBuilder: (context, imageProvider) =>
                              DecoratedBox(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: imageProvider,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          imageUrl: resizedUrl,
                        )
                    : null,
                imageBuilder: (context, imageProvider) => DecoratedBox(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: imageProvider,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                imageUrl: fullSizeUrl,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
