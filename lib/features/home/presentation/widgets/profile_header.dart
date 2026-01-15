import 'package:flutter/material.dart';
import '../../../../ui/theme/df_theme.dart';

class ProfileHeader extends StatelessWidget {
  final VoidCallback onSettingsTap;

  const ProfileHeader({super.key, required this.onSettingsTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Profile Pill
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: DFTheme.surface.withOpacity(0.9),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
              boxShadow: DFTheme.shadowDepth,
            ),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: DFTheme.gradientMetal,
                    border: Border.all(color: DFTheme.cyan, width: 2),
                  ),
                  child: const Center(
                    child: Icon(Icons.person, color: Colors.white, size: 24),
                  ),
                ),
                const SizedBox(width: 8),
                // Info
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'VikingHero',
                      style: DFTheme.labelBold.copyWith(fontSize: 14),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star, color: DFTheme.gold, size: 12),
                        const SizedBox(width: 2),
                        Text(
                          'Lvl 12',
                          style: TextStyle(
                            color: DFTheme.gold,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.emoji_events, color: Colors.white70, size: 12),
                        const SizedBox(width: 2),
                        const Text(
                          '2450',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(width: 12),
              ],
            ),
          ),
          
          const Spacer(),
          
          // Settings Button
          GestureDetector(
            onTap: onSettingsTap,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: DFTheme.surface.withOpacity(0.9),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(0.1)),
                boxShadow: DFTheme.shadowDepth,
              ),
              child: const Icon(Icons.settings, color: Colors.white70, size: 24),
            ),
          ),
        ],
      ),
    );
  }
}
