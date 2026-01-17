import 'package:flutter/material.dart';
import '../widgets/deck_card_widget.dart';

class CardSwapAnimator {
  static Future<void> animateSwap({
    required BuildContext context,
    required TickerProvider vsync,
    required Rect fromA,
    required Rect toA,
    required Rect fromB,
    required Rect toB,
    required String cardIdA,
    required String cardIdB,
  }) async {
    final overlayState = Overlay.of(context);
    
    // Create animation controller
    final controller = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 600), // Slightly longer for better feel
    );

    final animation = CurvedAnimation(
      parent: controller,
      curve: Curves.easeInOutCubic,
    );

    // Calculate screen center for visibility
    final screenSize = MediaQuery.of(context).size;
    // Shift center slightly to the left (-40) as requested
    final screenCenter = Offset((screenSize.width / 2) - 40, screenSize.height / 2);

    // Helper: Solve for Control Point P1 such that the curve passes through M at t=0.5
    // P(0.5) = 0.25*P0 + 0.5*P1 + 0.25*P2 = M
    // P1 = 2M - 0.5(P0 + P2)
    Offset solveControlPoint(Offset start, Offset end, Offset mid) {
      return (mid * 2.0) - ((start + end) * 0.5);
    }

    // Helper: Evaluate Quadratic Bezier
    Offset evaluateBezier(Offset p0, Offset p1, Offset p2, double t) {
      final u = 1 - t;
      return (p0 * u * u) + (p1 * 2 * u * t) + (p2 * t * t);
    }

    // Helper to build animated card
    Widget buildAnimatedCard(Rect from, Rect to, String cardId, bool isFirstCard) {
      // Calculate path
      final startCenter = from.center;
      final endCenter = to.center;
      
      // Offset the midpoint slightly so they don't crash into each other perfectly
      final midOffset = isFirstCard ? const Offset(-30, 0) : const Offset(30, 0);
      final midPoint = screenCenter + midOffset;
      
      final controlPoint = solveControlPoint(startCenter, endCenter, midPoint);

      return Positioned.fill(
        child: Stack(
          children: [
            // Ghost Trail (lagging behind)
            AnimatedBuilder(
              animation: animation,
              builder: (context, child) {
                final ghostValue = (animation.value - 0.08).clamp(0.0, 1.0);
                if (ghostValue <= 0.0 || ghostValue >= 1.0) return const SizedBox();

                final currentCenter = evaluateBezier(startCenter, controlPoint, endCenter, ghostValue);
                final currentSize = Size.lerp(from.size, to.size, ghostValue)!;
                final rect = Rect.fromCenter(center: currentCenter, width: currentSize.width, height: currentSize.height);
                
                final scale = 1.0 + (0.15 * (1.0 - (2 * (ghostValue - 0.5)).abs()));
                
                return Positioned.fromRect(
                  rect: rect,
                  child: Opacity(
                    opacity: 0.3,
                    child: Transform.scale(
                      scale: scale * 0.95,
                      child: DeckCardWidget(
                        cardId: cardId,
                        isSelected: false,
                        onTap: () {},
                        isStaticMode: true,
                      ),
                    ),
                  ),
                );
              },
            ),
            // Main Card
            AnimatedBuilder(
              animation: animation,
              builder: (context, child) {
                final currentCenter = evaluateBezier(startCenter, controlPoint, endCenter, animation.value);
                final currentSize = Size.lerp(from.size, to.size, animation.value)!;
                final rect = Rect.fromCenter(center: currentCenter, width: currentSize.width, height: currentSize.height);

                // Scale up to 1.15 at 50% progress
                final scale = 1.0 + (0.15 * (1.0 - (2 * (animation.value - 0.5)).abs()));
                
                return Positioned.fromRect(
                  rect: rect,
                  child: Transform.scale(
                    scale: scale,
                    child: DeckCardWidget(
                      cardId: cardId,
                      isSelected: true, // Glow during flight
                      onTap: () {},
                      isStaticMode: true,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      );
    }

    final entryA = OverlayEntry(
      builder: (context) => buildAnimatedCard(fromA, toA, cardIdA, true),
    );

    final entryB = OverlayEntry(
      builder: (context) => buildAnimatedCard(fromB, toB, cardIdB, false),
    );

    // Insert overlays
    overlayState.insert(entryA);
    overlayState.insert(entryB);

    // Run animation
    try {
      await controller.forward();
    } finally {
      // Cleanup
      entryA.remove();
      entryB.remove();
      controller.dispose();
    }
  }
}
