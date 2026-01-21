import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';

import '../ui/duelforge_assets.dart';
import '../ui/carta_duelforge_component.dart';

class ExemploCartaScene extends FlameGame { // HasTappables deprecated em versões novas, usar TapCallbacks no componente e HasTappablesBridge ou nada se v1.8+
  // Nota: Em Flame v1.8+, HasTappables é obsoleto. O mixin no componente (TapCallbacks) + o jogo detectar input é o padrão.
  // Se der erro, remover HasTappables e garantir que o GameWidget tenha suporte a input.

  @override
  Color backgroundColor() => const Color(0xFF05080F); // Fundo escuro

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // 1. Carregar Assets Globais
    await DuelForgeAssets.carregarAssetsCartas(this);
    // Carregar assets de exemplo (placeholders)
    // await images.load('cards/bear.png'); // Exemplo

    // 2. Criar Cartas de Exemplo
    final tamanhoCarta = Vector2(200, 300);
    final yPos = size.y / 2;
    final espacamento = 220.0;

    // Carta 1: Não Obtida
    add(CartaDuelForgeComponent(
      cardId: 'c1',
      nomeCarta: 'Guerreiro',
      raridade: 'comum',
      nivel: 1,
      fragmentosPossuidos: 0,
      fragmentosNecessarios: 10,
      obtida: false,
      tamanho: tamanhoCarta,
      posicao: Vector2(100, yPos),
      aoTocar: () => print('Tocou na carta 1'),
    ));

    // Carta 2: Obtida, Normal
    add(CartaDuelForgeComponent(
      cardId: 'c2',
      nomeCarta: 'Arqueira',
      raridade: 'raro',
      nivel: 3,
      fragmentosPossuidos: 5,
      fragmentosNecessarios: 20,
      obtida: true,
      // assetPathArte: 'cards/archer.png', // Comentar se não tiver asset real
      tamanho: tamanhoCarta,
      posicao: Vector2(100 + espacamento, yPos),
    ));

    // Carta 3: Pronta para Evoluir
    add(CartaDuelForgeComponent(
      cardId: 'c3',
      nomeCarta: 'Mago',
      raridade: 'epico',
      nivel: 2,
      fragmentosPossuidos: 10,
      fragmentosNecessarios: 5, // Pode evoluir!
      obtida: true,
      tamanho: tamanhoCarta,
      posicao: Vector2(100 + espacamento * 2, yPos),
    ));

    // Carta 4: Lendária
    add(CartaDuelForgeComponent(
      cardId: 'c4',
      nomeCarta: 'Dragão',
      raridade: 'lendario',
      nivel: 1,
      fragmentosPossuidos: 1,
      fragmentosNecessarios: 2,
      obtida: true,
      tamanho: tamanhoCarta,
      posicao: Vector2(100 + espacamento * 3, yPos),
    ));
  }
}
