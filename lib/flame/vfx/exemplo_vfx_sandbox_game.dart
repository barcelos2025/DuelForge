import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'duelforge_vfx_bus.dart';
import 'duelforge_vfx_system.dart';

/// Game loop isolado para testar VFX sem carregar o jogo inteiro.
class ExemploVfxSandboxGame extends FlameGame with TapDetector {
  @override
  Future<void> onLoad() async {
    // Adiciona o sistema de VFX ao mundo
    add(DuelForgeVfxSystem());
  }

  @override
  void onTapUp(TapUpInfo info) {
    final pos = info.eventPosition.game;
    
    // Cicla entre efeitos para teste a cada clique
    final time = DateTime.now().millisecondsSinceEpoch;
    final tipo = time % 5;

    if (tipo == 0) {
      DuelForgeVfxBus().emit(EventoAcerto(pos, 'fisico'));
    } else if (tipo == 1) {
      DuelForgeVfxBus().emit(EventoAcerto(pos, 'fogo'));
    } else if (tipo == 2) {
      DuelForgeVfxBus().emit(EventoAcerto(pos, 'gelo'));
    } else if (tipo == 3) {
      DuelForgeVfxBus().emit(EventoFeiticoCast(pos, 50, 'poison'));
    } else {
      DuelForgeVfxBus().emit(EventoRaioImpacto(pos, 1));
    }
  }
}

// Widget wrapper para rodar o sandbox
class VfxSandboxWidget extends StatelessWidget {
  const VfxSandboxWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GameWidget(game: ExemploVfxSandboxGame());
  }
}
