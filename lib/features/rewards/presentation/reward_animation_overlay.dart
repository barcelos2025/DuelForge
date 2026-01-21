import 'dart:async';
import 'dart:collection';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flame/components.dart' hide Timer; // Evitar conflito com dart:async
import '../domain/reward_models.dart'; // Se existir, ou usar o do event_bus
import '../domain/reward_event_bus.dart';
import 'reward_vfx_flame_component.dart';

import 'package:duelforge_proto/core/utils/number_formatter.dart';

class RewardAnimationOverlay extends StatefulWidget {
  final Widget child;
  const RewardAnimationOverlay({super.key, required this.child});

  @override
  State<RewardAnimationOverlay> createState() => _RewardAnimationOverlayState();
}

class _RewardAnimationOverlayState extends State<RewardAnimationOverlay> with TickerProviderStateMixin {
  final Queue<RewardBatch> _queue = Queue();
  bool _isPlaying = false;
  RewardBatch? _currentBatch;
  
  // Controle de animação do Card
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _opacityAnim;

  // Controle de animação "Flying"
  late AnimationController _flyController;
  
  // Flame Game
  final RewardVfxGame _vfxGame = RewardVfxGame();

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    
    // Entrada (0.0 -> 0.5)
    _scaleAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.5, curve: Curves.elasticOut)),
    );
    _opacityAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.3, curve: Curves.easeOut)),
    );

    // Saída (0.5 -> 1.0)
    // O card some voando para cima e desaparecendo
    _flyController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800)); // Not used anymore, reusing main controller

    // Ouvir eventos
    RewardEventBus().onRewardReceived.listen((batch) {
      if (mounted) {
        setState(() {
          _queue.add(batch);
        });
        _processQueue();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _flyController.dispose();
    super.dispose();
  }

  Future<void> _processQueue() async {
    if (_isPlaying || _queue.isEmpty) return;
    _isPlaying = true;

    while (_queue.isNotEmpty) {
      final batch = _queue.removeFirst();
      setState(() {
        _currentBatch = batch;
      });

      // Reset VFX
      _vfxGame.reset();

      // Fase 1: Entrada
      await _controller.animateTo(0.5, duration: const Duration(milliseconds: 600), curve: Curves.easeOut);
      
      // Som de sucesso (Placeholder)
      // AudioService.play('sfx/reward_popup.mp3');

      // Esperar leitura
      await Future.delayed(const Duration(seconds: 2));

      // Fase 2: Saída (Fly to HUD)
      await _controller.animateTo(1.0, duration: const Duration(milliseconds: 400), curve: Curves.easeIn);
      
      // Notificar consumo
      RewardEventBus().emitConsumed(batch.outboxIds);

      // Reset para o próximo
      _controller.value = 0.0;
      
      // Pequena pausa entre batches
      await Future.delayed(const Duration(milliseconds: 200));
    }

    setState(() {
      _currentBatch = null;
    });
    _isPlaying = false;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_currentBatch != null)
          Positioned.fill(
            child: Container(
              color: Colors.black54,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Flame VFX Background (atrás do card)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: GameWidget(game: _vfxGame),
                    ),
                  ),
                  
                  // Card
                  SlideTransition(
                    position: Tween<Offset>(begin: Offset.zero, end: const Offset(0, -2.0)).animate(
                      CurvedAnimation(parent: _controller, curve: const Interval(0.5, 1.0, curve: Curves.easeIn)),
                    ),
                    child: FadeTransition(
                      opacity: Tween<double>(begin: 1.0, end: 0.0).animate(
                        CurvedAnimation(parent: _controller, curve: const Interval(0.8, 1.0, curve: Curves.easeOut)),
                      ),
                      child: ScaleTransition(
                        scale: _scaleAnim, // Usa a animação de entrada (0-0.5) que mantém 1.0 depois
                        child: FadeTransition(
                          opacity: _opacityAnim, // Usa a animação de entrada
                          child: _buildRewardCard(_currentBatch!),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildRewardCard(RewardBatch batch) {
    return Container(
      width: 320,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1A1A2E).withOpacity(0.95),
            const Color(0xFF16213E).withOpacity(0.95),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.cyanAccent.withOpacity(0.6), width: 2),
        boxShadow: [
          BoxShadow(color: Colors.cyanAccent.withOpacity(0.3), blurRadius: 30, spreadRadius: 5),
          BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header com brilho
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Colors.white, Colors.cyanAccent],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ).createShader(bounds),
            child: const Text(
              'CONQUISTA!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w900,
                letterSpacing: 2.0,
                fontFamily: 'Roboto', // Ou a fonte do jogo
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Items Grid
          Wrap(
            spacing: 20,
            runSpacing: 20,
            alignment: WrapAlignment.center,
            children: batch.items.map((item) => _buildItemIcon(item)).toList(),
          ),
          
          const SizedBox(height: 30),
          
          // Botão/Texto de continuar
          const Text(
            'Toque para coletar',
            style: TextStyle(
              color: Colors.white54, 
              fontSize: 12,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemIcon(RewardItem item) {
    IconData icon;
    Color color;
    String label;
    List<Color> gradientColors;

    switch (item.resourceId) {
      case 'gold':
        icon = Icons.monetization_on_rounded;
        color = const Color(0xFFFFD700);
        gradientColors = [const Color(0xFFFFD700), const Color(0xFFFFA000)];
        label = 'Ouro';
        break;
      case 'runes':
        icon = Icons.auto_awesome;
        color = const Color(0xFFD500F9);
        gradientColors = [const Color(0xFFE040FB), const Color(0xFFAA00FF)];
        label = 'Runas';
        break;
      case 'trophies':
        icon = Icons.emoji_events_rounded;
        color = const Color(0xFFFFAB00);
        gradientColors = [const Color(0xFFFFD54F), const Color(0xFFFF6F00)];
        label = 'Troféus';
        break;
      default:
        // Cartas
        icon = Icons.style_rounded;
        color = const Color(0xFF2979FF);
        gradientColors = [const Color(0xFF448AFF), const Color(0xFF2962FF)];
        label = item.resourceId.replaceAll('_', ' ').toUpperCase();
    }

    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(color: color.withOpacity(0.4), blurRadius: 12, spreadRadius: 2),
            ],
            border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
          ),
          child: Icon(icon, color: Colors.white, size: 36),
        ),
        const SizedBox(height: 8),
        Text(
          '+${NumberFormatter.format(item.amount)}',
          style: const TextStyle(
            color: Colors.white, 
            fontWeight: FontWeight.bold, 
            fontSize: 20,
            shadows: [Shadow(color: Colors.black, blurRadius: 4)],
          ),
        ),
        Text(
          label,
          style: TextStyle(color: color.withOpacity(0.9), fontSize: 11, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}

// Wrapper simples para o GameWidget do Flame
class RewardVfxGame extends FlameGame {
  @override
  Color backgroundColor() => const Color(0x00000000); // Transparente

  @override
  Future<void> onLoad() async {
    add(RewardVfxFlameComponent());
  }
  
  void reset() {
    // Reiniciar partículas se necessário
    children.whereType<RewardVfxFlameComponent>().forEach((c) => c.reset());
  }
}
