import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../features/avatars/registry/avatar_registry.dart';
import '../../features/avatars/models/avatar_def.dart';
import '../../ui/theme/df_theme.dart';
import 'avatar_text_styles.dart';
import 'avatar_animations.dart';
import 'avatar_snow_particles.dart';

class AvatarSelectionScreen extends StatefulWidget {
  final String? initialAvatarId;
  final Function(String) onAvatarSelected;

  const AvatarSelectionScreen({
    super.key,
    this.initialAvatarId,
    required this.onAvatarSelected,
  });

  @override
  State<AvatarSelectionScreen> createState() => _AvatarSelectionScreenState();
}

class _AvatarSelectionScreenState extends State<AvatarSelectionScreen> with SingleTickerProviderStateMixin {
  late String _selectedId;
  final _registry = AvatarRegistry.instance;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _selectedId = widget.initialAvatarId ?? 'warrior_m';
    
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final avatars = _registry.getAll();
    final selectedAvatar = _registry.get(_selectedId);

    return Scaffold(
      backgroundColor: DFTheme.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: FadeDownIn(
          child: Text(
            'Escolha seu Avatar',
            style: AvatarTextStyles.title,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: FadeScaleIn(
        child: Stack(
          children: [
            // Background Image
            Positioned.fill(
              child: Image.asset(
                'assets/images/avatar_selection_bg.jpg',
                fit: BoxFit.cover,
              ),
            ),
            // Snow Particles (Flame)
            const Positioned.fill(
              child: AvatarSnowParticles(),
            ),
            // Main Content
            Column(
              children: [
                // Selected Avatar Details
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 81),
                          // Avatar Group
                          Stack(
                            alignment: Alignment.center,
                            clipBehavior: Clip.none,
                            children: [
                              // 1. LED Glow (Pulsing)
                              AnimatedBuilder(
                                animation: _pulseAnimation,
                                builder: (context, child) {
                                  return Container(
                                    width: 252, // Reduced by 10% (280 * 0.9)
                                    height: 252,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.cyanAccent.withOpacity(0.6 * _pulseAnimation.value.clamp(0.0, 1.0)),
                                          blurRadius: 50 * _pulseAnimation.value,
                                          spreadRadius: 4 * _pulseAnimation.value,
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                              // 2. Avatar Image
                              SizedBox(
                                width: 234, // Reduced by 10% (260 * 0.9)
                                height: 234,
                                child: ClipOval(
                                  child: AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 400),
                                    transitionBuilder: (Widget child, Animation<double> animation) {
                                      return FadeTransition(
                                        opacity: animation,
                                        child: ScaleTransition(scale: animation, child: child),
                                      );
                                    },
                                    child: Image.asset(
                                      selectedAvatar.assetPath,
                                      key: ValueKey<String>(selectedAvatar.id),
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return const Icon(Icons.person, size: 140, color: Colors.white);
                                      },
                                    ),
                                  ),
                                ),
                              ),
                              // 3. Frame Overlay
                              Positioned(
                                top: -58, // Adjusted for new size: (252 - 373)/2 + 3
                                left: -61, // Adjusted for new size: (252 - 373)/2
                                child: Image.asset(
                                  'assets/ui/avatar_frame.png',
                                  width: 373, // Reduced by 10% (414 * 0.9)
                                  height: 373,
                                  fit: BoxFit.contain,
                                ),
                              ),
                              // 4. Info Icon
                              Positioned(
                                top: -20,
                                right: -20,
                                child: GestureDetector(
                                  onTap: () {
                                    _showInfoDialog(context, selectedAvatar);
                                  },
                                  child: Image.asset(
                                    'assets/ui/icons/info_icon.png',
                                    width: 62, // Increased by 30% (48 * 1.3)
                                    height: 62,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Character Name (Shimmer)
                          ShimmerText(
                            child: Text(
                              selectedAvatar.name,
                              style: AvatarTextStyles.characterName,
                            ),
                          ),
                          // Character Class (Delayed Fade)
                          Transform.translate(
                            offset: const Offset(0, -10),
                            child: FadeScaleIn(
                              delay: const Duration(milliseconds: 150),
                              child: Text(
                                selectedAvatar.classType,
                                style: AvatarTextStyles.characterClass,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
      
                // Avatar Grid & Button
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0A1525).withOpacity(0.5),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GridView.builder(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 5,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.0,
                        ),
                        itemCount: avatars.length,
                        itemBuilder: (context, index) {
                          final avatar = avatars[index];
                          final isSelected = avatar.id == _selectedId;
      
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedId = avatar.id;
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected ? DFTheme.gold : Colors.transparent,
                                  width: isSelected ? 3 : 1,
                                ),
                                color: Colors.grey[800],
                              ),
                              child: ClipOval(
                                child: Image.asset(
                                  avatar.assetPath,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(
                                      Icons.person, 
                                      size: 24, 
                                      color: isSelected ? Colors.white : Colors.white54
                                    );
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      // Confirm Button
                      GestureDetector(
                        onTap: () {
                          widget.onAvatarSelected(_selectedId);
                          Navigator.pop(context, _selectedId);
                        },
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.48, // Reduced by 20% (0.6 * 0.8)
                          child: Image.asset(
                            'assets/ui/buttons/confirm_button.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showInfoDialog(BuildContext context, AvatarDef avatar) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 40),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Main Container
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF000814).withOpacity(0.9), // Darker blue with 10% transparency
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.cyanAccent.withOpacity(0.3), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 8),
                  Text(
                    avatar.name.toUpperCase(),
                    style: GoogleFonts.cinzel(
                      color: const Color(0xFFFFD700), // Metallic Gold
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.5),
                          offset: const Offset(1, 1),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      avatar.classType,
                      style: GoogleFonts.rajdhani(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    avatar.description,
                    style: GoogleFonts.rajdhani(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 15,
                      height: 1.5,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
            // Close Button (X)
            Positioned(
              top: -10,
              right: -10,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.close,
                    size: 20,
                    color: Color(0xFF000814),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
