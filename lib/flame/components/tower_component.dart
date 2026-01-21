import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'tower_config.dart';

/// Componente que representa uma torre na arena de batalha.
/// Gerencia HP, renderização e possui uma barra de vida acoplada.
class TowerComponent extends PositionComponent with TapCallbacks {
  final TipoTorre tipo;
  final TimeTorre time;
  
  // --- Atributos de Gameplay ---
  late double hpMax;
  double hpAtual = 0;
  late double alcance;
  late double cadenciaTiro;
  late double danoBase;

  // --- Estado ---
  bool get destruida => hpAtual <= 0;

  // --- Visual ---
  final Paint _paintBase = Paint();
  final Paint _paintTopo = Paint();
  final Paint _paintAlcance = Paint()
    ..color = Colors.white.withOpacity(0.1)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2;

  // Debug
  bool debugAtivo = false;

  TowerComponent({
    required this.tipo,
    required this.time,
    Vector2? position,
  }) : super(position: position, anchor: Anchor.center, priority: 10) {
    _configurarAtributos();
    _configurarPaints();
    
    // Tamanho do componente baseado no visual placeholder
    size = Vector2.all(TowerConfig.raioBaseVisual * 2);
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // Adiciona a barra de vida como filha
    add(TowerHealthBarComponent(torre: this));
  }

  void _configurarAtributos() {
    if (tipo == TipoTorre.lateral) {
      hpMax = TowerConfig.hpLateral;
      alcance = TowerConfig.alcanceLateral;
      cadenciaTiro = TowerConfig.cadenciaLateral;
      danoBase = TowerConfig.danoLateral;
    } else {
      hpMax = TowerConfig.hpCentral;
      alcance = TowerConfig.alcanceCentral;
      cadenciaTiro = TowerConfig.cadenciaCentral;
      danoBase = TowerConfig.danoCentral;
    }
    hpAtual = hpMax;
  }

  void _configurarPaints() {
    // Cor base por time
    if (time == TimeTorre.jogador) {
      _paintBase.color = const Color(0xFF2196F3); // Azul
    } else {
      _paintBase.color = const Color(0xFFF44336); // Vermelho
    }

    // Cor do topo por tipo
    if (tipo == TipoTorre.central) {
      _paintTopo.color = const Color(0xFFFFD700); // Dourado
    } else {
      _paintTopo.color = Colors.white.withOpacity(0.8); // Prata/Branco
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    if (destruida) {
      // Renderizar escombros (placeholder: cinza escuro e menor)
      canvas.drawCircle(
        (size / 2).toOffset(),
        size.x / 3,
        Paint()..color = Colors.grey.shade800,
      );
      return;
    }

    // 1. Renderizar Base da Torre (Placeholder)
    final raio = size.x / 2;
    final centro = (size / 2).toOffset();

    // Corpo
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: centro, width: size.x * 0.8, height: size.y),
        const Radius.circular(8),
      ),
      _paintBase,
    );

    // Topo
    canvas.drawCircle(
      centro,
      raio * 0.6,
      _paintTopo,
    );

    // 2. Debug Alcance
    if (debugAtivo) {
      canvas.drawCircle(centro, alcance, _paintAlcance);
    }
  }

  /// Aplica dano à torre. Retorna true se foi destruída neste hit.
  bool receberDano(double dano) {
    if (destruida) return false;

    hpAtual -= dano;
    if (hpAtual <= 0) {
      hpAtual = 0;
      // TODO: Tocar SFX de destruição
      return true;
    }
    return false;
  }

  /// Reseta a torre para o estado inicial
  void resetar() {
    hpAtual = hpMax;
  }

  @override
  void onTapDown(TapDownEvent event) {
    receberDano(100);
    debugPrint('Torre ${tipo.name} ($time) recebeu dano. HP: $hpAtual/$hpMax');
    super.onTapDown(event);
  }
}

/// Componente dedicado para a barra de vida da torre.
/// Garante renderização acima da torre e clamp na tela.
class TowerHealthBarComponent extends PositionComponent with HasGameRef {
  final TowerComponent torre;
  
  final Paint _paintBarraFundo = Paint()..color = Colors.black54;
  final Paint _paintBarraVida = Paint();

  // Configuração
  static const double _largura = TowerConfig.larguraBarraVida;
  static const double _altura = TowerConfig.alturaBarraVida;
  static const double _offsetPadraoY = -15.0; // Acima da torre
  static const double _marginTopoTela = 50.0; // Margem de segurança do topo

  TowerHealthBarComponent({required this.torre}) : super(priority: 20, anchor: Anchor.bottomCenter);

  @override
  void onLoad() {
    super.onLoad();
    // Define cor baseada no time da torre
    if (torre.time == TimeTorre.jogador) {
      _paintBarraVida.color = const Color(0xFF4CAF50); // Verde
    } else {
      _paintBarraVida.color = const Color(0xFFE91E63); // Rosa/Vermelho
    }
    
    size = Vector2(_largura, _altura);
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    // 1. Posicionamento Base (Relativo ao centro da torre)
    // TowerComponent é Anchor.center.
    // Topo da torre: -torre.size.y / 2
    // Base da torre: +torre.size.y / 2
    
    double targetY;
    
    if (torre.time == TimeTorre.jogador) {
      // Jogador: Barra ACIMA da torre
      targetY = -torre.size.y / 2 + _offsetPadraoY; 
    } else {
      // Inimigo: Barra ABAIXO da torre (para não bater no topo da tela/HUD)
      // Usamos Anchor.bottomCenter, então precisamos descer:
      // Base da torre (+size/2) + Altura da barra + Margem
      targetY = torre.size.y / 2 + height + 5.0;
    }
    
    // 2. Clamp para dentro da tela (Correção do Bug da Torre Superior)
    // Precisamos da posição absoluta no mundo para comparar com a câmera
    final worldPos = torre.position + Vector2(0, targetY);
    
    // Obtém o retângulo visível da câmera (aproximado)
    // Assumindo que a câmera não rotaciona e o jogo usa coordenadas de mundo padrão.
    // Se o jogo usa CameraComponent, visibleWorldRect é o ideal.
    // Como fallback simples, verificamos se y < 0 (topo da arena).
    
    double minY = 0;
    try {
      // Tenta pegar o topo da câmera se disponível
      minY = gameRef.camera.visibleWorldRect.top + _marginTopoTela;
    } catch (e) {
      minY = _marginTopoTela; // Fallback
    }

    if (worldPos.y < minY) {
      // Se estourou o topo, empurra para baixo
      // Novo Y relativo = (MinY Absoluto - Torre Y Absoluto)
      targetY = minY - torre.position.y;
    }

    // Aplica a posição calculada
    // X é 0 pois é relativo ao centro da torre e usamos Anchor.bottomCenter
    position = Vector2(0, targetY);
  }

  @override
  void render(Canvas canvas) {
    if (torre.destruida) return;

    // Fundo
    canvas.drawRect(
      Rect.fromLTWH(0, 0, width, height),
      _paintBarraFundo,
    );

    // Vida
    final pct = (torre.hpAtual / torre.hpMax).clamp(0.0, 1.0);
    canvas.drawRect(
      Rect.fromLTWH(0, 0, width * pct, height),
      _paintBarraVida,
    );
    
    // Debug Clamp (Opcional)
    if (torre.debugAtivo) {
      canvas.drawCircle(Offset(width/2, height), 2, Paint()..color = Colors.yellow);
    }
  }
}
