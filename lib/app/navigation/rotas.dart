
import 'package:flutter/material.dart';
import '../../features/battle/battle_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/deck/deck_screen.dart';
import '../../features/upgrade/upgrade_screen.dart';
import '../../features/shop/shop_screen.dart';
import '../../features/debug/assets_showcase_screen.dart';
import '../../core/assets/asset_loader_service.dart';

class Rotas {
  static const String splash = '/';
  static const String home = '/home';
  static const String battle = '/battle';
  static const String deck = '/deck';
  static const String upgrade = '/upgrade';
  static const String shop = '/shop';
  static const String assetsShowcase = '/assets-showcase';

  static Map<String, WidgetBuilder> builders() {
    return {
      splash: (_) => const SplashScreen(),
      home: (_) => const HomeScreen(),
      battle: (_) => const BattleScreen(),
      deck: (_) => const DeckScreen(),
      upgrade: (_) => const UpgradeScreen(),
      shop: (_) => const ShopScreen(),
      assetsShowcase: (_) => const AssetsShowcaseScreen(),
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
    
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(Rotas.home);
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
                    'Loading Assets... ${(progress * 100).toInt()}%',
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
