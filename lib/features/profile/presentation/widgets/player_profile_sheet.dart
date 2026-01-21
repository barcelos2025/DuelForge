import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../ui/theme/duel_colors.dart';
import '../../../../ui/theme/duel_typography.dart';
import '../../../../ui/theme/duel_ui_tokens.dart';
import '../../../auth/services/auth_service.dart';
import '../../../../app/navigation/rotas.dart';
import '../../services/profile_service.dart';
import '../../models/user_card.dart';
import '../../../../ui/avatar/avatar_selection_screen.dart';
import '../../../../features/avatars/registry/avatar_registry.dart';
import '../../../../features/avatars/utils/class_icon_mapper.dart';
import 'ember_particles.dart';
import 'cracked_ice_painter.dart';
import 'package:flame/game.dart';
import 'package:google_fonts/google_fonts.dart';

class PlayerProfileSheet extends StatefulWidget {
  const PlayerProfileSheet({super.key});

  @override
  State<PlayerProfileSheet> createState() => _PlayerProfileSheetState();
}

class _PlayerProfileSheetState extends State<PlayerProfileSheet> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  final EmberParticles _emberGame = EmberParticles();

  @override
  void initState() {
    super.initState();
    
    // Heartbeat-like pulse animation
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _pulseAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.8, end: 1.0).chain(CurveTween(curve: Curves.easeIn)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.85).chain(CurveTween(curve: Curves.easeOut)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.85, end: 0.8).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 30,
      ),
    ]).animate(_pulseController);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileService = Provider.of<ProfileService>(context);
    final profile = profileService.profile;
    final authService = AuthService();

    if (profile == null) {
      return const Center(
        child: CircularProgressIndicator(color: DuelColors.primary),
      );
    }

    // Calculate Collection Stats
    final totalCards = 28; // Hardcoded for now, should come from catalog count
    final obtainedCards = profile.userCards.where((c) => c.isObtained).length;
    
    // Top Cards (Sort by Level DESC, then Fragments DESC)
    final topCards = List<UserCard>.from(profile.userCards.where((c) => c.isObtained))
      ..sort((a, b) {
        int cmp = b.level.compareTo(a.level);
        if (cmp != 0) return cmp;
        return b.fragments.compareTo(a.fragments);
      });
    final top5 = topCards.take(5).toList();

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: Stack(
        children: [
          // 1. Background Image (Sharp)
          Positioned.fill(
            child: Image.asset(
              'assets/images/profile_background.jpg',
              fit: BoxFit.cover,
            ),
          ),
          
          // 2. Top Gradient (Dark Blue → Transparent)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 200,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF0A1929).withOpacity(0.9),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          
          // 3. Bottom Gradient (Transparent → Dark Blue)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 200,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    const Color(0xFF0A1929).withOpacity(0.9),
                  ],
                ),
              ),
            ),
          ),
          
          // 4. Deep Blue Overlay
          Positioned.fill(
            child: Container(
              color: const Color(0xFF000510).withOpacity(0.7),
            ),
          ),
          
          // 5. Ice Smoke Particles
          Positioned.fill(
            child: IgnorePointer(
              child: GameWidget(
                game: _emberGame,
              ),
            ),
          ),

          // 6. Main Content
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                children: [
                // Handle Bar
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 12),
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0.1),
                          Colors.white.withOpacity(0.3),
                          Colors.white.withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(2.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ),
              
              Expanded(
                child: ScrollConfiguration(
                  behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                    // --- Header with Name Frame ---
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: SizedBox(
                        height: 200,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          // Name Frame (behind avatar)
                          Positioned(
                            left: 28.13, // 5% more to left (29.61 - 29.61*0.05)
                            top: 20.2, // 3% down (16 + 140*0.03)
                            child: SizedBox(
                              width: 336,
                              height: 140,
                              child: Stack(
                                alignment: Alignment.centerLeft,
                                children: [
                                  // Name Frame Background
                                  Image.asset(
                                    'assets/ui/player_name_frame.png',
                                    width: 336,
                                    height: 140,
                                    fit: BoxFit.fill,
                                  ),
                                  // Player Name with Icon
                                  Positioned(
                                    left: 120.64, // 1% to right (117.28 + 336*0.01)
                                    top: 40.4, // 2% up from 43.2 (43.2 - 140*0.02)
                                    right: 30,
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            profile.nickname.toUpperCase(),
                                            style: GoogleFonts.cinzel(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                              color: DuelColors.accentGold,
                                              letterSpacing: 1.2,
                                              shadows: [
                                                const Shadow(
                                                  color: Colors.black,
                                                  offset: Offset(2, 2),
                                                  blurRadius: 4,
                                                ),
                                                const Shadow(
                                                  color: Colors.black54,
                                                  offset: Offset(0, 0),
                                                  blurRadius: 8,
                                                ),
                                              ],
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Class Name
                                  Positioned(
                                    left: 121.98, // 0.4% to right (120.64 + 336*0.004)
                                    top: 72.6, // 15% down from 51.6 (51.6 + 140*0.15)
                                    right: 30,
                                    child: Text(
                                      AvatarRegistry.instance.get(profile.avatarId).classType,
                                      style: GoogleFonts.rajdhani(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF2FE6FF),
                                        letterSpacing: 0.6,
                                        shadows: const [
                                          Shadow(
                                            color: Color(0x6600CFFF),
                                            blurRadius: 8,
                                          ),
                                        ],
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  // Level Text (in blue bar)
                                  Positioned(
                                    right: 130, 
                                    bottom: 12.3,
                                    child: Text(
                                      'NÍVEL ${profile.level}',
                                      style: GoogleFonts.rajdhani(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        letterSpacing: 1.0,
                                        shadows: [
                                          const Shadow(
                                            color: Colors.black,
                                            offset: Offset(2, 2),
                                            blurRadius: 8,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          
                          // Avatar (on top of name frame)
                          Positioned(
                            left: -20, // 5% more to left (-10 - 10)
                            top: 10,
                            child: GestureDetector(
                              onTap: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AvatarSelectionScreen(
                                      initialAvatarId: profile.avatarId,
                                      onAvatarSelected: (id) {
                                        profileService.setAvatar(id);
                                      },
                                    ),
                                  ),
                                );
                                if (result != null) {
                                  profileService.setAvatar(result);
                                }
                              },
                              child: Stack(
                                alignment: Alignment.center,
                                clipBehavior: Clip.none,
                                children: [
                                  // 1. LED Glow (Pulsing)
                                  AnimatedBuilder(
                                    animation: _pulseAnimation,
                                    builder: (context, child) {
                                      return Container(
                                        width: 122.5,
                                        height: 122.5,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.cyanAccent.withOpacity(0.6 * _pulseAnimation.value),
                                              blurRadius: 25 * _pulseAnimation.value,
                                              spreadRadius: 2.5 * _pulseAnimation.value,
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                  // 2. Avatar Image
                                  SizedBox(
                                    width: 112.5,
                                    height: 112.5,
                                    child: ClipOval(
                                      child: Image.asset(
                                        AvatarRegistry.instance.get(profile.avatarId).assetPath,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return const Icon(Icons.person, size: 50, color: Colors.white);
                                        },
                                      ),
                                    ),
                                  ),
                                  // 3. Frame Overlay
                                  Image.asset(
                                    'assets/ui/avatar_frame.png',
                                    width: 178.75,
                                    height: 178.75,
                                    fit: BoxFit.contain,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ), // Comma added

                  // Edit Avatar Icon (above avatar frame)
                  Positioned(
                    top: -5,
                    left: 120,
                    child: GestureDetector(
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AvatarSelectionScreen(
                              initialAvatarId: profile.avatarId,
                              onAvatarSelected: (id) {
                                profileService.setAvatar(id);
                              },
                            ),
                          ),
                        );
                        if (result != null) {
                          profileService.setAvatar(result);
                        }
                      },
                      child: Image.asset(
                        'assets/ui/edit_avatar_icon.png',
                        width: 41.6,
                        height: 41.6,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.edit, size: 32, color: Colors.white70);
                        },
                      ),
                    ),
                  ),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0A1525).withOpacity(0.5),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                      border: const Border(
                        top: BorderSide(color: Colors.white10, width: 1),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 10,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        // Cracked ice overlay
                        Positioned.fill(
                          child: CustomPaint(
                            painter: CrackedIcePainter(),
                          ),
                        ),
                        // Main content
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 32),

                    // --- Currencies (Existing) ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _CurrencyItem(
                          imagePath: 'assets/ui/currency_gold_frame.png', 
                          value: profile.coins.toString(), 
                          color: DuelColors.accentGold,
                        ),
                        _CurrencyItem(
                          imagePath: 'assets/ui/currency_gem_frame.png', 
                          value: profile.rubies.toString(), 
                          color: Colors.greenAccent,
                        ),
                        _CurrencyItem(
                          imagePath: 'assets/ui/currency_rune_frame.png', 
                          value: profile.runes.toString(),
                          color: Colors.purpleAccent,
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),
                    
                    // --- Stats Grid (Existing) ---
                    Text('ESTATÍSTICAS', style: DuelTypography.labelCaps.copyWith(color: Colors.white54)),
                    const SizedBox(height: 12),
                    GridView.count(
                      shrinkWrap: true,
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 2.5,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _StatCard(
                          label: 'Troféus', 
                          value: profile.trophies.toString(), 
                          icon: Icons.emoji_events, 
                          color: DuelColors.accentGold
                        ),
                        _StatCard(
                          label: 'Arena', 
                          value: profileService.currentArena.name, 
                          icon: Icons.stadium, 
                          color: DuelColors.accentCyan
                        ),
                        _StatCard(
                          label: 'XP Total', 
                          value: profile.xp.toString(), 
                          icon: Icons.bolt, 
                          color: Colors.blueAccent
                        ),
                        const _StatCard(
                          label: 'Vitórias', 
                          value: '128', 
                          icon: Icons.sports_martial_arts, 
                          color: Colors.redAccent
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 32),

                    // --- Collection Stats (NEW) ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'COLEÇÃO', 
                          style: GoogleFonts.rajdhani(
                            color: Colors.white54,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          '$obtainedCards / $totalCards', 
                          style: GoogleFonts.rajdhani(
                            color: DuelColors.accentCyan,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Stack(
                      children: [
                        Container(
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.white10,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        FractionallySizedBox(
                          widthFactor: obtainedCards / totalCards,
                          child: Container(
                            height: 8,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [DuelColors.primary, DuelColors.accentCyan],
                              ),
                              borderRadius: BorderRadius.circular(4),
                              boxShadow: [
                                BoxShadow(
                                  color: DuelColors.primary.withOpacity(0.5),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Top Cards List (NEW)
                    if (top5.isNotEmpty) ...[
                      const SizedBox(height: 32),
                      Text(
                        'MELHORES CARTAS', 
                        style: GoogleFonts.rajdhani(
                          color: Colors.white54,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.03),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: Column(
                          children: top5.asMap().entries.map((entry) {
                            final index = entry.key;
                            final card = entry.value;
                            final required = card.level * 10; 
                            final canUpgrade = card.fragments >= required;
                            final isLast = index == top5.length - 1;

                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              decoration: BoxDecoration(
                                border: isLast ? null : const Border(bottom: BorderSide(color: Colors.white10)),
                              ),
                              child: Row(
                                children: [
                                  // Card Icon with Glow
                                  Container(
                                    width: 44,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      color: Colors.black45,
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: Colors.white24),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.3),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(5),
                                      child: Image.asset(
                                        'assets/cards/${card.cardId}.png',
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => const Icon(Icons.style, color: Colors.white24),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          card.cardId.split('_').last.toUpperCase(),
                                          style: GoogleFonts.rajdhani(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: DuelColors.primary.withOpacity(0.15),
                                                borderRadius: BorderRadius.circular(4),
                                                border: Border.all(color: DuelColors.primary.withOpacity(0.3)),
                                              ),
                                              child: Text(
                                                'NV. ${card.level}',
                                                style: GoogleFonts.rajdhani(
                                                  color: DuelColors.primary, 
                                                  fontSize: 10, 
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Text(
                                              '${card.fragments} / $required',
                                              style: GoogleFonts.rajdhani(
                                                color: canUpgrade ? DuelColors.success : Colors.white38,
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (canUpgrade)
                                    Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: DuelColors.success.withOpacity(0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.arrow_upward, color: DuelColors.success, size: 18),
                                    ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],

                    const SizedBox(height: 10),
                    
                    // --- Logout (Existing) ---
                    SizedBox(
                      width: double.infinity,
                      child: InkWell(
                        onTap: () async {
                          await authService.logout();
                          if (context.mounted) {
                            Navigator.of(context).pushNamedAndRemoveUntil(Rotas.auth, (route) => false);
                          }
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
                            gradient: LinearGradient(
                              colors: [
                                Colors.redAccent.withOpacity(0.1),
                                Colors.redAccent.withOpacity(0.02),
                              ],
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.logout, color: Colors.redAccent, size: 20),
                              const SizedBox(width: 12),
                              Text(
                                'SAIR DA CONTA',
                                style: GoogleFonts.rajdhani(
                                  color: Colors.redAccent,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                        const SizedBox(height: 24),
                          ],
                        ),
                      ],
                    ),
                  ),
                  ],
                ),
              ),
            ),
            ],
          ),
        ),
      ),
    ],
  ),
);
  }
}

class _CurrencyItem extends StatelessWidget {
  final String imagePath;
  final String value;
  final Color color;

  const _CurrencyItem({required this.imagePath, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      height: 120,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: -60,
            left: 0,
            right: 0,
            bottom: 0,
            child: Image.asset(imagePath, fit: BoxFit.contain),
          ),
          Positioned(
            bottom: 12,
            left: 10,
            right: 10,
            child: Text(
              value, 
              textAlign: TextAlign.center,
              style: GoogleFonts.rajdhani(
                color: const Color(0xFFE0E0E0), 
                fontWeight: FontWeight.bold,
                fontSize: 14,
                letterSpacing: 0.5,
                shadows: [
                  const Shadow(
                    color: Colors.black,
                    offset: Offset(1, 1),
                    blurRadius: 2,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.28),
            Colors.white.withOpacity(0.22),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Accent line on the left
          Positioned(
            left: 0,
            top: 4,
            bottom: 4,
            width: 3,
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.5),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Row(
              children: [
                Icon(icon, color: color.withOpacity(0.8), size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        value, 
                        style: GoogleFonts.rajdhani(
                          fontWeight: FontWeight.bold, 
                          fontSize: 15,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      Text(
                        label.toUpperCase(), 
                        style: GoogleFonts.rajdhani(
                          color: Colors.white38, 
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
