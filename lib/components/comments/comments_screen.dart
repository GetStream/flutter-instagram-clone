import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:provider/provider.dart';
import 'package:stream_feed_flutter_core/stream_feed_flutter_core.dart';

import '../../app/app.dart';
import '../app_widgets/app_widgets.dart';
import 'state/state.dart';

/// Screen that shows all comments for a given post.
class CommentsScreen extends StatefulWidget {
  /// Creates a new [CommentsScreen].
  const CommentsScreen({
    Key? key,
    required this.enrichedActivity,
    required this.activityOwnerData,
  }) : super(key: key);

  final EnrichedActivity enrichedActivity;

  /// Owner / [User] of the activity.
  final StreamagramUser activityOwnerData;

  /// MaterialPageRoute to this screen.
  static Route route({
    required EnrichedActivity enrichedActivity,
    required StreamagramUser activityOwnerData,
  }) =>
      MaterialPageRoute(
        builder: (context) => CommentsScreen(
          enrichedActivity: enrichedActivity,
          activityOwnerData: activityOwnerData,
        ),
      );

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  late FocusNode commentFocusNode;
  late CommentState commentState;

  @override
  void initState() {
    super.initState();
    commentFocusNode = FocusNode();
    commentState = CommentState(
      activityId: widget.enrichedActivity.id!,
      activityOwnerData: widget.activityOwnerData,
    );
  }

  @override
  void dispose() {
    commentFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: commentState),
        ChangeNotifierProvider.value(value: commentFocusNode),
      ],
      child: GestureDetector(
        onTap: () {
          commentState.resetCommentFocus();
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Comments',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            elevation: 0.5,
            shadowColor: Colors.white,
          ),
          body: Stack(
            children: [
              _CommentsList(
                activityId: widget.enrichedActivity.id!,
              ),
              _CommentBox(
                enrichedActivity: widget.enrichedActivity,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CommentsList extends StatelessWidget {
  const _CommentsList({
    Key? key,
    required this.activityId,
  }) : super(key: key);

  final String activityId;

  @override
  Widget build(BuildContext context) {
    return ReactionListCore(
      lookupValue: activityId,
      kind: 'comment',
      loadingBuilder: (context) =>
          const Center(child: CircularProgressIndicator()),
      errorBuilder: (context, error) =>
          const Center(child: Text('Could not load comments.')),
      emptyBuilder: (context) =>
          const Center(child: Text('Be the first to add a comment.')),
      reactionsBuilder: (context, reactions) {
        return ListView.builder(
          itemCount: reactions.length + 1,
          itemBuilder: (context, index) {
            if (index == reactions.length) {
              // Bottom padding to ensure [CommentBox] does not obscure
              // visibility
              return const SizedBox(
                height: 120,
              );
            }
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: _CommentTile(
                key: ValueKey('comment-${reactions[index].id}'),
                reaction: reactions[index],
              ),
            );
          },
        );
      },
      flags: EnrichmentFlags()
        ..withOwnChildren()
        ..withOwnReactions()
        ..withRecentReactions(),
    );
  }
}

class _CommentBox extends StatefulWidget {
  const _CommentBox({
    Key? key,
    required this.enrichedActivity,
  }) : super(key: key);

  final EnrichedActivity enrichedActivity;

  @override
  __CommentBoxState createState() => __CommentBoxState();
}

class __CommentBoxState extends State<_CommentBox> {
  late final _commentTextController = TextEditingController();

  Future<void> handleSubmit(String? value) async {
    if (value != null && value.isNotEmpty) {
      _commentTextController.clear();
      FocusScope.of(context).unfocus();

      final commentState = context.read<CommentState>();
      final commentFocus = commentState.commentFocus;

      if (commentFocus.typeOfComment == TypeOfComment.activityComment) {
        await FeedProvider.of(context).bloc.onAddReaction(
          kind: 'comment',
          activity: widget.enrichedActivity,
          feedGroup: 'timeline',
          data: {'message': value},
        );
      } else if (commentFocus.typeOfComment == TypeOfComment.reactionComment) {
        if (commentFocus.reaction != null) {
          await FeedProvider.of(context).bloc.onAddChildReaction(
            kind: 'comment',
            reaction: commentFocus.reaction!,
            lookupValue: widget.enrichedActivity.id!,
            data: {'message': value},
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _commentTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final commentFocus =
        context.select((CommentState state) => state.commentFocus);

    final focusNode = context.watch<FocusNode>();

    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        color: (Theme.of(context).brightness == Brightness.light)
            ? AppColors.light
            : AppColors.dark,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, animation) {
                final tween =
                    Tween(begin: const Offset(0.0, 1.0), end: Offset.zero)
                        .chain(CurveTween(curve: Curves.easeOutQuint));
                final offsetAnimation = animation.drive(tween);
                return SlideTransition(
                  position: offsetAnimation,
                  child: child,
                );
              },
              child:
                  (commentFocus.typeOfComment == TypeOfComment.reactionComment)
                      ? _replyToBox(commentFocus, context)
                      : const SizedBox.shrink(),
            ),
            CommentBox(
              commenter: context.appState.streamagramUser!,
              textEditingController: _commentTextController,
              onSubmitted: handleSubmit,
              focusNode: focusNode,
            ),
            SizedBox(
              height: MediaQuery.of(context).padding.bottom,
            )
          ],
        ),
      ),
    );
  }

  Container _replyToBox(CommentFocus commentFocus, BuildContext context) {
    return Container(
      color: (Theme.of(context).brightness == Brightness.dark)
          ? AppColors.grey
          : AppColors.ligthGrey,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Text(
              'Replying to ${commentFocus.user.fullName}',
              style: AppTextStyle.textStyleFaded,
            ),
            const Spacer(),
            TapFadeIcon(
              onTap: () {
                context.read<CommentState>().resetCommentFocus();
              },
              icon: Icons.close,
              size: 16,
              iconColor: Theme.of(context).iconTheme.color!,
            ),
          ],
        ),
      ),
    );
  }
}

class _CommentTile extends StatefulWidget {
  const _CommentTile({
    Key? key,
    required this.reaction,
    this.canReply = true,
    this.isReplyToComment = false,
  }) : super(key: key);

  final Reaction reaction;
  final bool canReply;
  final bool isReplyToComment;
  @override
  __CommentTileState createState() => __CommentTileState();
}

class __CommentTileState extends State<_CommentTile> {
  late final userData = StreamagramUser.fromMap(widget.reaction.user!.data!);
  late final message = extractMessage;

  late final timeSince = _timeSinceComment();

  late int numberOfLikes = widget.reaction.childrenCounts?['like'] ?? 0;

  late bool isLiked = _isFavorited();
  Reaction? likeReaction;

  String _timeSinceComment() {
    final jiffyTime = Jiffy(widget.reaction.createdAt).fromNow();
    if (jiffyTime == 'a few seconds ago') {
      return 'just now';
    } else {
      return jiffyTime;
    }
  }

  String numberOfLikesMessage(int count) {
    if (count == 0) {
      return '';
    }
    if (count == 1) {
      return '1 like';
    } else {
      return '$count likes';
    }
  }

  String get extractMessage {
    final data = widget.reaction.data;
    if (data != null && data['message'] != null) {
      return data['message'] as String;
    } else {
      return '';
    }
  }

  bool _isFavorited() {
    likeReaction = widget.reaction.ownChildren?['like']?.first;
    return likeReaction != null;
  }

  Future<void> _handleFavorite(bool liked) async {
    if (isLiked && likeReaction != null) {
      await context.appState.client.reactions.delete(likeReaction!.id!);
      numberOfLikes--;
    } else {
      likeReaction = await context.appState.client.reactions.addChild(
        'like',
        widget.reaction.id!,
        userId: context.appState.user.id,
      );
      numberOfLikes++;
    }
    setState(() {
      isLiked = liked;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: (widget.isReplyToComment)
                  ? Avatar.tiny(streamagramUser: userData)
                  : Avatar.small(streamagramUser: userData),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            children: <TextSpan>[
                              TextSpan(
                                  text: userData.fullName,
                                  style: AppTextStyle.textStyleSmallBold),
                              const TextSpan(text: ' '),
                              TextSpan(
                                text: message,
                                style: const TextStyle(fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Center(
                          child: FavoriteIconButton(
                            isLiked: isLiked,
                            size: 14,
                            onTap: _handleFavorite,
                          ),
                        ),
                      )
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 80,
                          child: Text(
                            timeSince,
                            style: AppTextStyle.textStyleFadedSmall,
                          ),
                        ),
                        Visibility(
                          visible: numberOfLikes > 0,
                          child: SizedBox(
                            width: 60,
                            child: Text(
                              numberOfLikesMessage(numberOfLikes),
                              style: AppTextStyle.textStyleFadedSmall,
                            ),
                          ),
                        ),
                        Visibility(
                          visible: widget.canReply,
                          child: GestureDetector(
                            onTap: () {
                              context.read<CommentState>().setCommentFocus(
                                    CommentFocus(
                                      typeOfComment:
                                          TypeOfComment.reactionComment,
                                      id: widget.reaction.id!,
                                      user: StreamagramUser.fromMap(
                                          widget.reaction.user!.data!),
                                      reaction: widget.reaction,
                                    ),
                                  );

                              FocusScope.of(context)
                                  .requestFocus(context.read<FocusNode>());
                            },
                            child: const SizedBox(
                              width: 50,
                              child: Text(
                                'Reply',
                                style: AppTextStyle.textStyleFadedSmallBold,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(left: 34.0),
          child: _ChildCommentList(
              comments: widget.reaction.latestChildren?['comment']),
        ),
      ],
    );
  }
}

class _ChildCommentList extends StatelessWidget {
  const _ChildCommentList({
    Key? key,
    required this.comments,
  }) : super(key: key);

  final List<Reaction>? comments;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: comments
              ?.map(
                (reaction) => Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: _CommentTile(
                    key: ValueKey('comment-tile-${reaction.id}'),
                    reaction: reaction,
                    canReply: false,
                    isReplyToComment: true,
                  ),
                ),
              )
              .toList() ??
          [],
    );
  }
}
