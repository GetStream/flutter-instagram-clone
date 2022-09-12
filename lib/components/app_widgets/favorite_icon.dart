import 'package:flutter/material.dart';
import 'package:stream_agram/app/theme.dart';

/// {@template favorite_icon_button}
/// Animated button to indicate if a post/comment is liked.
///
/// Pass in onPressed to
/// {@endtemplate}
class FavoriteIconButton extends StatefulWidget {
  /// {@macro favorite_icon_button}
  const FavoriteIconButton({
    Key? key,
    required this.isLiked,
    this.size = 22,
    required this.onTap,
  }) : super(key: key);

  /// Indicates if it is liked or not.
  final bool isLiked;

  /// Size of the icon.
  final double size;

  /// onTap callback. Returns a value to indicate if liked or not.
  final Function(bool val) onTap;

  @override
  State<FavoriteIconButton> createState() => _FavoriteIconButtonState();
}

class _FavoriteIconButtonState extends State<FavoriteIconButton> {
  late bool isLiked = widget.isLiked;

  void _handleTap() {
    setState(() {
      isLiked = !isLiked;
    });
    widget.onTap(isLiked);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedCrossFade(
        firstCurve: Curves.easeIn,
        secondCurve: Curves.easeOut,
        firstChild: Icon(
          Icons.favorite,
          color: AppColors.like,
          size: widget.size,
        ),
        secondChild: Icon(
          Icons.favorite_outline,
          size: widget.size,
        ),
        crossFadeState:
            isLiked ? CrossFadeState.showFirst : CrossFadeState.showSecond,
        duration: const Duration(milliseconds: 200),
      ),
    );
  }
}
