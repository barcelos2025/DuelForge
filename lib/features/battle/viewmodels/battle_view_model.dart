import 'dart:async';
import 'dart:math';
import 'package:flame/components.dart' hide Timer;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Imports de Domínio e Dados
import '../../../battle/data/card_catalog.dart';
import '../../../battle/domain/config/battle_field_config.dart';
import '../../../battle/domain/controllers/bot_controller.dart';
import '../../../battle/domain/ai/ai_core.dart';
import '../../../battle/domain/difficulty/difficulty_manager.dart';
import '../../../battle/domain/difficulty/session_tracker.dart';
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
import '../domain/models/arena_definition.dart';
import '../../../core/audio/audio_service.dart';
import '../../profile/services/profile_service.dart';

class BattleViewModel extends ChangeNotifier {
  final CardsRepository repositorio;
  final ProfileService profileService;
  BuildContext? _context; // Contexto para navegação

  // Estado da Partida (Lógica Core)
  late MatchState matchState;
  late MatchLoop matchLoop;
  BotController? botController;
  Timer? _timer;
  bool _isInitialized = false;

  // Stream de Eventos (Desacoplamento UI)
  final _eventController = StreamController<BattleEvent>.broadcast();
  Stream<BattleEvent> get eventStream => _eventController.stream;

  // Estado de UI (Wrappers)
  Carta? cartaSelecionada;
  int tempoRestante = 180;
  
  // Lógica de Arena
  int get _trofeusJogador => profileService.trophies;
  ArenaDefinition get arenaAtual => ArenaCatalog.getArenaForTrophies(_trofeusJogador);
  // Alias para compatibilidade com UI legada
  ArenaDefinition get currentArena => arenaAtual;
  
  // Compatibilidade com UI Legada
  late EstadoBatalha estado; 

  BattleViewModel({required this.repositorio, required this.profileService}) {
    // Inicializa estado visual padrão
    estado = EstadoBatalha(runaAtual: 10, runaMax: 10, regenPorSegundo: 0.83);
  }

  void setContext(BuildContext context) {
    _context = context;
  }

  /// Inicializa a batalha, garantindo que todos os recursos necessários estejam carregados.
  Future<void> inicializar({String? replayId}) async {
    debugPrint('⚔️ BattleViewModel: Inicializando batalha...');

    // 1. Garantir carregamento do Repositório de Cartas (CRÍTICO)
    if (!repositorio.carregado) {
      debugPrint('⚠️ CardsRepository não carregado. Forçando carregamento...');
      await repositorio.carregar();
    }

    // 2. Determinar Seed e Configuração
    int seed;
    ReplayData? replayData;
    
    if (replayId != null) {
      replayData = await ReplayService.loadReplay(replayId);
      seed = replayData?.seed ?? Random().nextInt(1000000);
    } else {
      seed = Random().nextInt(1000000);
    }

    final rng = Random(seed);
    final perfilBot = BotProfile.values[rng.nextInt(BotProfile.values.length)];
    
    // Registrar início de partida na sessão
    SessionTracker().registerMatchStart();

    // Gerar ID da partida antecipadamente
    final matchId = 'local_match_${DateTime.now().millisecondsSinceEpoch}';

    // Configuração Dinâmica de IA
    final trofeus = profileService.trophies;
    final winRate = profileService.winRate;
    final nivelMedio = profileService.averageCardLevel;
    final consecutiveLosses = profileService.consecutiveLosses;

    final configBot = DifficultyManager().calculateMatchConfig(
      playerTrophies: trofeus,
      playerWinRate: winRate,
      playerAvgCardLevel: nivelMedio,
      consecutiveLosses: consecutiveLosses,
      consecutiveWins: 0,
      matchId: matchId,
    );

    debugPrint('🎲 Match Init: Seed=$seed, Bot=${configBot.id}, Policy=${configBot.policy.name}, Knobs=${configBot.knobs}');

    // 3. Configurar Serviços de Domínio
    // Tenta carregar o deck ativo do perfil. Se falhar, usa o default.
    List<String> idsDeckJogador;
    try {
      final deckAtivo = profileService.profile.decks.firstWhere((d) => d.isActive);
      idsDeckJogador = deckAtivo.cardIds;
      debugPrint('🎴 Deck carregado do perfil: ${deckAtivo.name} (${idsDeckJogador.length} cartas)');
      debugPrint('   IDs: $idsDeckJogador');
    } catch (e) {
      debugPrint('⚠️ Nenhum deck ativo encontrado. Usando deck padrão.');
      idsDeckJogador = DeckBuilder.buildDefaultDeck();
      debugPrint('   IDs padrão: $idsDeckJogador');
    }

    final deckJogador = DeckService(idsDeckJogador);
    final poderJogador = PowerService(initialPower: 10.0);

    final idsDeckInimigo = BotDecks.getDeck(perfilBot);
    final deckInimigo = DeckService(idsDeckInimigo);
    final poderInimigo = PowerService(initialPower: 10.0);
    
    // 4. Configurar Estado da Partida (MatchState)
    matchState = MatchState(
      matchId: matchId,
      playerPower: poderJogador,
      enemyPower: poderInimigo,
      playerDeck: deckJogador,
      enemyDeck: deckInimigo,
    );
    matchState.randomSeed = seed;

    // Preencher níveis das cartas do jogador
    for (final cardId in idsDeckJogador) {
      matchState.playerCardLevels[cardId] = profileService.getCardLevel(cardId);
    }

    // Configuração de Replay
    if (replayData != null) {
      matchState.isReplay = true;
      matchState.replayData = replayData;
    }
    
    // 5. Configurar Engine Lógica (Loop)
    botController = BotController(matchState, configBot, seed: seed);
    matchLoop = MatchLoop(matchState, botController: botController);
    
    // Callback de Fim de Partida
    matchState.onMatchEnd = (vencedor) async {
      if (!matchState.isReplay) {
        // Lógica de Áudio
        final audio = AudioService();
        await audio.fadeOutMusic(duration: const Duration(milliseconds: 500));
        
        if (vencedor == BattleSide.player) {
          audio.playSfx('victory_stinger.mp3');
        } else {
          audio.playSfx('defeat_stinger.mp3');
        }

        // Salvar Telemetria
        matchState.telemetry.setDuration(matchState.timeElapsed);
        // Salvar Telemetria
        matchState.telemetry.setDuration(matchState.timeElapsed);
        await TelemetryService.saveTelemetry(matchState.telemetry);
        
        // Reportar Resultado para ProfileService (Tilt Assist)
        profileService.reportMatchResult(vencedor == BattleSide.player);
        
        // Salvar Replay
        await _salvarReplay();
        
        // Navegar para Resumo
        if (_context != null && _context!.mounted) {
          Navigator.of(_context!).push(
            MaterialPageRoute(
              builder: (_) => MatchSummaryScreen(
                telemetry: matchState.telemetry,
                victory: vencedor == BattleSide.player,
              ),
            ),
          );
        }
      }
      
      // Notificar UI
      _eventController.add(MatchEndEvent(
        winner: vencedor.name,
      ));
    };

    matchState.startMatch();

    // 6. Iniciar Loop de Sincronização UI (10fps é suficiente para barras, o jogo roda no Flame)
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      _sincronizarUI();
    });

    _isInitialized = true;
    notifyListeners();
    debugPrint('✅ Batalha inicializada com sucesso.');
  }

  Future<void> _salvarReplay() async {
    final data = ReplayData(
      seed: matchState.randomSeed,
      events: matchState.recordedEvents,
    );
    await ReplayService.saveReplay(data, matchState.matchId);
    debugPrint('💾 Replay salvo: ${matchState.matchId}');
  }

  void _sincronizarUI() {
    if (!_isInitialized) return;
    if (matchState.phase != MatchPhase.active && matchState.phase != MatchPhase.overtime) return;

    // Sincroniza estado reativo para UI Flutter
    final oldPower = estado.runaAtual;
    estado.runaAtual = matchState.playerPower.currentPower;
    tempoRestante = matchState.remainingTime.ceil();
    
    if ((oldPower - estado.runaAtual).abs() > 0.1) {
       debugPrint('⏱️ UI Sync: Power Changed: ${oldPower.toStringAsFixed(2)} -> ${estado.runaAtual.toStringAsFixed(2)}');
    }

    notifyListeners();
  }

  bool jogarCarta(Carta cartaSelecionada, {Vector2? position}) {
    if (!_isInitialized) return false;
    final carta = cartaSelecionada;
    
    // Determinar Posição (Default se nulo)
    Vector2 posSpawn = position ?? Vector2(0.5, 0.8);
    if (position == null && carta.tipo == TipoCarta.feitico) {
      posSpawn = Vector2(0.5, 0.5); // Feitiços sem alvo vão no centro por padrão
    }

    // Converter normalizado (0..1) para mundo
    double wx = (posSpawn.x - 0.5) * BattleFieldConfig.width;
    double wy = (posSpawn.y - 0.5) * BattleFieldConfig.height;
    Vector2 posMundo = Vector2(wx, wy);

    // Validar Deploy
    if (carta.tipo != TipoCarta.feitico) {
      if (!BattleFieldConfig.isValidDeploy(posMundo, true)) {
        return false; // Posição inválida
      }
      // Snap to Lane (Alinhar com rotas)
      posMundo.x = BattleFieldConfig.snapToLane(posMundo.x);
    }

    // Verificar Custo
    if (!matchState.playerPower.consume(carta.custo)) {
      return false; // Sem elixir suficiente
    }

    // Executar Jogada
    matchState.playerDeck.play(carta.id);
    
    // Enfileirar Comando (Determinismo)
    matchLoop.enqueueCommand(PlayCardCommand(
      timestamp: matchState.timeElapsed,
      side: BattleSide.player,
      cardId: carta.id,
      x: posMundo.x,
      y: posMundo.y,
    ));

    // SFX
    AudioService().playDeploySfx();

    this.cartaSelecionada = null;
    notifyListeners();
    return true;
  }

  // Getters para UI
  List<Carta> get mao {
    if (!_isInitialized) return [];
    // Hidrata os IDs do deck usando o repositório oficial
    return matchState.playerDeck.hand.map((id) => _hidratarCarta(id)).toList();
  }

  Carta? get proximaCarta {
    if (!_isInitialized) return null;
    final nextId = matchState.playerDeck.nextCard;
    if (nextId == null) return null;
    return _hidratarCarta(nextId);
  }

  void selecionarCarta(Carta? carta) {
    cartaSelecionada = carta;
    notifyListeners();
  }

  bool podeJogar(Carta carta) {
    if (!_isInitialized) return false;
    return matchState.playerPower.canConsume(carta.custo);
  }

  /// Converte um ID de carta em um objeto Carta completo para a UI.
  /// Usa o CardsRepository como fonte da verdade.
  Carta _hidratarCarta(String id) {
    // 1. Tentar buscar no Repositório (Dados do Banco/JSON)
    if (repositorio.carregado) {
      try {
        debugPrint('🔍 Hidratando carta: "$id"');
        return repositorio.porId(id);
      } catch (e) {
        debugPrint('⚠️ Erro ao hidratar carta "$id" do repositório: $e');
      }
    }

    // 2. Fallback de Emergência (CardCatalog legado)
    // Isso só deve acontecer se o ID não existir no repositório (ex: ID antigo 'df_card_...')
    debugPrint('⚠️ Usando fallback legado para carta: $id');
    
    final def = cardCatalog.firstWhere(
      (c) => c.cardId == id, 
      orElse: () => CardDefinition(
        cardId: id, 
        cost: 0, 
        type: CardType.tropa, 
        archetype: 'unknown', 
        function: 'unknown',
        tags: [],
      )
    );
    
    TipoCarta tipoUI;
    switch (def.type) {
      case CardType.tropa: tipoUI = TipoCarta.tropa; break;
      case CardType.construcao: tipoUI = TipoCarta.construcao; break;
      case CardType.feitico: tipoUI = TipoCarta.feitico; break;
    }

    String raridade = 'comum';
    if (def.tags.contains('legendary')) raridade = 'lendaria';
    else if (def.tags.contains('epic')) raridade = 'epica';
    else if (def.tags.contains('rare')) raridade = 'rara';

    return Carta(
      id: def.cardId,
      // Tenta limpar o nome se for um filename
      nome: def.cardId.contains('_') 
          ? def.cardId.split('_').skip(2).join(' ').replaceAll('.jpg', '').replaceAll('.png', '')
          : def.cardId,
      custo: def.cost,
      tipo: tipoUI,
      imagePath: 'assets/cards/${def.cardId}',
      descricao: def.function,
      raridade: raridade,
      poder: profileService.getCardLevel(def.cardId),
    );
  }
}
