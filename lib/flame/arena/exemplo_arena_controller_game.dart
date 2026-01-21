import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'arena_controller.dart';

/// Exemplo de uso do ArenaController com visualização de Debug.
/// Mostra as zonas, torres e caminhos definidos na especificação.
class ExemploArenaControllerGame extends FlameGame {
  late final ArenaController arenaController;

  @override
  Color backgroundColor() => const Color(0xFF1A1A1A); // Cinza escuro para contraste

  @override
  Future<void> onLoad() async {
    // Tamanho lógico da arena conforme spec (1000x1800)
    final tamanhoArena = Vector2(1000, 1800);

    // Configura a câmera para visualizar a arena inteira
    // O Viewfinder foca no centro da arena (500, 900) e garante que 1000x1800 esteja visível
    camera.viewfinder.visibleGameSize = tamanhoArena;
    camera.viewfinder.position = tamanhoArena / 2;
    camera.viewfinder.anchor = Anchor.center;

    // Inicializa o Controlador da Arena
    arenaController = ArenaController(tamanhoArena: tamanhoArena);

    // Adiciona o componente de Debug ao mundo para desenhar as linhas e zonas
    // Como o componente desenha no Canvas usando as coordenadas do controller,
    // ele deve estar na posição (0,0) do mundo.
    world.add(ArenaDebugOverlayComponent(controller: arenaController));
  }
}
