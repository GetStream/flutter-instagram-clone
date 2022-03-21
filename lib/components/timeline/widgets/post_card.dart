import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:provider/provider.dart';
import 'package:stream_feed_flutter_core/stream_feed_flutter_core.dart';

import '../../../app/app.dart';
import '../../app_widgets/app_widgets.dart';
import '../../comments/comments_screen.dart';

typedef OnAddComment = void Function(
  EnrichedActivity activity, {
  String? message,
});

/// {@template post_card}
/// A card that displays a user post/activity.
/// {@endtemplate}
class PostCard extends StatelessWidget {
  /// {@macro post_card}
  const PostCard({
    Key? key,
    required this.enrichedActivity,
    required this.onAddComment,
  }) : super(key: key);

  /// Enriched activity (post) to display.
  final EnrichedActivity enrichedActivity;
  final OnAddComment onAddComment;

  @override
  Widget build(BuildContext context) {
    final actorData = enrichedActivity.actor!.data;
    final userData = StreamagramUser.fromMap(actorData as Map<String, dynamic>);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ProfileSlab(
          userData: userData,
        ),
        _PictureCarousal(
          enrichedActivity: enrichedActivity,
        ),
        _Description(
          enrichedActivity: enrichedActivity,
        ),
        _InteractiveCommentSlab(
          enrichedActivity: enrichedActivity,
          onAddComment: onAddComment,
        ),
      ],
    );
  }
}

class _PictureCarousal extends StatefulWidget {
  const _PictureCarousal({
    Key? key,
    required this.enrichedActivity,
  }) : super(key: key);

  final EnrichedActivity enrichedActivity;

  @override
  __PictureCarousalState createState() => __PictureCarousalState();
}

class __PictureCarousalState extends State<_PictureCarousal> {
  late var likeReactions = getLikeReactions() ?? [];
  late var likeCount = getLikeCount() ?? 0;

  Reaction? latestLikeReaction;

  List<Reaction>? getLikeReactions() {
    return widget.enrichedActivity.latestReactions?['like'] ?? [];
  }

  int? getLikeCount() {
    return widget.enrichedActivity.reactionCounts?['like'] ?? 0;
  }

  Future<void> _addLikeReaction() async {
    latestLikeReaction = await context.appState.client.reactions.add(
      'like',
      widget.enrichedActivity.id!,
      userId: context.appState.user.id,
    );

    setState(() {
      likeReactions.add(latestLikeReaction!);
      likeCount++;
    });
  }

  Future<void> _removeLikeReaction() async {
    late String? reactionId;
    // A new reaction was added to this state.
    if (latestLikeReaction != null) {
      reactionId = latestLikeReaction?.id;
    } else {
      // An old reaction has been retrieved from Stream.
      final prevReaction = widget.enrichedActivity.ownReactions?['like'];
      if (prevReaction != null && prevReaction.isNotEmpty) {
        reactionId = prevReaction[0].id;
      }
    }

    try {
      if (reactionId != null) {
        await context.appState.client.reactions.delete(reactionId);
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    setState(() {
      likeReactions.removeWhere((element) => element.id == reactionId);
      likeCount--;
      latestLikeReaction = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ..._pictureCarousel(context),
        _likes(),
      ],
    );
  }

  /// Picture carousal and interaction buttons.
  List<Widget> _pictureCarousel(BuildContext context) {
    const iconPadding = EdgeInsets.symmetric(horizontal: 8, vertical: 4);
    var imageUrl = widget.enrichedActivity.extraData!['image_url'] as String;
    double aspectRatio =
        widget.enrichedActivity.extraData!['aspect_ratio'] as double? ?? 1.0;
    final iconColor = Theme.of(context).iconTheme.color!;
    return [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 500),
            child: AspectRatio(
              aspectRatio: aspectRatio,
              child: CachedNetworkImage(
                imageUrl: imageUrl,
              ),
            ),
          ),
        ),
      ),
      Row(
        children: [
          const SizedBox(
            width: 4,
          ),
          Padding(
            padding: iconPadding,
            child: FavoriteIconButton(
              isLiked: widget.enrichedActivity.ownReactions?['like'] != null,
              onTap: (liked) {
                if (liked) {
                  _addLikeReaction();
                } else {
                  _removeLikeReaction();
                }
              },
            ),
          ),
          Padding(
            padding: iconPadding,
            child: TapFadeIcon(
              onTap: () {
                // ADD THIS
                final map = widget.enrichedActivity.actor!.data!;

                // AND THIS
                Navigator.of(context).push(
                  CommentsScreen.route(
                    enrichedActivity: widget.enrichedActivity,
                    activityOwnerData: StreamagramUser.fromMap(map),
                  ),
                );
              },
              icon: Icons.chat_bubble_outline,
              iconColor: iconColor,
            ),
          ),
          Padding(
            padding: iconPadding,
            child: TapFadeIcon(
              onTap: () =>
                  context.removeAndShowSnackbar('Message: Not yet implemented'),
              icon: Icons.call_made,
              iconColor: iconColor,
            ),
          ),
          const Spacer(),
          Padding(
            padding: iconPadding,
            child: TapFadeIcon(
              onTap: () => context
                  .removeAndShowSnackbar('Bookmark: Not yet implemented'),
              icon: Icons.bookmark_border,
              iconColor: iconColor,
            ),
          ),
        ],
      )
    ];
  }

  Widget _likes() {
    if (likeReactions.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.only(left: 16.0, top: 8),
        child: Text.rich(
          TextSpan(
            text: 'Liked by ',
            style: AppTextStyle.textStyleLight,
            children: <TextSpan>[
              TextSpan(
                  text: StreamagramUser.fromMap(
                          likeReactions[0].user?.data as Map<String, dynamic>)
                      .fullName,
                  style: AppTextStyle.textStyleBold),
              if (likeCount > 1 && likeCount < 3) ...[
                const TextSpan(text: ' and '),
                TextSpan(
                    text: StreamagramUser.fromMap(
                            likeReactions[1].user?.data as Map<String, dynamic>)
                        .fullName,
                    style: AppTextStyle.textStyleBold),
              ],
              if (likeCount > 3) ...[
                const TextSpan(text: ' and '),
                const TextSpan(
                    text: 'others', style: AppTextStyle.textStyleBold),
              ],
            ],
          ),
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}

class _Description extends StatelessWidget {
  const _Description({
    Key? key,
    required this.enrichedActivity,
  }) : super(key: key);

  final EnrichedActivity enrichedActivity;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6),
      child: Text.rich(
        TextSpan(
          children: <TextSpan>[
            TextSpan(
                text: enrichedActivity.actor!.id!,
                style: AppTextStyle.textStyleBold),
            const TextSpan(text: ' '),
            TextSpan(
                text: enrichedActivity.extraData?['description'] as String? ??
                    ''),
          ],
        ),
      ),
    );
  }
}

class _InteractiveCommentSlab extends StatefulWidget {
  const _InteractiveCommentSlab({
    Key? key,
    required this.enrichedActivity,
    required this.onAddComment,
  }) : super(key: key);

  final EnrichedActivity enrichedActivity;
  final OnAddComment onAddComment;

  @override
  _InteractiveCommentSlabState createState() => _InteractiveCommentSlabState();
}

class _InteractiveCommentSlabState extends State<_InteractiveCommentSlab> {
  EnrichedActivity get enrichedActivity => widget.enrichedActivity;

  late final String _timeSinceMessage =
      Jiffy(widget.enrichedActivity.time).fromNow();

  List<Reaction> get _commentReactions =>
      enrichedActivity.latestReactions?['comment'] ?? [];

  int get _commentCount => enrichedActivity.reactionCounts?['comment'] ?? 0;

  @override
  Widget build(BuildContext context) {
    const textPadding = EdgeInsets.all(8);
    const spacePadding = EdgeInsets.only(left: 20.0, top: 8);
    final comments = _commentReactions;
    final commentCount = _commentCount;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (commentCount > 0 && comments.isNotEmpty)
          Padding(
            padding: spacePadding,
            child: Text.rich(
              TextSpan(
                children: <TextSpan>[
                  TextSpan(
                      text: StreamagramUser.fromMap(
                              comments[0].user?.data as Map<String, dynamic>)
                          .fullName,
                      style: AppTextStyle.textStyleBold),
                  const TextSpan(text: '  '),
                  TextSpan(text: comments[0].data?['message'] as String?),
                ],
              ),
            ),
          ),
        if (commentCount > 1 && comments.isNotEmpty)
          Padding(
            padding: spacePadding,
            child: Text.rich(
              TextSpan(
                children: <TextSpan>[
                  TextSpan(
                      text: StreamagramUser.fromMap(
                              comments[1].user?.data as Map<String, dynamic>)
                          .fullName,
                      style: AppTextStyle.textStyleBold),
                  const TextSpan(text: '  '),
                  TextSpan(text: comments[1].data?['message'] as String?),
                ],
              ),
            ),
          ),
        if (commentCount > 2)
          Padding(
            padding: spacePadding,
            child: GestureDetector(
              onTap: () {
                final map =
                    widget.enrichedActivity.actor!.data as Map<String, dynamic>;
                // AND THIS
                Navigator.of(context).push(CommentsScreen.route(
                  enrichedActivity: widget.enrichedActivity,
                  activityOwnerData: StreamagramUser.fromMap(map),
                ));
              },
              child: Text(
                'View all $commentCount comments',
                style: AppTextStyle.textStyleFaded,
              ),
            ),
          ),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            widget.onAddComment(enrichedActivity);
          },
          child: Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 3, right: 8),
            child: Row(
              children: [
                const _ProfilePicture(),
                const Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: 8.0),
                    child: Text(
                      'Add a comment',
                      style: TextStyle(
                        color: AppColors.faded,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    widget.onAddComment(enrichedActivity, message: '❤️');
                  },
                  child: const Padding(
                    padding: textPadding,
                    child: Text('❤️'),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    widget.onAddComment(enrichedActivity, message: '🙌');
                  },
                  child: const Padding(
                    padding: textPadding,
                    child: Text('🙌'),
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 16.0, top: 4),
          child: Text(
            _timeSinceMessage,
            style: const TextStyle(
              color: AppColors.faded,
              fontWeight: FontWeight.w400,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfilePicture extends StatelessWidget {
  const _ProfilePicture({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final streamagramUser = context.watch<AppState>().streamagramUser;
    if (streamagramUser == null) {
      return const Icon(Icons.error);
    }
    return Avatar.small(
      streamagramUser: streamagramUser,
    );
  }
}

class _ProfileSlab extends StatelessWidget {
  const _ProfileSlab({
    Key? key,
    required this.userData,
  }) : super(key: key);

  final StreamagramUser userData;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 16.0),
      child: Row(
        children: [
          Avatar.medium(streamagramUser: userData),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              userData.fullName,
              style: AppTextStyle.textStyleBold,
            ),
          ),
          const Spacer(),
          TapFadeIcon(
            onTap: () => context.removeAndShowSnackbar('Not part of the demo'),
            icon: Icons.more_horiz,
            iconColor: Theme.of(context).iconTheme.color!,
          ),
        ],
      ),
    );
  }
}
