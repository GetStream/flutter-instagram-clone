import 'package:flutter/material.dart';
import 'package:stream_agram/app/app.dart';
import 'package:stream_agram/components/app_widgets/app_widgets.dart';
import 'package:stream_feed_flutter_core/stream_feed_flutter_core.dart';

import 'widgets/widgets.dart';

/// {@template timeline_page}
/// Page to display a timeline of user created posts. Global 'timeline'
/// {@endtemplate}
class TimelinePage extends StatefulWidget {
  /// {@macro timeline_page}
  const TimelinePage({Key? key}) : super(key: key);

  @override
  State<TimelinePage> createState() => _TimelinePageState();
}

class _TimelinePageState extends State<TimelinePage> {
  final ValueNotifier<bool> _showCommentBox = ValueNotifier(false);
  final TextEditingController _commentTextController = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();
  EnrichedActivity? activeActivity;
  bool _isPaginating = false;

  static const _feedGroup = 'timeline';
  static final _flags = EnrichmentFlags()
    ..withOwnReactions()
    ..withRecentReactions()
    ..withReactionCounts();

  void openCommentBox(EnrichedActivity activity, {String? message}) {
    _commentTextController.text = message ?? '';
    _commentTextController.selection = TextSelection.fromPosition(
        TextPosition(offset: _commentTextController.text.length));
    activeActivity = activity;
    _showCommentBox.value = true;
    _commentFocusNode.requestFocus();
  }

  Future<void> addComment(String? message) async {
    if (activeActivity != null &&
        message != null &&
        message.isNotEmpty &&
        message != '') {
      await FeedProvider.of(context).bloc.onAddReaction(
        kind: 'comment',
        activity: activeActivity!,
        feedGroup: 'timeline',
        data: {'message': message},
      );
      _commentTextController.clear();
      if (!mounted) return;
      FocusScope.of(context).unfocus();
      _showCommentBox.value = false;
    }
  }

  Future<void> _loadMore() async {
    // Ensure we're not already loading more activities.
    if (!_isPaginating) {
      _isPaginating = true;
      context.feedBloc
          .loadMoreEnrichedActivities(feedGroup: _feedGroup, flags: _flags)
          .whenComplete(() {
        _isPaginating = false;
      });
    }
  }

  @override
  void dispose() {
    _commentTextController.dispose();
    _commentFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        _showCommentBox.value = false;
      },
      child: Stack(
        children: [
          FlatFeedCore(
            feedGroup: _feedGroup,
            errorBuilder: (context, error) =>
                const Text('Could not load profile'),
            loadingBuilder: (context) => const SizedBox(),
            emptyBuilder: (context) => const Center(
              child: Text('No Posts\nGo and post something'),
            ),
            flags: _flags,
            feedBuilder: (context, activities) {
              return RefreshIndicator(
                onRefresh: () {
                  return FeedProvider.of(context)
                      .bloc
                      .refreshPaginatedEnrichedActivities(
                        feedGroup: 'timeline',
                        flags: EnrichmentFlags()
                          ..withOwnReactions()
                          ..withRecentReactions()
                          ..withReactionCounts(),
                      );
                },
                child: ListView.builder(
                  itemCount: activities.length,
                  itemBuilder: (context, index) {
                    // Pagination (Infinite scroll)
                    bool shouldLoadMore = activities.length - 3 == index;
                    if (shouldLoadMore) {
                      _loadMore();
                    }

                    return PostCard(
                      key: ValueKey('post-${activities[index].id}'),
                      enrichedActivity: activities[index],
                      onAddComment: openCommentBox,
                    );
                  },
                ),
              );
            },
          ),
          _CommentBox(
            commenter: context.appState.streamagramUser!,
            textEditingController: _commentTextController,
            focusNode: _commentFocusNode,
            addComment: addComment,
            showCommentBox: _showCommentBox,
          )
        ],
      ),
    );
  }
}

class _CommentBox extends StatefulWidget {
  const _CommentBox({
    Key? key,
    required this.commenter,
    required this.textEditingController,
    required this.focusNode,
    required this.addComment,
    required this.showCommentBox,
  }) : super(key: key);

  final StreamagramUser commenter;
  final TextEditingController textEditingController;
  final FocusNode focusNode;
  final Function(String?) addComment;
  final ValueNotifier<bool> showCommentBox;

  @override
  __CommentBoxState createState() => __CommentBoxState();
}

class __CommentBoxState extends State<_CommentBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  late final Animation<double> _animation = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOut,
    reverseCurve: Curves.easeIn,
  );

  bool visibility = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.dismissed) {
        setState(() {
          visibility = false;
        });
      } else {
        setState(() {
          visibility = true;
        });
      }
    });
    widget.showCommentBox.addListener(_showHideCommentBox);
  }

  void _showHideCommentBox() {
    if (widget.showCommentBox.value) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: visibility,
      child: FadeTransition(
        opacity: _animation,
        child: Builder(builder: (context) {
          return Align(
            alignment: Alignment.bottomCenter,
            child: CommentBox(
              commenter: widget.commenter,
              textEditingController: widget.textEditingController,
              focusNode: widget.focusNode,
              onSubmitted: widget.addComment,
            ),
          );
        }),
      ),
    );
  }
}
