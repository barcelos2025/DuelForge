import 'package:flutter/material.dart';
import '../../ui/theme/duel_colors.dart';
import '../../ui/theme/duel_typography.dart';
import '../../ui/theme/duel_ui_tokens.dart';

class DFPrimaryCTA extends StatefulWidget {
  final String title;
  final String? subtitle;
  final IconData? leftIcon;
  final Widget? rightBadge;
  final VoidCallback? onPressed;
  final bool enabled;

  const DFPrimaryCTA({
    super.key,
    required this.title,
    this.subtitle,
    this.leftIcon,
    this.rightBadge,
    required this.onPressed,
    this.enabled = true,
  });

  @override
  State<DFPrimaryCTA> createState() => _DFPrimaryCTAState();
}

class _DFPrimaryCTAState extends State<DFPrimaryCTA> with TickerProviderStateMixin {
  late AnimationController _pressController;
  late AnimationController _glowController;
  late Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.0,
      upperBound: 0.05,
    );

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _glowAnim = Tween<double>(begin: 0.3, end: 0.8).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.enabled) _pressController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.enabled) {
      _pressController.reverse();
      widget.onPressed?.call();
    }
  }

  void _onTapCancel() {
    if (widget.enabled) _pressController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: Listenable.merge([_pressController, _glowController]),
        builder: (context, child) {
          final scale = 1.0 - _pressController.value;
          final glowOpacity = widget.enabled ? _glowAnim.value : 0.0;

          return Transform.scale(
            scale: scale,
            child: Container(
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: widget.enabled
                    ? const LinearGradient(colors: [DuelColors.accentGold, Color(0xFFFFA000)])
                    : const LinearGradient(colors: [Color(0xFF424242), Color(0xFF212121)]),
                boxShadow: widget.enabled
                    ? [
                        BoxShadow(
                          color: DuelColors.accentGold.withOpacity( glowOpacity),
                          blurRadius: 20,
                          spreadRadius: 2,
                          offset: const Offset(0, 4),
                        ),
                        const BoxShadow(
                          color: Color(0xFF8B6508), // Sombra "dura" (profundidade)
                          offset: Offset(0, 6),
                          blurRadius: 0,
                        ),
                      ]
                    : [
                        const BoxShadow(
                          color: Colors.black38,
                          offset: Offset(0, 4),
                          blurRadius: 0,
                        ),
                      ],
              ),
              child: Stack(
                children: [
                  // Brilho interno animado (Runic Glow)
                  if (widget.enabled)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withOpacity( 0.4),
                              Colors.transparent,
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.3, 1.0],
                          ),
                        ),
                      ),
                    ),

                  // Conteúdo
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (widget.leftIcon != null) ...[
                          Icon(
                            widget.leftIcon,
                            color: widget.enabled ? const Color(0xFF4A3000) : Colors.white38,
                            size: 32,
                          ),
                          const SizedBox(width: 16),
                        ],
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.title.toUpperCase(),
                              style: DuelTypography.displayLarge.copyWith(
                                fontSize: 28,
                                color: widget.enabled ? const Color(0xFF4A3000) : Colors.white38,
                                shadows: [], // Remove sombra padrão para ficar flat no botão
                              ),
                            ),
                            if (widget.subtitle != null)
                              Text(
                                widget.subtitle!,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: widget.enabled ? const Color(0xFF6D4C00) : Colors.white24,
                                  letterSpacing: 1.0,
                                ),
                              ),
                          ],
                        ),
                        if (widget.rightBadge != null) ...[
                          const Spacer(),
                          widget.rightBadge!,
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
