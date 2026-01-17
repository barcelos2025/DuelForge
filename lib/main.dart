import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app/di/app_di.dart';
import 'app/navigation/rotas.dart';
import 'features/cards/services/card_progression_service.dart';
import 'features/profile/services/profile_service.dart';
import 'core/assets/asset_registry.dart';
import 'ui/theme/df_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await AssetRegistry.init();
  final profileService = await ProfileService.init();
  
  // Initialize Card Progression
  await CardProgressionService().init();
  
  runApp(DuelForgeApp(profileService: profileService));
}

class DuelForgeApp extends StatelessWidget {
  final ProfileService profileService;
  
  const DuelForgeApp({super.key, required this.profileService});

  @override
  Widget build(BuildContext context) {
    final app = AppDI(
      profileService: profileService,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'DuelForge',
        theme: DFTheme.darkTheme,
        initialRoute: Rotas.splash,
        routes: Rotas.builders(),
      ),
    );

    if (kIsWeb) {
      return Directionality(
        textDirection: TextDirection.ltr,
        child: Container(
          color: const Color(0xFF121212), // Fundo escuro para destacar o app
          alignment: Alignment.center,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              width: 390, // Largura estilo iPhone
              height: 844, // Altura estilo iPhone
              child: app,
            ),
          ),
        ),
      );
    }

    return app;
  }
}
