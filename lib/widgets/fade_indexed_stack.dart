import 'package:flutter/material.dart';

class FadeIndexedStack extends StatefulWidget {
  final int index;
  final List<Widget> children;
  final Duration duration;

  const FadeIndexedStack({
    super.key,
    required this.index,
    required this.children,
    this.duration = const Duration(milliseconds: 300),
  });

  @override
  State<FadeIndexedStack> createState() => _FadeIndexedStackState();
}

class _FadeIndexedStackState extends State<FadeIndexedStack> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _currentIndex = 0;
  int _previousIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.index;
    _previousIndex = widget.index;
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..forward(from: 1.0);
  }

  @override
  void didUpdateWidget(covariant FadeIndexedStack oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.index != widget.index) {
      _previousIndex = _currentIndex;
      _currentIndex = widget.index;
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          fit: StackFit.expand,
          children: List.generate(widget.children.length, (i) {
            final child = widget.children[i];
            // Only render children that are actively participating in the fade or are fully visible
            if (i == _currentIndex) {
              return Opacity(
                opacity: _controller.value,
                child: Offstage(
                  offstage: false,
                  child: child,
                ),
              );
            } else if (i == _previousIndex) {
              return Opacity(
                opacity: 1.0 - _controller.value,
                child: Offstage(
                  offstage: _controller.value == 1.0,
                  child: child,
                ),
              );
            } else {
              return Offstage(
                offstage: true,
                child: child,
              );
            }
          }),
        );
      },
    );
  }
}
