import 'package:flutter/material.dart';
import '../../ui/theme/df_theme.dart';
import '../../app/navigation/rotas.dart';

// Widgets
import 'presentation/widgets/profile_header.dart';
import 'presentation/widgets/wallet_row.dart';
import 'presentation/widgets/season_hero_card.dart';
import 'presentation/widgets/battle_cta_button.dart';
import 'presentation/widgets/quick_actions_grid.dart';
import 'presentation/widgets/events_carousel.dart';
import 'presentation/widgets/bottom_nav.dart';
import 'presentation/widgets/snow_particles.dart';
import 'presentation/widgets/current_arena_card.dart';
import '../battle/domain/models/arena_definition.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0; // Início

  void _onNavTap(int index) {
    setState(() {
      _currentIndex = index;
    });

    switch (index) {
      case 0:
        // Already Home
        break;
      case 1:
        Navigator.pushNamed(context, Rotas.deck);
        break;
      case 2:
        // Navigator.pushNamed(context, Rotas.upgrade);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Acesse o Deck para evoluir suas cartas!')),
        );
        break;
      case 3:
        Navigator.pushNamed(context, Rotas.shop);
        break;
      case 4:
        Navigator.pushNamed(context, Rotas.battle);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DFTheme.background,
      body: Stack(
        children: [
          // 1. Background Layer
          Positioned.fill(
            child: Image.asset(
              'assets/images/home_bg_storm_runes.png', // New premium background
              fit: BoxFit.cover,
              color: Colors.black.withOpacity(0.3), // Reduced overlay opacity for better visibility
              colorBlendMode: BlendMode.darken,
            ),
          ),
          
          // 2. Particles / Runic Glow (Simulated with Gradient for now)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topCenter,
                  radius: 1.5,
                  colors: [
                    DFTheme.ice.withOpacity(0.1),
                    Colors.transparent,
                    Colors.black.withOpacity(0.4),
                  ],
                ),
              ),
            ),
          ),
          
          // 2.1 Snow Particles
          const Positioned.fill(
            child: SnowParticles(),
          ),

          // 3. Main Content
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                // Fixed Header Elements
                ProfileHeader(
                  onSettingsTap: () => debugPrint('Settings'),
                ),
                const WalletRow(),
                
                // Scrollable Body
                Expanded(
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      const SliverToBoxAdapter(child: SizedBox(height: 16)),
                      
                      // Season Hero
                      const SliverToBoxAdapter(
                        child: SeasonHeroCard(),
                      ),
                      
                      // Battle CTA (The Star)
                      SliverToBoxAdapter(
                        child: BattleCTAButton(
                          onTap: () => Navigator.pushNamed(context, Rotas.battle),
                        ),
                      ),

                      // Current Arena
                      SliverToBoxAdapter(
                        child: CurrentArenaCard(
                          arena: ArenaCatalog.getArenaForTrophies(0), // Mocked 0 trophies for now
                        ),
                      ),
                      
                      // Quick Actions
                      const SliverToBoxAdapter(
                        child: QuickActionsGrid(),
                      ),
                      
                      const SliverToBoxAdapter(child: SizedBox(height: 24)),
                      
                      // Events
                      const SliverToBoxAdapter(
                        child: EventsCarousel(),
                      ),
                      
                      // Bottom Spacer for Nav
                      const SliverToBoxAdapter(child: SizedBox(height: 100)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 4. Bottom Navigation
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: DuelForgeBottomNav(
              currentIndex: _currentIndex,
              onTap: _onNavTap,
            ),
          ),
        ],
      ),
    );
  }
}
