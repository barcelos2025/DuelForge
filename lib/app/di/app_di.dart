
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
        ChangeNotifierProxyProvider<CardsRepository, BattleViewModel>(
          create: (context) => BattleViewModel(
            repositorio: context.read<CardsRepository>(),
          ),
          update: (context, repo, antigo) => antigo ?? BattleViewModel(repositorio: repo),
        ),
        ChangeNotifierProxyProvider<CardsRepository, DeckViewModel>(
          create: (context) => DeckViewModel(
            repositorio: context.read<CardsRepository>(),
          ),
          update: (context, repo, antigo) => antigo ?? DeckViewModel(repositorio: repo),
        ),
      ],
      child: child,
    );
  }
}
