import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flame/game.dart';
import '../../battle/presentation/game/battle_game.dart';
import 'viewmodels/battle_view_model.dart';
import 'models/carta.dart';
import '../../ui/theme/df_theme.dart';
import '../../battle/domain/events/battle_events.dart' as events;
import '../../battle/domain/config/battle_field_config.dart';
import '../../battle/presentation/widgets/hud/battle_hud.dart';
import '../../core/assets/asset_registry.dart';
import '../../core/audio/audio_service.dart';
import '../../features/profile/services/profile_service.dart';

import 'dart:math';

class BattleScreen extends StatefulWidget {
  const BattleScreen({super.key});

  @override
  State<BattleScreen> createState() => _BattleScreenState();
}

class _BattleScreenState extends State<BattleScreen> {
  BattleGame? _game; // Nullable until VM init
  late int _arenaIndex;
  StreamSubscription? _eventSubscription;
  BattleViewModel? _vm;

  @override
  void initState() {
    super.initState();
    _arenaIndex = Random().nextInt(6) + 1; // 1 a 6
    
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        _vm = context.read<BattleViewModel>();
        final profileService = context.read<ProfileService>();
        _vm!.setContext(context); // Set context for navigation
        
        await _vm!.inicializar();
        
        if (!mounted) return;
        
        _vm!.addListener(_syncSelection);

        setState(() {
          _game = BattleGame(
            matchState: _vm!.matchState, 
            matchLoop: _vm!.matchLoop,
            onDeploy: (carta, position) {
               final normalizedX = (position.x / BattleFieldConfig.width) + 0.5;
               final normalizedY = (position.y / BattleFieldConfig.height) + 0.5;
               
               _vm!.jogarCarta(carta, position: Vector2(normalizedX, normalizedY));
            },
            onCancel: () {
               _vm!.selecionarCarta(null);
            },
            arenaAssetPath: _vm!.currentArena.assetPath,
          );
        });
        
        _eventSubscription = _vm!.eventStream.listen(_handleBattleEvent);
        
        // Listen to MatchState events for Game Over
        _vm!.matchState.onMatchEnd = (winner) {
           _onGameEvent('game_over', {'winner': winner.name});
        };
      } catch (e, stackTrace) {
        print('❌ Error initializing BattleScreen: $e');
        print('Stack trace: $stackTrace');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao iniciar batalha: $e')),
          );
          Navigator.of(context).pop();
        }
      }
    });
  }

  @override
  void dispose() {
    _vm?.removeListener(_syncSelection);
    _eventSubscription?.cancel();
    super.dispose();
  }

  void _syncSelection() {
    if (_game == null || _vm == null) return;
    if (_vm!.cartaSelecionada != null) {
      _game!.selectCard(_vm!.cartaSelecionada!);
    } else {
      _game!.deselectCard();
    }
  }

  void _handleBattleEvent(events.BattleEvent event) {
    if (event is events.MatchEndEvent) {
      _onGameEvent('game_over', {'winner': event.winner});
    }
  }

  void _onGameEvent(String evento, Map<String, dynamic> payload) {
    if (evento == 'game_over') {
      final winner = payload['winner'];
      final isVictory = winner == 'player';
      
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF1E1E2C),
          title: Text(
            isVictory ? 'VITÓRIA!' : 'DERROTA',
            style: TextStyle(
              color: isVictory ? Colors.cyanAccent : Colors.redAccent,
              fontWeight: FontWeight.bold,
              fontSize: 28,
            ),
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isVictory ? Icons.emoji_events : Icons.sentiment_very_dissatisfied,
                size: 64,
                color: isVictory ? Colors.amber : Colors.grey,
              ),
              const SizedBox(height: 16),
              Text(
                isVictory ? 'Você destruiu o Rei inimigo!' : 'Seu Rei caiu...',
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Fecha Dialog
                Navigator.pop(context); // Sai da Batalha
              },
              child: const Text('VOLTAR', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    final vm = context.watch<BattleViewModel>();

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Game Engine (Flame) with Arena Background
          Positioned.fill(
            child: _game != null 
                ? DragTarget<Carta>(
                    onWillAccept: (carta) {
                      return carta != null && _vm!.podeJogar(carta);
                    },
                    onAccept: (carta) {
                      _game!.attemptDeploy();
                    },
                    onMove: (details) {
                      final renderBox = context.findRenderObject() as RenderBox?;
                      if (renderBox != null) {
                        final localOffset = renderBox.globalToLocal(details.offset);
                        _game!.updateGhost(Vector2(localOffset.dx, localOffset.dy));
                      }
                    },
                    onLeave: (data) {
                      // Keep ghost visible
                    },
                    builder: (context, candidateData, rejectedData) {
                      return GameWidget(
                        game: _game!,
                        backgroundBuilder: (context) => Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage(vm.currentArena.assetPath),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      );
                    },
                  )
                : const Center(child: CircularProgressIndicator()),
          ),

          // ... HUDs ...

          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: _TopHud(tempoRestante: vm.tempoRestante),
            ),
          ),

          // 5. HUD Inferior (Mão, Elixir, Próxima Carta)
          const BattleHud(),
          
          // Botão de Voltar (Debug)
          Positioned(
            top: 40,
            left: 10,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                AudioService().playMusic('main_menu_theme.mp3');
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ArenaBackground extends StatelessWidget {
  final String assetPath;
  const _ArenaBackground({required this.assetPath});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(assetPath),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class _TopHud extends StatelessWidget {
  final int tempoRestante;

  const _TopHud({required this.tempoRestante});

  String get _formattedTime {
    final m = tempoRestante ~/ 60;
    final s = tempoRestante % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Placar Inimigo
          const _CrownCounter(count: 0, isEnemy: true),
          
          // Tempo
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white24),
            ),
            child: Text(
              _formattedTime,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),

          // Placar Aliado
          const _CrownCounter(count: 0, isEnemy: false),
        ],
      ),
    );
  }
}

class _CrownCounter extends StatelessWidget {
  final int count;
  final bool isEnemy;

  const _CrownCounter({required this.count, required this.isEnemy});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(3, (index) {
        final active = index < count;
        return Icon(
          Icons.emoji_events, // Coroa
          color: active ? DFTheme.gold : Colors.black38,
          size: 28,
        );
      }),
    );
  }
}


