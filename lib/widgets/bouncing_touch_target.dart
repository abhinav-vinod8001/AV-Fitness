import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A touch target that physically scales down when pressed, mimicking a natural
/// physics-based interaction (like iOS buttons or Spotify's design language).
/// It provides a much more premium, human feel than a flat ripple.
class BouncingTouchTarget extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final double scaleDownFactor;
  final Duration duration;

  const BouncingTouchTarget({
    super.key,
    required this.child,
    required this.onTap,
    this.scaleDownFactor = 0.95,
    this.duration = const Duration(milliseconds: 150),
  });

  @override
  State<BouncingTouchTarget> createState() => _BouncingTouchTargetState();
}

class _BouncingTouchTargetState extends State<BouncingTouchTarget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
      reverseDuration: widget.duration,
    );
    
    _scaleAnimation = Tween<double>(begin: 1.0, end: widget.scaleDownFactor).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeOutCubic,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    HapticFeedback.lightImpact();
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onTap();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }
}
