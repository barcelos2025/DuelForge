import 'package:flutter/material.dart';
import '../../ui/theme/duel_colors.dart';
import '../../ui/theme/duel_ui_tokens.dart';
import '../../ui/components/df_top_bar.dart';
import '../../ui/components/df_bottom_dock.dart';
import '../../ui/components/df_season_banner.dart';
import '../../ui/components/df_primary_cta.dart';
import '../../app/navigation/rotas.dart';
import 'presentation/widgets/wallet_row.dart';
import 'presentation/widgets/current_arena_card.dart';
import 'presentation/widgets/quick_actions_grid.dart';
import '../battle/domain/models/arena_definition.dart';
import '../../core/audio/audio_service.dart';
import '../deck/deck_screen.dart';
import '../profile/presentation/widgets/player_profile_sheet.dart';
import 'package:provider/provider.dart';
import '../profile/services/profile_service.dart';

import '../avatars/registry/avatar_registry.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Start background music
    AudioService().playMusic('main_menu_theme.mp3');
  }

  void _onNavTap(int index) {
    setState(() => _currentIndex = index);
    
    switch (index) {
      case 0: // Loja
        Navigator.pushNamed(context, Rotas.shop);
        break;
      case 1: // Batalha
        AudioService().stopMusic();
        Navigator.pushNamed(context, Rotas.battle);
        break;
      case 2: // Deck
        _navigateToDeck();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileService = Provider.of<ProfileService>(context);

    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity! < -500) { // Swipe Left
          _navigateToDeck();
        }
      },
      child: Scaffold(
        backgroundColor: DuelColors.background,
        body: Column(
          children: [
            // Top Bar
            DFTopBar(
              playerName: profileService.profile.nickname,
              playerLevel: profileService.profile.level,
              trophies: profileService.trophies,
              rankLabel: profileService.currentArena.name,
              avatarImage: AvatarRegistry.instance.get(profileService.profile.avatarId).assetPath,
              onTapProfile: () {
                showModalBottomSheet(
                  context: context,
                  backgroundColor: Colors.transparent,
                  isScrollControlled: true,
                  builder: (_) => const PlayerProfileSheet(),
                );
              },
              onTapSettings: () {
                Navigator.pushNamed(context, Rotas.assetsShowcase);
              },
            ),
            
            // Main Content - SEM SCROLL, tudo harmonioso
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: DuelUiTokens.spacing16,
                ),
                child: Column(
                  children: [
                    const SizedBox(height: DuelUiTokens.spacing8),
                    
                    // Wallet Row (Fixed Height)
                    const WalletRow(),
                    
                    const SizedBox(height: DuelUiTokens.spacing8),
                    
                    // Season Banner (Flexible)
                    Flexible(
                      flex: 3,
                      child: DFSeasonBanner(
                        title: 'Tempestade de Inverno',
                        description: 'Conquiste recompensas épicas',
                        imageAsset: 'assets/images/home_bg_storm_runes.png',
                        timeRemaining: const Duration(days: 14),
                      ),
                    ),
                    
                    const SizedBox(height: DuelUiTokens.spacing8),
                    
                    // Battle CTA (Flexible)
                    Flexible(
                      flex: 2,
                      child: DFPrimaryCTA(
                        title: 'BATALHAR',
                        subtitle: 'Entre na arena',
                        leftIcon: Icons.sports_kabaddi,
                        onPressed: () {
                          AudioService().stopMusic();
                          Navigator.pushNamed(context, Rotas.battle);
                        },
                      ),
                    ),
                    
                    const SizedBox(height: DuelUiTokens.spacing8),
                    
                    // Current Arena (Fixed Height)
                    CurrentArenaCard(
                      arena: profileService.currentArena,
                    ),
                    
                    const SizedBox(height: DuelUiTokens.spacing8),
                    
                    // Quick Actions (Fixed Height)
                    const QuickActionsGrid(),
                    
                    const SizedBox(height: DuelUiTokens.spacing4),
                  ],
                ),
              ),
            ),
            
            // Bottom Navigation
            DFBottomDock(
              currentIndex: _currentIndex,
              onChange: _onNavTap,
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToDeck() {
    // Change Music
    AudioService().playMusic('deck_theme.mp3');

    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const DeckScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;

          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    ).then((_) {
      // Restore Main Menu Music when returning
      AudioService().playMusic('main_menu_theme.mp3');
    });
  }
}
