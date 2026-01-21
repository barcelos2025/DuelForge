import 'dart:async';
import 'package:flame/components.dart';

/// Singleton para gerenciar eventos de VFX desacoplados da lógica do jogo.
class DuelForgeVfxBus {
  static final DuelForgeVfxBus _instance = DuelForgeVfxBus._internal();
  factory DuelForgeVfxBus() => _instance;
  DuelForgeVfxBus._internal();

  final _controller = StreamController<VfxEvent>.broadcast();

  Stream<VfxEvent> get stream => _controller.stream;

  void emit(VfxEvent event) {
    _controller.add(event);
  }

  void dispose() {
    _controller.close();
  }
}

/// Classe base para todos os eventos de VFX
abstract class VfxEvent {}

// --- Eventos de Gameplay ---

class EventoCartaDeploy extends VfxEvent {
  final Vector2 posicao;
  final String cartaId;
  final String raridade;
  EventoCartaDeploy(this.posicao, this.cartaId, this.raridade);
}

class EventoTorreAtira extends VfxEvent {
  final Vector2 origem;
  final Vector2 alvo;
  final String time; // 'player' ou 'enemy'
  EventoTorreAtira(this.origem, this.alvo, this.time);
}

class EventoTorreAcerta extends VfxEvent {
  final Vector2 pontoImpacto;
  final String time;
  EventoTorreAcerta(this.pontoImpacto, this.time);
}

class EventoTorreDestruida extends VfxEvent {
  final Vector2 posicao;
  final String tipoTorre; // 'king' ou 'princess'
  final String time;
  EventoTorreDestruida(this.posicao, this.tipoTorre, this.time);
}

class EventoUnidadeSpawn extends VfxEvent {
  final Vector2 posicao;
  final String unidadeId;
  final String raridade;
  EventoUnidadeSpawn(this.posicao, this.unidadeId, this.raridade);
}

class EventoUnidadeAtaca extends VfxEvent {
  final Vector2 origem;
  final Vector2 alvo;
  final String unidadeId;
  EventoUnidadeAtaca(this.origem, this.alvo, this.unidadeId);
}

class EventoAcerto extends VfxEvent {
  final Vector2 pontoImpacto;
  final String tipoDano; // 'fisico', 'magico', 'fogo', 'gelo', 'veneno', 'eletrico'
  final bool critico;
  EventoAcerto(this.pontoImpacto, this.tipoDano, {this.critico = false});
}

class EventoFeiticoCast extends VfxEvent {
  final Vector2 areaCentro;
  final double raio;
  final String spellId;
  EventoFeiticoCast(this.areaCentro, this.raio, this.spellId);
}

class EventoCongelamentoAplicado extends VfxEvent {
  final Vector2 alvoPosicao;
  final double intensidade;
  EventoCongelamentoAplicado(this.alvoPosicao, this.intensidade);
}

class EventoVenenoTick extends VfxEvent {
  final Vector2 alvoPosicao;
  EventoVenenoTick(this.alvoPosicao);
}

class EventoRaioImpacto extends VfxEvent {
  final Vector2 pontoImpacto;
  final int saltos;
  EventoRaioImpacto(this.pontoImpacto, this.saltos);
}

class EventoCameraShake extends VfxEvent {
  final double intensidade;
  final double duracao;
  EventoCameraShake({this.intensidade = 5.0, this.duracao = 0.2});
}
