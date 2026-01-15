import 'dart:async';
import 'dart:math';
import 'package:flame/components.dart' hide Timer;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../battle/data/card_catalog.dart';
import '../../../battle/data/balance_rules.dart';
import '../../../battle/domain/config/battle_field_config.dart';
import '../../../battle/domain/controllers/bot_controller.dart';
import '../../../battle/domain/entities/match_state.dart';
import '../../../battle/domain/entities/battle_objects.dart';
import '../../../battle/domain/events/battle_events.dart';
import '../../../battle/domain/logic/match_loop.dart';
import '../../../battle/domain/services/deck_service.dart';
import '../../../battle/domain/services/power_service.dart';
import '../../../battle/domain/models/replay_data.dart';
import '../../../battle/domain/services/replay_service.dart';
import '../../../battle/domain/services/telemetry_service.dart';
import '../../../battle/domain/commands/battle_command.dart';
import '../models/carta.dart';
import '../models/estado_batalha.dart';
import '../screens/match_summary_screen.dart';
import 'cards_repository.dart';

class BattleViewModel extends ChangeNotifier {
  final CardsRepository repositorio;
  BuildContext? _context; // Store context for navigation

  late MatchState matchState;
  late MatchLoop matchLoop;
  BotController? botController;
  Timer? _timer;

  // Event Stream
  final _eventController = StreamController<BattleEvent>.broadcast();
  Stream<BattleEvent> get eventStream => _eventController.stream;

  // UI State Wrappers
  Carta? cartaSelecionada;
  int tempoRestante = 180;
  
  // Backward Compatibility for UI
  late EstadoBatalha estado; 

  BattleViewModel({required this.repositorio}) {
    estado = EstadoBatalha(runaAtual: 5, runaMax: 10, regenPorSegundo: 0.83);
  }

  void setContext(BuildContext context) {
    _context = context;
  }

  Future<void> inicializar({String? replayId}) async {
    // 0. Determine Seed & Config
    int seed;
    ReplayData? replayData;
    
    if (replayId != null) {
      replayData = await ReplayService.loadReplay(replayId);
      seed = replayData?.seed ?? Random().nextInt(1000000);
    } else {
      seed = Random().nextInt(1000000);
    }

    final rng = Random(seed);
    final botProfile = BotProfile.values[rng.nextInt(BotProfile.values.length)];
    final botDifficulty = BotDifficulty.values[rng.nextInt(BotDifficulty.values.length)];
    
    final botConfig = BotConfig(
      profile: botProfile,
      difficulty: botDifficulty,
      seed: seed,
    );

    print('Match Init: Seed=$seed, Profile=${botProfile.name}, Diff=${botDifficulty.name}');

    // 1. Setup Services
    final playerDeckIds = DeckBuilder.buildDefaultDeck();
    final playerDeck = DeckService(playerDeckIds);
    final playerPower = PowerService(initialPower: 5.0);

    final enemyDeckIds = BotDecks.getDeck(botProfile);
    final enemyDeck = DeckService(enemyDeckIds);
    final enemyPower = PowerService(initialPower: 5.0);
    
    // 2. Setup Match State
    matchState = MatchState(
      matchId: 'local_match_${DateTime.now().millisecondsSinceEpoch}',
      playerPower: playerPower,
      enemyPower: enemyPower,
      playerDeck: playerDeck,
      enemyDeck: enemyDeck,
    );
    matchState.randomSeed = seed;

    // Replay Setup
    if (replayData != null) {
      matchState.isReplay = true;
      matchState.replayData = replayData;
    }
    
    // 3. Setup Logic Engine
    botController = BotController(matchState, botConfig);
    matchLoop = MatchLoop(matchState, botController: botController);
    
    matchState.onMatchEnd = (winner) async {
      if (!matchState.isReplay) {
        // Save telemetry
        matchState.telemetry.setDuration(matchState.timeElapsed);
        await TelemetryService.saveTelemetry(matchState.telemetry);
        
        // Save replay
        await saveReplay();
        
        // Show summary
        if (_context != null && _context!.mounted) {
          Navigator.of(_context!).push(
            MaterialPageRoute(
              builder: (_) => MatchSummaryScreen(
                telemetry: matchState.telemetry,
                victory: winner == BattleSide.player,
              ),
            ),
          );
        }
      }
    };

    matchState.startMatch();

    // 4. Start UI Sync Loop
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      _syncUI();
    });

    notifyListeners();
  }

  Future<void> saveReplay() async {
    final data = ReplayData(
      seed: matchState.randomSeed,
      events: matchState.recordedEvents,
    );
    await ReplayService.saveReplay(data, matchState.matchId);
    print('Replay saved: ${matchState.matchId}');
  }

  void _syncUI() {
    if (matchState.phase != MatchPhase.active && matchState.phase != MatchPhase.overtime) return;

    // Sync UI State
    estado.runaAtual = matchState.playerPower.currentPower;
    tempoRestante = matchState.remainingTime.ceil();

    notifyListeners();
  }

  bool jogarCarta(Carta cartaSelecionada, {Vector2? position}) {
    final carta = cartaSelecionada;
    
    // Determine Position (Default if null)
    Vector2 spawnPos = position ?? Vector2(0.5, 0.8);
    if (position == null && carta.tipo == TipoCarta.feitico) {
      spawnPos = Vector2(0.5, 0.5);
    }

    // Convert normalized to world
    double wx = (spawnPos.x - 0.5) * BattleFieldConfig.width;
    double wy = (spawnPos.y - 0.5) * BattleFieldConfig.height;
    Vector2 worldPos = Vector2(wx, wy);

    // Validate Deploy
    // Spells can be deployed anywhere? Usually yes.
    // Units must be in valid zone.
    if (carta.tipo != TipoCarta.feitico) {
      if (!BattleFieldConfig.isValidDeploy(worldPos, true)) {
        // Invalid position
        return false;
      }
      // Snap to Lane
      worldPos.x = BattleFieldConfig.snapToLane(worldPos.x);
    }

    if (!matchState.playerPower.consume(carta.custo)) {
      return false;
    }

    matchState.playerDeck.play(carta.id);
    
    matchLoop.enqueueCommand(PlayCardCommand(
      timestamp: matchState.timeElapsed,
      side: BattleSide.player,
      cardId: carta.id,
      x: worldPos.x,
      y: worldPos.y,
    ));

    this.cartaSelecionada = null;
    notifyListeners();
    return true;
  }
  // Helpers for UI
  List<Carta> get mao {
    return matchState.playerDeck.hand.map((id) => hydrateCard(id)).toList();
  }

  Carta? get proximaCarta {
    final nextId = matchState.playerDeck.nextCard;
    if (nextId == null) return null;
    return hydrateCard(nextId);
  }

  void selecionarCarta(Carta? carta) {
    cartaSelecionada = carta;
    notifyListeners();
  }

  bool podeJogar(Carta carta) {
    return matchState.playerPower.canConsume(carta.custo);
  }

  Carta hydrateCard(String id) {
    // Find in catalog or repo
    // Assuming catalog is available
    final def = cardCatalog.firstWhere((c) => c.cardId == id, 
      orElse: () => CardDefinition(cardId: id, cost: 0, type: CardType.tropa, archetype: 'unknown', function: 'unknown'));
    
    // Map Domain Type to UI Type
    TipoCarta uiType;
    switch (def.type) {
      case CardType.tropa: uiType = TipoCarta.tropa; break;
      case CardType.construcao: uiType = TipoCarta.construcao; break;
      case CardType.feitico: uiType = TipoCarta.feitico; break;
    }

    return Carta(
      id: def.cardId,
      nome: def.cardId.split('_').skip(2).join(' ').replaceAll('.jpg', '').replaceAll('.png', ''), // Simple name extraction
      custo: def.cost,
      tipo: uiType,
      imagePath: 'assets/cards/${def.cardId}', // Adjust path as needed
      descricao: def.function,
      raridade: def.tags.contains('legendary') ? 'lendaria' : 'comum',
      poder: 1,
    );
  }
}
