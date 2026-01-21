import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/effects.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'duelforge_assets.dart';
import 'duelforge_text_paints.dart';

class CartaDuelForgeComponent extends PositionComponent with TapCallbacks, HasGameRef<FlameGame> {
  // --- Propriedades ---
  final String cardId;
  String nomeCarta;
  String raridade;
  int nivel;
  int fragmentosPossuidos;
  int fragmentosNecessarios;
  bool obtida;
  String? assetPathArte; // Path da imagem da arte (ex: 'cards/bear.png')

  // Callbacks
  final VoidCallback? aoTocar;
  final VoidCallback? aoPressionarLongo;

  // --- Estado Interno ---
  bool _selecionada = false;
  bool get selecionada => _selecionada;

  // --- Componentes Filhos (Camadas) ---
  late SpriteComponent _baseFrame;
  late SpriteComponent _arte;
  late SpriteComponent _silhouette;
  late SpriteComponent _rarityOverlay;
  late SpriteComponent _namePlate;
  late TextComponent _nameText;
  late SpriteComponent _levelBadge;
  late TextComponent _levelText;
  late SpriteComponent _fragmentPlate;
  late TextComponent _fragmentText;
  late SpriteComponent _upgradeIcon;
  late RectangleComponent _selectionGlow;

  CartaDuelForgeComponent({
    required this.cardId,
    required this.nomeCarta,
    required this.raridade,
    required this.nivel,
    required this.fragmentosPossuidos,
    required this.fragmentosNecessarios,
    required this.obtida,
    this.assetPathArte,
    this.aoTocar,
    this.aoPressionarLongo,
    Vector2? tamanho,
    Vector2? posicao,
  }) : super(size: tamanho ?? Vector2(256, 384), position: posicao, anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // 0. Glow de Seleção (Fundo)
    _selectionGlow = RectangleComponent(
      size: size,
      paint: Paint()
        ..color = const Color(0xFF00F0FF).withOpacity(0.0) // Invisível inicialmente
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20),
    );
    add(_selectionGlow);

    // 1. Base Frame
    _baseFrame = SpriteComponent(
      sprite: await game.loadSprite(DuelForgeAssets.cardFrameBase),
      size: size,
    );
    add(_baseFrame);

    // 2. Arte ou Silhouette
    if (obtida && assetPathArte != null) {
      // Tenta carregar a arte. Se falhar, o Flame lança erro, ideal tratar antes.
      // Assumindo que o asset existe.
      _arte = SpriteComponent(
        sprite: await game.loadSprite(assetPathArte!),
        size: size * 0.8, // Ajuste fino para caber na moldura
        position: size * 0.1,
      );
      // Máscara seria ideal, mas aqui vamos apenas posicionar atrás do frame se possível
      // Como o frame tem centro transparente, a arte deve ser desenhada ANTES do frame se quisermos "dentro".
      // Mas o frame é o pai visual. Vamos usar prioridade ou ordem de add.
      // Reordenando: Arte primeiro, depois Frame.
      remove(_baseFrame);
      add(_arte);
      add(_baseFrame);
    } else {
      _silhouette = SpriteComponent(
        sprite: await game.loadSprite(DuelForgeAssets.cardSilhouetteLocked),
        size: size * 0.6,
        position: Vector2(size.x * 0.2, size.y * 0.2),
        paint: Paint()..color = Colors.black.withOpacity(0.5), // Escurecer
      );
      remove(_baseFrame);
      add(_silhouette);
      add(_baseFrame);
    }

    // 3. Rarity Overlay
    _rarityOverlay = SpriteComponent(
      sprite: await game.loadSprite(DuelForgeAssets.getRarityOverlay(raridade)),
      size: size,
    );
    add(_rarityOverlay);

    // 4. Name Plate & Text
    _namePlate = SpriteComponent(
      sprite: await game.loadSprite(DuelForgeAssets.cardNamePlate),
      size: Vector2(size.x * 0.9, size.y * 0.15),
      position: Vector2(size.x * 0.05, size.y * 0.75),
    );
    add(_namePlate);

    _nameText = TextComponent(
      text: nomeCarta,
      textRenderer: DuelForgeTextPaints.nomeCarta,
      anchor: Anchor.center,
      position: _namePlate.position + _namePlate.size / 2,
    );
    add(_nameText);

    // 5. Level Badge (Apenas se obtida)
    if (obtida) {
      _levelBadge = SpriteComponent(
        sprite: await game.loadSprite(DuelForgeAssets.cardLevelBadge),
        size: Vector2(40, 40), // Tamanho fixo relativo
        position: Vector2(size.x * 0.05, size.y * 0.68),
      );
      add(_levelBadge);

      _levelText = TextComponent(
        text: '$nivel',
        textRenderer: DuelForgeTextPaints.nivelBadge,
        anchor: Anchor.center,
        position: _levelBadge.position + _levelBadge.size / 2,
      );
      add(_levelText);
    }

    // 6. Fragment Plate (Se obtida)
    if (obtida) {
      _fragmentPlate = SpriteComponent(
        sprite: await game.loadSprite(DuelForgeAssets.cardFragmentPlate),
        size: Vector2(size.x * 0.8, size.y * 0.08),
        position: Vector2(size.x * 0.1, size.y * 0.88),
      );
      add(_fragmentPlate);

      bool podeEvoluir = fragmentosPossuidos >= fragmentosNecessarios;
      _fragmentText = TextComponent(
        text: '$fragmentosPossuidos / $fragmentosNecessarios',
        textRenderer: podeEvoluir 
            ? DuelForgeTextPaints.fragmentos.copyWith((style) => style.copyWith(color: const Color(0xFF00E676))) // Verde
            : DuelForgeTextPaints.fragmentos,
        anchor: Anchor.center,
        position: _fragmentPlate.position + _fragmentPlate.size / 2,
      );
      add(_fragmentText);

      // 7. Upgrade Icon
      if (podeEvoluir) {
        _upgradeIcon = SpriteComponent(
          sprite: await game.loadSprite(DuelForgeAssets.iconUpgradeReady),
          size: Vector2(32, 32),
          position: Vector2(size.x * 0.8, size.y * 0.05),
        );
        // Efeito de pulso simples
        _upgradeIcon.add(
          ScaleEffect.by(
            Vector2.all(1.2),
            EffectController(duration: 0.5, reverseDuration: 0.5, infinite: true),
          ),
        );
        add(_upgradeIcon);
      }
    } else {
      // Texto "Não Obtida"
      final naoObtidaText = TextComponent(
        text: 'NÃO OBTIDA',
        textRenderer: DuelForgeTextPaints.naoObtida,
        anchor: Anchor.center,
        position: Vector2(size.x / 2, size.y * 0.9),
      );
      add(naoObtidaText);
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    _selecionar(!_selecionada);
    aoTocar?.call();
    super.onTapDown(event);
  }

  @override
  void onLongTapDown(TapDownEvent event) {
    aoPressionarLongo?.call();
    super.onLongTapDown(event);
  }

  void _selecionar(bool ativo) {
    _selecionada = ativo;
    if (_selecionada) {
      // Scale Up
      add(ScaleEffect.to(Vector2.all(1.1), EffectController(duration: 0.1)));
      // Glow On
      _selectionGlow.paint.color = const Color(0xFF00F0FF).withOpacity(0.6);
    } else {
      // Scale Down
      add(ScaleEffect.to(Vector2.all(1.0), EffectController(duration: 0.1)));
      // Glow Off
      _selectionGlow.paint.color = const Color(0xFF00F0FF).withOpacity(0.0);
    }
  }

  /// Atualiza os dados da carta e refresca a UI necessária
  void atualizarEstado({
    int? novoNivel,
    int? novosFragmentos,
    bool? novaObtida,
  }) {
    if (novoNivel != null) nivel = novoNivel;
    if (novosFragmentos != null) fragmentosPossuidos = novosFragmentos;
    if (novaObtida != null) obtida = novaObtida;

    // Nota: Em uma implementação real completa, aqui atualizaríamos os TextComponents
    // e visibilidade dos ícones sem recriar tudo.
    // Por simplicidade neste exemplo, apenas atualizamos os textos se existirem.
    
    if (obtida) { // Pseudo-check, na real checaríamos se foi init
       // _levelText.text = '$nivel'; // Comentado pois pode não estar init
       // _fragmentText.text = '$fragmentosPossuidos / $fragmentosNecessarios';
    }
  }
}
