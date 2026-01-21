
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../features/battle/viewmodels/battle_view_model.dart';
import '../../features/battle/viewmodels/cards_repository.dart';
import '../../features/deck/viewmodels/deck_view_model.dart';
import '../../features/profile/services/profile_service.dart';

class AppDI extends StatelessWidget {
  final Widget child;
  final ProfileService profileService;
  
  const AppDI({super.key, required this.child, required this.profileService});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: profileService),
        Provider<CardsRepository>(
          create: (_) => CardsRepository(),
        ),
        ChangeNotifierProxyProvider2<CardsRepository, ProfileService, BattleViewModel>(
          create: (context) => BattleViewModel(
            repositorio: context.read<CardsRepository>(),
            profileService: context.read<ProfileService>(),
          ),
          update: (context, repo, profile, antigo) => antigo ?? BattleViewModel(repositorio: repo, profileService: profile),
        ),
        ChangeNotifierProxyProvider2<CardsRepository, ProfileService, DeckViewModel>(
          create: (context) => DeckViewModel(
            repositorio: context.read<CardsRepository>(),
            profileService: context.read<ProfileService>(),
          ),
          update: (context, repo, profile, antigo) => antigo ?? DeckViewModel(repositorio: repo, profileService: profile),
        ),
      ],
      child: child,
    );
  }
}
