import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Centralized, lightweight animation utilities.
/// All durations and curves are tuned for smooth 60 Hz / 120 Hz displays.
class AppAnimations {
  AppAnimations._(); // prevent instantiation

  // ──────────────────────────────────────────────
  // Durations
  // ──────────────────────────────────────────────
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 280);
  static const Duration pageTransition = Duration(milliseconds: 450); // Slower, smoother iOS speed
  static const Duration pageReverse = Duration(milliseconds: 400);
  static const Duration slow = Duration(milliseconds: 400);

  // ──────────────────────────────────────────────
  // Curves (iOS-grade smooth deceleration)
  // ──────────────────────────────────────────────
  static const Curve defaultCurve = Curves.easeOutCubic;
  static const Curve enterCurve = Curves.easeOutCubic;
  static const Curve exitCurve = Curves.easeInCubic;
  // Authentic iOS-style spring/cubic decelerating curve
  static const Curve iosSlideCurve = Cubic(0.32, 0.72, 0.0, 1.0);

  // ──────────────────────────────────────────────
  // GoRouter page transition (iOS-Style Smooth Right-to-Left Slide + Parallax)
  // ──────────────────────────────────────────────
  static CustomTransitionPage<T> slidePage<T>({
    required LocalKey key,
    required Widget child,
  }) {
    return CustomTransitionPage<T>(
      key: key,
      child: child,
      transitionDuration: pageTransition,
      reverseTransitionDuration: pageReverse,
      transitionsBuilder: pageTransitionBuilder,
    );
  }

  // ──────────────────────────────────────────────
  // Vertical Slide (bottom-to-top sheet, for workout expand/minimize)
  // ──────────────────────────────────────────────
  static CustomTransitionPage<T> verticalSlidePage<T>({
    required LocalKey key,
    required Widget child,
  }) {
    return CustomTransitionPage<T>(
      key: key,
      child: child,
      transitionDuration: const Duration(milliseconds: 400),
      reverseTransitionDuration: const Duration(milliseconds: 350),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: const Cubic(0.22, 1.0, 0.36, 1.0),
          reverseCurve: Curves.easeInCubic,
        );

        final slideTween = Tween<Offset>(
          begin: const Offset(0.0, 1.0),
          end: Offset.zero,
        );

        final fadeTween = Tween<double>(begin: 0.6, end: 1.0);

        // Subtle scale-down on the underlying screen
        final secondaryCurved = CurvedAnimation(
          parent: secondaryAnimation,
          curve: iosSlideCurve,
        );
        final scaleDownTween = Tween<double>(begin: 1.0, end: 0.94);

        return ScaleTransition(
          scale: scaleDownTween.animate(secondaryCurved),
          child: FadeTransition(
            opacity: fadeTween.animate(curvedAnimation),
            child: SlideTransition(
              position: slideTween.animate(curvedAnimation),
              child: child,
            ),
          ),
        );
      },
    );
  }

  // ──────────────────────────────────────────────
  // Hero Morph Transition (For expanding Pill to Full Screen)
  // ──────────────────────────────────────────────
  static CustomTransitionPage<T> heroPage<T>({
    required LocalKey key,
    required Widget child,
  }) {
    return CustomTransitionPage<T>(
      key: key,
      child: child,
      // The hero animation handles the shape morphing. 
      // The page transition just fades the background.
      transitionDuration: const Duration(milliseconds: 450),
      reverseTransitionDuration: const Duration(milliseconds: 400),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOutCubic,
        );
        return FadeTransition(
          opacity: curvedAnimation,
          child: child,
        );
      },
    );
  }

  static Widget pageTransitionBuilder(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // iOS-style smooth cubic curve (pleasing, soft deceleration)
    final curvedAnimation = CurvedAnimation(
      parent: animation,
      curve: iosSlideCurve,
      reverseCurve: iosSlideCurve,
    );

    final slideInTween = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    );

    // Subtle 20% parallax on underlying screen when a new screen is pushed on top
    final secondaryCurved = CurvedAnimation(
      parent: secondaryAnimation,
      curve: iosSlideCurve,
      reverseCurve: iosSlideCurve,
    );
    final secondarySlideTween = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(-0.20, 0.0),
    );

    return SlideTransition(
      position: secondarySlideTween.animate(secondaryCurved),
      child: SlideTransition(
        position: slideInTween.animate(curvedAnimation),
        child: child,
      ),
    );
  }

  // ──────────────────────────────────────────────
  // Animated dialog  (gentle scale + fade, no bouncy overshoot)
  // ──────────────────────────────────────────────
  static Future<T?> showAnimatedDialog<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    bool barrierDismissible = true,
  }) {
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black54,
      transitionDuration: normal,
      pageBuilder: (ctx, _, _) => builder(ctx),
      transitionBuilder: (_, animation, _, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: enterCurve,
          reverseCurve: exitCurve,
        );
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.92, end: 1.0).animate(curved),
            child: child,
          ),
        );
      },
    );
  }

  // ──────────────────────────────────────────────
  // Animated bottom sheet  (uses Flutter's built‑in controller — no leak)
  // ──────────────────────────────────────────────
  static Future<T?> showAnimatedBottomSheet<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    bool isScrollControlled = true,
    bool useSafeArea = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      useSafeArea: useSafeArea,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: builder,
    );
  }
}
