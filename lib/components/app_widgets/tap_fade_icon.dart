import 'package:flutter/material.dart';

/// {@template tap_fade_icon}
/// A tappable icon that fades colors when tapped and held.
/// {@endtemplate}
class TapFadeIcon extends StatefulWidget {
  /// {@macro tap_fade_icon}
  const TapFadeIcon({
    Key? key,
    required this.onTap,
    required this.icon,
    required this.iconColor,
    this.size = 22,
  }) : super(key: key);

  /// Callback to handle tap.
  final VoidCallback onTap;

  /// Color of the icon.
  final Color iconColor;

  /// Type of icon.
  final IconData icon;

  /// Icon size.
  final double size;

  @override
  _TapFadeIconState createState() => _TapFadeIconState();
}

class _TapFadeIconState extends State<TapFadeIcon> {
  late Color color = widget.iconColor;

  void handleTapDown(TapDownDetails _) {
    setState(() {
      color = widget.iconColor.withOpacity(0.7);
    });
  }

  void handleTapUp(TapUpDetails _) {
    setState(() {
      color = widget.iconColor;
    });

    widget.onTap(); // Execute callback.
  }

  @override
  void didUpdateWidget(covariant TapFadeIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.iconColor != widget.iconColor) {
      color = widget.iconColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: handleTapDown,
      onTapUp: handleTapUp,
      child: Icon(
        widget.icon,
        color: color,
        size: widget.size,
      ),
    );
  }
}
