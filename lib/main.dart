import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app/di/app_di.dart';
import 'app/navigation/rotas.dart';
import 'features/cards/services/card_progression_service.dart';
import 'features/profile/services/profile_service.dart';
import 'core/assets/asset_registry.dart';
import 'ui/theme/df_theme.dart';
import 'core/audio/audio_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'features/auth/services/auth_service.dart';
import 'core/services/sync_service.dart';

import 'features/rewards/services/reward_sync_service.dart';
import 'features/rewards/presentation/reward_animation_overlay.dart';
import 'core/content/content_sdk.dart';
import 'core/flags/feature_flags.dart';
import 'core/telemetry/telemetry_service.dart';
import 'core/telemetry/telemetry_models.dart';
import 'game/registry/card_registry.dart';
import 'game/registry/shop_registry.dart';
import 'game/registry/drop_registry.dart';
import 'game/registry/balance_registry.dart';
import 'game/registry/event_registry.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  
  await Supabase.initialize(
    url: 'https://ebqqwmvtrmstiynddixw.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVicXF3bXZ0cm1zdGl5bmRkaXh3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njg3NDYxNjksImV4cCI6MjA4NDMyMjE2OX0.onqAH3fxFYMZ04jnX3uHtDozTLFlV3m3m6PTNsODqRw',
  );

  await AuthService().init();

  await AssetRegistry.init();
  final profileService = await ProfileService.init();
  
  // Initialize Audio with profile settings
  await AudioService().init(profileService: profileService);
  
  // Initialize Card Progression
  await CardProgressionService().init();

  await SyncService().init();
  
  // Iniciar serviço de recompensas
  RewardSyncService(Supabase.instance.client).startPolling(); // Ajustado para passar client

  // --- Live Ops & Telemetry ---
  await ContentSDK.instance.inicializar();
  FeatureFlags.instance.init();
  
  // Registries (Hot Reloadable)
  CardRegistry.instance.init();
  ShopRegistry.instance.init();
  DropRegistry.instance.init();
  BalanceRegistry.instance.init();
  EventRegistry.instance.init();

  // Telemetria
  await TelemetryService.instance.init();
  if (FeatureFlags.instance.isTelemetryEnabled) {
    TelemetryService.instance.setEnabled(true);
    TelemetryService.instance.track(TelemetryEvent(
      eventType: 'app_start', 
      payload: {'version': '1.0.0'},
    ));
  } else {
    TelemetryService.instance.setEnabled(false);
  }

  runApp(DuelForgeApp(profileService: profileService));
}

class DuelForgeApp extends StatelessWidget {
  final ProfileService profileService;
  
  const DuelForgeApp({super.key, required this.profileService});

  @override
  Widget build(BuildContext context) {
    final app = AppDI(
      profileService: profileService,
      child: RewardAnimationOverlay(
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'DuelForge',
          theme: DFTheme.darkTheme,
          initialRoute: Rotas.splash,
          routes: Rotas.builders(),
        ),
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
