import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../arena/arena_controller.dart';
import '../components/tower_component.dart';
import '../components/tower_config.dart';

/// Cena de teste específica para validar o posicionamento das barras de HP.
/// Foca em garantir que a torre superior esquerda (bugada) mostre a barra corretamente.
class ExemploTesteBarrasHpGame extends FlameGame {
  late final ArenaController arenaController;

  @override
  Color backgroundColor() => const Color(0xFF222222);

  @override
  Future<void> onLoad() async {
    // 1. Configurar Arena e Câmera
    final tamanhoArena = Vector2(1000, 1800);
    camera.viewfinder.visibleGameSize = tamanhoArena;
    camera.viewfinder.position = tamanhoArena / 2;
    camera.viewfinder.anchor = Anchor.center;

    arenaController = ArenaController(tamanhoArena: tamanhoArena);
    
    // 2. Adicionar Torres nos 4 cantos para teste de limites
    
    // Superior Esquerda (O caso do BUG)
    _adicionarTorre(
      TipoTorre.lateral, 
      TimeTorre.inimigo, 
      arenaController.torreInimigoEsq, 
      "Superior Esquerda (BUG)"
    );

    // Superior Direita
    _adicionarTorre(
      TipoTorre.lateral, 
      TimeTorre.inimigo, 
      arenaController.torreInimigoDir,
      "Superior Direita"
    );

    // Inferior Esquerda
    _adicionarTorre(
      TipoTorre.lateral, 
      TimeTorre.jogador, 
      arenaController.torreJogadorEsq,
      "Inferior Esquerda"
    );

    // Inferior Direita
    _adicionarTorre(
      TipoTorre.lateral, 
      TimeTorre.jogador, 
      arenaController.torreJogadorDir,
      "Inferior Direita"
    );

    // Central Inimigo (Rei)
    _adicionarTorre(
      TipoTorre.central, 
      TimeTorre.inimigo, 
      arenaController.torreInimigoCentral,
      "Central Inimigo"
    );

    // Central Jogador (Rei)
    _adicionarTorre(
      TipoTorre.central, 
      TimeTorre.jogador, 
      arenaController.torreJogadorCentral,
      "Central Jogador"
    );
  }

  void _adicionarTorre(TipoTorre tipo, TimeTorre time, Vector2 posicao, String label) {
    final torre = TowerComponent(
      tipo: tipo,
      time: time,
      position: posicao,
    );
    torre.debugAtivo = true; // Para ver o ponto de ancoragem
    world.add(torre);
    
    // Label de debug
    world.add(TextComponent(
      text: label,
      position: posicao + Vector2(0, 50),
      anchor: Anchor.topCenter,
      textRenderer: TextPaint(style: const TextStyle(color: Colors.white, fontSize: 12)),
    ));
  }
}
