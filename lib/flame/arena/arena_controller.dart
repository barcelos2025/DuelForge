import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// Controlador responsável por gerenciar as coordenadas, zonas e lógica espacial da Arena.
/// Baseado na especificação "Odyn's Rage".
class ArenaController {
  final Vector2 tamanhoArena;

  // --- Constantes de Proporção (Baseadas em 1000x1800) ---
  static const double _alturaRio = 100.0;
  static const double _larguraPonte = 120.0;
  static const double _alturaPonte = 140.0;
  static const double _margemLateral = 50.0;
  static const double _yRioCentro = 900.0;

  // --- Zonas (Calculadas no construtor) ---
  late final Rect zonaDeployJogador;
  late final Rect zonaDeployInimigo;
  late final Rect rioRect;
  late final Rect ponteEsquerdaRect;
  late final Rect ponteDireitaRect;

  // --- Pontos das Torres ---
  late final Vector2 torreJogadorEsq;
  late final Vector2 torreJogadorDir;
  late final Vector2 torreJogadorCentral; // Rei

  late final Vector2 torreInimigoEsq;
  late final Vector2 torreInimigoDir;
  late final Vector2 torreInimigoCentral; // Rei

  // --- Caminhos (Lanes) ---
  // Usaremos List<Vector2> como waypoints principais
  late final List<Vector2> waypointsLaneEsqJogador;
  late final List<Vector2> waypointsLaneDirJogador;
  late final List<Vector2> waypointsLaneEsqInimigo;
  late final List<Vector2> waypointsLaneDirInimigo;

  ArenaController({required this.tamanhoArena}) {
    _inicializarZonas();
    _inicializarTorres();
    _inicializarWaypoints();
  }

  void _inicializarZonas() {
    final w = tamanhoArena.x;
    final h = tamanhoArena.y;
    final yRio = _yRioCentro; // Assumindo escala 1:1 com a spec ou ajustado se tamanhoArena for diferente

    // Rio
    rioRect = Rect.fromCenter(
      center: Offset(w / 2, yRio),
      width: w,
      height: _alturaRio,
    );

    // Pontes (X=200 e X=800 na spec de 1000u)
    // Ajustando proporcionalmente se o tamanhoArena não for 1000x1800
    final xPonteEsq = w * 0.2;
    final xPonteDir = w * 0.8;

    ponteEsquerdaRect = Rect.fromCenter(
      center: Offset(xPonteEsq, yRio),
      width: _larguraPonte,
      height: _alturaPonte,
    );

    ponteDireitaRect = Rect.fromCenter(
      center: Offset(xPonteDir, yRio),
      width: _larguraPonte,
      height: _alturaPonte,
    );

    // Zonas de Deploy
    // Inimigo: Topo até margem do rio
    zonaDeployInimigo = Rect.fromLTRB(
      0, 
      0, 
      w, 
      rioRect.top
    );

    // Jogador: Margem do rio até base
    zonaDeployJogador = Rect.fromLTRB(
      0, 
      rioRect.bottom, 
      w, 
      h
    );
  }

  void _inicializarTorres() {
    final w = tamanhoArena.x;
    final h = tamanhoArena.y;

    // Posições relativas baseadas na spec (Y=0 topo, Y=h base)
    // Blue (Jogador): Y ~ 0.8 (Torres), Y ~ 0.9 (Rei)
    // Red (Inimigo): Y ~ 0.2 (Torres), Y ~ 0.1 (Rei)
    
    // Usando valores fixos da spec se a arena for 1000x1800, ou proporcional
    final scaleX = w / 1000.0;
    final scaleY = h / 1800.0;

    // Jogador (Blue)
    torreJogadorCentral = Vector2(500 * scaleX, 1650 * scaleY);
    torreJogadorEsq = Vector2(200 * scaleX, 1450 * scaleY);
    torreJogadorDir = Vector2(800 * scaleX, 1450 * scaleY);

    // Inimigo (Red)
    torreInimigoCentral = Vector2(500 * scaleX, 150 * scaleY);
    torreInimigoEsq = Vector2(200 * scaleX, 350 * scaleY);
    torreInimigoDir = Vector2(800 * scaleX, 350 * scaleY);
  }

  void _inicializarWaypoints() {
    // Waypoints simplificados: Spawn -> Torre Lane -> Ponte -> Torre Inimiga -> Rei Inimigo
    
    // Jogador Lane Esquerda
    waypointsLaneEsqJogador = [
      Vector2(torreJogadorEsq.x, zonaDeployJogador.bottom - 100), // Spawn point aprox
      torreJogadorEsq,
      Vector2(ponteEsquerdaRect.center.dx, ponteEsquerdaRect.center.dy),
      torreInimigoEsq,
      torreInimigoCentral,
    ];

    // Jogador Lane Direita
    waypointsLaneDirJogador = [
      Vector2(torreJogadorDir.x, zonaDeployJogador.bottom - 100),
      torreJogadorDir,
      Vector2(ponteDireitaRect.center.dx, ponteDireitaRect.center.dy),
      torreInimigoDir,
      torreInimigoCentral,
    ];

    // Inimigo Lane Esquerda (Do ponto de vista do inimigo, é a direita dele, mas vamos manter "Esquerda do Mapa")
    // Caminho inverso visualmente
    waypointsLaneEsqInimigo = [
      Vector2(torreInimigoEsq.x, zonaDeployInimigo.top + 100),
      torreInimigoEsq,
      Vector2(ponteEsquerdaRect.center.dx, ponteEsquerdaRect.center.dy),
      torreJogadorEsq,
      torreJogadorCentral,
    ];

    // Inimigo Lane Direita
    waypointsLaneDirInimigo = [
      Vector2(torreInimigoDir.x, zonaDeployInimigo.top + 100),
      torreInimigoDir,
      Vector2(ponteDireitaRect.center.dx, ponteDireitaRect.center.dy),
      torreJogadorDir,
      torreJogadorCentral,
    ];
  }

  // --- Métodos Utilitários ---

  /// Verifica se um ponto é válido para deploy de unidade
  bool pontoEhDeployValido(Vector2 ponto, {required bool paraJogador}) {
    final zona = paraJogador ? zonaDeployJogador : zonaDeployInimigo;
    
    // Verifica limites da zona
    if (!zona.contains(ponto.toOffset())) return false;

    // Verifica se não está dentro de estruturas (simplificado aqui, idealmente checaria colisão com torres)
    // Verifica se não está no rio (já coberto pelo Rect da zona, mas por segurança)
    if (rioRect.contains(ponto.toOffset())) return false;

    return true;
  }

  /// Restringe um ponto para ficar dentro da zona de deploy válida
  Vector2 clampParaZonaDeploy(Vector2 ponto, {required bool paraJogador}) {
    final zona = paraJogador ? zonaDeployJogador : zonaDeployInimigo;
    
    double x = ponto.x.clamp(zona.left, zona.right);
    double y = ponto.y.clamp(zona.top, zona.bottom);
    
    return Vector2(x, y);
  }

  /// Retorna um ponto de spawn padrão para bots ou testes
  Vector2 obterPontoSpawnPadrao({required bool laneEsquerda, required bool paraJogador}) {
    if (paraJogador) {
      return laneEsquerda ? waypointsLaneEsqJogador.first : waypointsLaneDirJogador.first;
    } else {
      return laneEsquerda ? waypointsLaneEsqInimigo.first : waypointsLaneDirInimigo.first;
    }
  }

  /// Retorna a lista de waypoints para navegação
  List<Vector2> obterWaypointsLane({required bool laneEsquerda, required bool paraJogador}) {
    if (paraJogador) {
      return laneEsquerda ? waypointsLaneEsqJogador : waypointsLaneDirJogador;
    } else {
      return laneEsquerda ? waypointsLaneEsqInimigo : waypointsLaneDirInimigo;
    }
  }
}

/// Componente de Debug para visualizar as zonas da Arena no Flame
class ArenaDebugOverlayComponent extends PositionComponent {
  final ArenaController controller;
  bool debugAtivo = true;

  final Paint _paintZonaJogador = Paint()..color = Colors.blue.withOpacity(0.2)..style = PaintingStyle.fill;
  final Paint _paintZonaInimigo = Paint()..color = Colors.red.withOpacity(0.2)..style = PaintingStyle.fill;
  final Paint _paintRio = Paint()..color = Colors.cyan.withOpacity(0.4)..style = PaintingStyle.fill;
  final Paint _paintPonte = Paint()..color = Colors.brown.withOpacity(0.6)..style = PaintingStyle.fill;
  final Paint _paintTorre = Paint()..color = Colors.yellow..style = PaintingStyle.stroke..strokeWidth = 3;
  final Paint _paintLane = Paint()..color = Colors.white.withOpacity(0.5)..style = PaintingStyle.stroke..strokeWidth = 2;

  ArenaDebugOverlayComponent({required this.controller}) : super(priority: 100); // Alta prioridade para desenhar por cima

  @override
  void render(Canvas canvas) {
    if (!debugAtivo) return;

    // 1. Zonas
    canvas.drawRect(controller.zonaDeployJogador, _paintZonaJogador);
    canvas.drawRect(controller.zonaDeployInimigo, _paintZonaInimigo);
    
    // 2. Rio e Pontes
    canvas.drawRect(controller.rioRect, _paintRio);
    canvas.drawRect(controller.ponteEsquerdaRect, _paintPonte);
    canvas.drawRect(controller.ponteDireitaRect, _paintPonte);

    // 3. Torres (Círculos)
    _desenharTorre(canvas, controller.torreJogadorCentral, 40); // Rei maior
    _desenharTorre(canvas, controller.torreJogadorEsq, 30);
    _desenharTorre(canvas, controller.torreJogadorDir, 30);

    _desenharTorre(canvas, controller.torreInimigoCentral, 40);
    _desenharTorre(canvas, controller.torreInimigoEsq, 30);
    _desenharTorre(canvas, controller.torreInimigoDir, 30);

    // 4. Lanes (Linhas)
    _desenharCaminho(canvas, controller.waypointsLaneEsqJogador);
    _desenharCaminho(canvas, controller.waypointsLaneDirJogador);
  }

  void _desenharTorre(Canvas canvas, Vector2 pos, double raio) {
    canvas.drawCircle(pos.toOffset(), raio, _paintTorre);
    canvas.drawCircle(pos.toOffset(), 5, _paintTorre..style = PaintingStyle.fill); // Centro
  }

  void _desenharCaminho(Canvas canvas, List<Vector2> points) {
    if (points.isEmpty) return;
    final path = Path();
    path.moveTo(points.first.x, points.first.y);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].x, points[i].y);
    }
    canvas.drawPath(path, _paintLane);
    
    // Pontos do caminho
    for (var p in points) {
      canvas.drawCircle(p.toOffset(), 3, _paintLane..style = PaintingStyle.fill);
    }
  }
}
