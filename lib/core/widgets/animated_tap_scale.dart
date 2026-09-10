import 'package:flutter/material.dart';

import '../utils/app_haptics.dart';

/// A reusable wrapper widget that applies a subtle scale-down animation on tap,
/// providing premium tactile & visual micro-feedback.
///
/// Usage:
/// ```dart
/// AnimatedTapScale(
///   onTap: () => doSomething(),
///   child: MyButton(),
/// )
/// ```
class AnimatedTapScale extends StatefulWidget {
  const AnimatedTapScale({
    super.key,
    required this.child,
    required this.onTap,
    this.scaleFactor = 0.96,
    this.haptics = true,
    this.duration = const Duration(milliseconds: 100),
  });

  final Widget child;
  final VoidCallback onTap;
  final double scaleFactor;
  final bool haptics;
  final Duration duration;

  @override
  State<AnimatedTapScale> createState() => _AnimatedTapScaleState();
}

class _AnimatedTapScaleState extends State<AnimatedTapScale>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
      reverseDuration: const Duration(milliseconds: 150),
    );
    _scale = Tween<double>(begin: 1.0, end: widget.scaleFactor).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    await _controller.forward();
    if (widget.haptics) await AppHaptics.light();
    widget.onTap();
    await _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      onTapDown: (_) => _controller.forward(),
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (context, child) => Transform.scale(
          scale: _scale.value,
          child: child,
        ),
        child: widget.child,
      ),
    );
  }
}
