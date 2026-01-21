import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../arena/arena_controller.dart';
import '../components/tower_component.dart';
import '../components/tower_config.dart';

/// Cena de exemplo para testar posicionamento e lógica básica das torres.
class ExemploTorresGame extends FlameGame {
  late final ArenaController arenaController;

  @override
  Color backgroundColor() => const Color(0xFF2C3E50); // Azul escuro fosco

  @override
  Future<void> onLoad() async {
    // 1. Configurar Arena e Câmera
    final tamanhoArena = Vector2(1000, 1800);
    camera.viewfinder.visibleGameSize = tamanhoArena;
    camera.viewfinder.position = tamanhoArena / 2;
    camera.viewfinder.anchor = Anchor.center;

    arenaController = ArenaController(tamanhoArena: tamanhoArena);
    
    // Adicionar Overlay de Debug da Arena (para ver se as torres batem com os pontos)
    world.add(ArenaDebugOverlayComponent(controller: arenaController)..debugAtivo = true);

    // 2. Instanciar Torres do Jogador (Azul)
    _adicionarTorre(
      TipoTorre.central, 
      TimeTorre.jogador, 
      arenaController.torreJogadorCentral
    );
    _adicionarTorre(
      TipoTorre.lateral, 
      TimeTorre.jogador, 
      arenaController.torreJogadorEsq
    );
    _adicionarTorre(
      TipoTorre.lateral, 
      TimeTorre.jogador, 
      arenaController.torreJogadorDir
    );

    // 3. Instanciar Torres do Inimigo (Vermelho)
    _adicionarTorre(
      TipoTorre.central, 
      TimeTorre.inimigo, 
      arenaController.torreInimigoCentral
    );
    _adicionarTorre(
      TipoTorre.lateral, 
      TimeTorre.inimigo, 
      arenaController.torreInimigoEsq
    );
    _adicionarTorre(
      TipoTorre.lateral, 
      TimeTorre.inimigo, 
      arenaController.torreInimigoDir
    );
  }

  void _adicionarTorre(TipoTorre tipo, TimeTorre time, Vector2 posicao) {
    final torre = TowerComponent(
      tipo: tipo,
      time: time,
      position: posicao,
    );
    
    // Ativar debug visual de alcance para todas as torres neste exemplo
    torre.debugAtivo = true;
    
    world.add(torre);
  }
}
