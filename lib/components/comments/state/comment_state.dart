import 'package:flutter/material.dart';
import 'package:stream_feed_flutter_core/stream_feed_flutter_core.dart';

import '../../../app/state/models/models.dart';

/// Indicates the type of comment that was made.
/// Can be:
/// - Activity comment
/// - Reaction comment
enum TypeOfComment {
  /// Comment on an activity
  activityComment,

  /// Comment on a reaction
  reactionComment,
}

/// {@template comment_focus}
/// Information on the type of comment to make. This can be a comment on an
/// activity, or a comment on a reaction.
///
/// It also indicates the parent user on whom the comment is made.
/// {@endtemplate}
class CommentFocus {
  /// {@macro comment_focus}
  const CommentFocus({
    required this.typeOfComment,
    required this.id,
    required this.user,
    this.reaction,
  });

  final Reaction? reaction;

  /// Indicates the type of comment. See [TypeOfComment].
  final TypeOfComment typeOfComment;

  /// Activity or reaction id on which the comment is made.
  final String id;

  /// The user data of the parent activity or reaction.
  final StreamagramUser user;
}

/// {@template comment_state}
/// ChangeNotifier to facilitate posting comments to activities and reactions.
/// {@endtemplate}
class CommentState extends ChangeNotifier {
  /// {@macro comment_state}
  CommentState({
    required this.activityId,
    required this.activityOwnerData,
  });

  /// The id for this activity.
  final String activityId;

  /// UserData of whoever owns the activity.
  final StreamagramUser activityOwnerData;

  /// The type of commentFocus that is currently selected.

  late CommentFocus commentFocus = CommentFocus(
    typeOfComment: TypeOfComment.activityComment,
    id: activityId,
    user: activityOwnerData,
  );

  /// Sets the focus to which a comment will be posted to.
  ///
  /// See [postComment].
  void setCommentFocus(CommentFocus focus) {
    commentFocus = focus;
    notifyListeners();
  }

  /// Resets the comment focus to the parent activity.
  void resetCommentFocus() {
    commentFocus = CommentFocus(
      typeOfComment: TypeOfComment.activityComment,
      id: activityId,
      user: activityOwnerData,
    );
    notifyListeners();
  }
}
