import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'arena_controller.dart';
import 'arena_background_component.dart';
import '../components/tower_component.dart';
import '../components/tower_config.dart';

/// Exemplo completo da Arena com Background, Torres e Debug.
class ExemploArenaCompletaGame extends FlameGame {
  late final ArenaController arenaController;

  @override
  Color backgroundColor() => const Color(0xFF000000); // Fundo preto (o componente cobrirá)

  @override
  Future<void> onLoad() async {
    // 1. Configurar Arena e Câmera
    final tamanhoArena = Vector2(1000, 1800);
    camera.viewfinder.visibleGameSize = tamanhoArena;
    camera.viewfinder.position = tamanhoArena / 2;
    camera.viewfinder.anchor = Anchor.center;

    arenaController = ArenaController(tamanhoArena: tamanhoArena);
    
    // 2. Adicionar Background (Chão, Rio, Pontes)
    world.add(ArenaBackgroundComponent(controller: arenaController));

    // 3. Adicionar Overlay de Debug (Opcional, para validar alinhamento)
    // world.add(ArenaDebugOverlayComponent(controller: arenaController)..debugAtivo = true);

    // 4. Instanciar Torres
    _spawnTorres();
  }

  void _spawnTorres() {
    // Jogador (Azul)
    _adicionarTorre(TipoTorre.central, TimeTorre.jogador, arenaController.torreJogadorCentral);
    _adicionarTorre(TipoTorre.lateral, TimeTorre.jogador, arenaController.torreJogadorEsq);
    _adicionarTorre(TipoTorre.lateral, TimeTorre.jogador, arenaController.torreJogadorDir);

    // Inimigo (Vermelho)
    _adicionarTorre(TipoTorre.central, TimeTorre.inimigo, arenaController.torreInimigoCentral);
    _adicionarTorre(TipoTorre.lateral, TimeTorre.inimigo, arenaController.torreInimigoEsq);
    _adicionarTorre(TipoTorre.lateral, TimeTorre.inimigo, arenaController.torreInimigoDir);
  }

  void _adicionarTorre(TipoTorre tipo, TimeTorre time, Vector2 posicao) {
    world.add(TowerComponent(
      tipo: tipo,
      time: time,
      position: posicao,
    ));
  }
}
