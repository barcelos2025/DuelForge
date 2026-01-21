
import 'package:flutter/material.dart';
import '../../features/battle/battle_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/deck/deck_screen.dart';
import '../../features/upgrade/upgrade_screen.dart';
import '../../features/shop/shop_screen.dart';
import '../../features/debug/assets_showcase_screen.dart';
import '../../features/debug/ui_kit_test_screen.dart';
import '../../core/assets/asset_loader_service.dart';
import '../../core/audio/audio_service.dart';
import '../../features/auth/services/auth_service.dart';
import '../../features/auth/presentation/screens/auth_screen.dart';
import '../../features/profile/presentation/screens/onboarding_profile_screen.dart';
import '../../features/battle/viewmodels/cards_repository.dart';
import '../../features/profile/services/profile_service.dart';
import '../../features/battle/domain/models/arena_definition.dart';
import 'package:provider/provider.dart';

class Rotas {
  static const String splash = '/';
  static const String auth = '/auth';
  static const String onboarding = '/onboarding';
  static const String home = '/home';
  static const String battle = '/battle';
  static const String deck = '/deck';
  static const String upgrade = '/upgrade';
  static const String shop = '/shop';
  static const String assetsShowcase = '/assets-showcase';
  static const String uiKitTest = '/ui-kit-test';

  static Map<String, WidgetBuilder> builders() {
    return {
      splash: (_) => const SplashScreen(),
      auth: (_) => const AuthScreen(),
      onboarding: (_) => const OnboardingProfileScreen(),
      home: (_) => const HomeScreen(),
      battle: (_) => const BattleScreen(),
      deck: (_) => const DeckScreen(),
      upgrade: (_) => const UpgradeScreen(),
      shop: (_) => const ShopScreen(),
      assetsShowcase: (_) => const AssetsShowcaseScreen(),
      uiKitTest: (_) => const UIKitTestScreen(),
    };
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _loadAssets();
  }

  Future<void> _loadAssets() async {
    await AssetLoaderService.preloadAssets((p) {
      if (mounted) {
        setState(() => _progress = p);
      }
    });
    
    // AudioService is now initialized in main.dart with ProfileService

    // Initialize Auth
    await AuthService().init();
    
    if (!mounted) return;

    // Preload critical game data if authenticated
    if (AuthService().isAuthenticated) {
      try {
        // 1. Preload Cards Repository (needed for deck validation and display)
        final repo = CardsRepository();
        if (!repo.carregado) {
          await repo.carregar();
          print('✅ CardsRepository preloaded: ${repo.todasCartas.length} cards');
        }
        
        // 2. Access ProfileService from Provider (already initialized in main.dart)
        if (mounted) {
          final profileService = Provider.of<ProfileService>(context, listen: false);
          print('✅ ProfileService ready with ${profileService.profile.decks.length} decks');
          
          // Log active deck for debugging
          try {
            final activeDeck = profileService.profile.decks.firstWhere((d) => d.isActive);
            print('   Active deck: "${activeDeck.name}" with ${activeDeck.cardIds.length} cards');
          } catch (e) {
            print('   ⚠️ No active deck found');
          }

          // 3. Preload Current Arena Image (Fix slow loading)
          try {
            final trophies = profileService.trophies;
            final currentArena = ArenaCatalog.getArenaForTrophies(trophies);
            if (mounted) {
              await precacheImage(AssetImage(currentArena.assetPath), context);
              print('✅ Arena preloaded: ${currentArena.name}');
            }
          } catch (e) {
            print('⚠️ Error preloading arena: $e');
          }
        }
        
      } catch (e) {
        print('⚠️ Error preloading game data: $e');
      }
    }
    
    if (!mounted) return;

    if (AuthService().isAuthenticated) {
      if (AuthService().isOnboardingCompleted) {
        Navigator.of(context).pushReplacementNamed(Rotas.home);
      } else {
        Navigator.of(context).pushReplacementNamed(Rotas.onboarding);
      }
    } else {
      Navigator.of(context).pushReplacementNamed(Rotas.auth);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _SplashView(progress: _progress);
  }
}

class _SplashView extends StatelessWidget {
  final double progress;
  const _SplashView({required this.progress});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Fallback color if splash image missing
          Container(color: const Color(0xFF121212)),
          Image.asset(
            'assets/images/splash_screen.png', 
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const SizedBox(),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 40, left: 40, right: 40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Carregando... ${(progress * 100).toInt()}%',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00FFFF).withOpacity(0.6),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.black54,
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00FFFF)),
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
