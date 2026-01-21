import 'package:flutter/material.dart';
import '../../core/utils/number_formatter.dart';
import '../theme/duel_colors.dart';
import '../theme/duel_typography.dart';
import '../theme/duel_ui_tokens.dart';
import '../../core/audio/audio_service.dart';

class DFTopBar extends StatelessWidget {
  final String playerName;
  final int playerLevel;
  final String? avatarImage;
  final int trophies;
  final String rankLabel;
  final VoidCallback? onTapProfile;
  final VoidCallback? onTapSettings;

  const DFTopBar({
    super.key,
    required this.playerName,
    required this.playerLevel,
    required this.trophies,
    required this.rankLabel,
    this.avatarImage,
    this.onTapProfile,
    this.onTapSettings,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            // Profile Section (Interactive)
            Expanded(
              child: _InteractiveProfileCard(
                playerName: playerName,
                playerLevel: playerLevel,
                avatarImage: avatarImage,
                trophies: trophies,
                rankLabel: rankLabel,
                onTap: onTapProfile,
              ),
            ),
            
            const SizedBox(width: 12),

            // Mute Button
            _MuteButton(),

            const SizedBox(width: 8),

            // Settings Button
            _SettingsButton(onTap: onTapSettings),
          ],
        ),
      ),
    );
  }
}

class _InteractiveProfileCard extends StatefulWidget {
  final String playerName;
  final int playerLevel;
  final String? avatarImage;
  final int trophies;
  final String rankLabel;
  final VoidCallback? onTap;

  const _InteractiveProfileCard({
    required this.playerName,
    required this.playerLevel,
    this.avatarImage,
    required this.trophies,
    required this.rankLabel,
    this.onTap,
  });

  @override
  State<_InteractiveProfileCard> createState() => _InteractiveProfileCardState();
}

class _InteractiveProfileCardState extends State<_InteractiveProfileCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.0,
      upperBound: 0.05,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) => _controller.forward();
  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onTap?.call();
  }
  void _onTapCancel() => _controller.reverse();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final isPressed = _controller.value > 0.01;
          return Transform.scale(
            scale: 1.0 - _controller.value,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: DuelColors.surface.withOpacity(0.9),
                borderRadius: BorderRadius.circular(DuelUiTokens.radiusFull),
                border: Border.all(
                  color: isPressed ? DuelColors.primary : Colors.white.withOpacity(0.15),
                  width: 1.5,
                ),
                boxShadow: isPressed ? DuelUiTokens.glowCyan : [],
              ),
              child: Row(
                children: [
                  // Avatar + Level Badge
                  SizedBox(
                    width: 66, // Increased to fit larger frame
                    height: 66,
                    child: Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.none,
                      children: [
                        // Glow
                        Container(
                          width: 43,
                          height: 43,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.cyanAccent.withOpacity(0.5),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                        // Avatar Image
                        SizedBox(
                          width: 40,
                          height: 40,
                          child: ClipOval(
                            child: Image.asset(
                              widget.avatarImage ?? 'assets/images/guerreiro ulf lendário.jpeg',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(Icons.person, size: 24, color: Colors.white);
                              },
                            ),
                          ),
                        ),
                        // Frame Overlay
                        Image.asset(
                          'assets/ui/avatar_frame.png',
                          width: 64,
                          height: 64,
                          fit: BoxFit.contain,
                        ),
                        // Level Badge
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: DuelColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              NumberFormatter.format(widget.playerLevel),
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Info
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.playerName,
                        style: DuelTypography.labelCaps.copyWith(fontSize: 14, color: DuelColors.textPrimary),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.emoji_events, size: 14, color: DuelColors.accentGold),
                          const SizedBox(width: 4),
                          Text(
                            NumberFormatter.format(widget.trophies),
                            style: DuelTypography.labelCaps.copyWith(color: DuelColors.accentGold),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            widget.rankLabel,
                            style: DuelTypography.bodySmall.copyWith(fontSize: 10, color: Colors.white54),
                          ),
                        ],
                      ),
                    ],
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

class _SettingsButton extends StatefulWidget {
  final VoidCallback? onTap;
  const _SettingsButton({this.onTap});

  @override
  State<_SettingsButton> createState() => _SettingsButtonState();
}

class _SettingsButtonState extends State<_SettingsButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap?.call();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.9 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: DuelColors.surface.withOpacity(0.9),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withOpacity(0.15),
              width: 1.5,
            ),
          ),
          child: const Icon(Icons.settings, color: Colors.white70, size: 24),
        ),
      ),
    );
  }
}

class _MuteButton extends StatefulWidget {
  const _MuteButton();

  @override
  State<_MuteButton> createState() => _MuteButtonState();
}

class _MuteButtonState extends State<_MuteButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AudioService(),
      builder: (context, child) {
        final isMuted = AudioService().isMuted;
        return GestureDetector(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) {
            setState(() => _isPressed = false);
            AudioService().toggleMute();
          },
          onTapCancel: () => setState(() => _isPressed = false),
          child: AnimatedScale(
            scale: _isPressed ? 0.9 : 1.0,
            duration: const Duration(milliseconds: 100),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: DuelColors.surface.withOpacity(0.9),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isMuted ? Colors.redAccent.withOpacity(0.5) : Colors.white.withOpacity(0.15),
                  width: 1.5,
                ),
              ),
              child: Icon(
                isMuted ? Icons.volume_off : Icons.volume_up,
                color: isMuted ? Colors.redAccent : Colors.white70,
                size: 24,
              ),
            ),
          ),
        );
      },
    );
  }
}
