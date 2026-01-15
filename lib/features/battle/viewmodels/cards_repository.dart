
import 'dart:convert';
import 'package:flutter/services.dart';
import '../../../core/config/app_config.dart';
import '../models/carta.dart';

class CardsRepository {
  Map<String, Carta> _mapa = const {};
  List<String> _starterDeck = const [];
  double _regen = 1.0;
  double _max = 10.0;

  Future<void> carregar() async {
    final texto = await rootBundle.loadString(AppConfig.caminhoCartasJson);
    final dados = jsonDecode(texto) as Map<String, dynamic>;

    _regen = ((dados['resource'] as Map<String, dynamic>)['regen_per_sec'] as num).toDouble();
    _max = ((dados['resource'] as Map<String, dynamic>)['max'] as num).toDouble();

    final lista = (dados['cards'] as List).cast<Map<String, dynamic>>();
    final cartas = lista.map(Carta.fromJson).toList();
    _mapa = {for (final c in cartas) c.id: c};

    _starterDeck = (dados['starter_deck'] as List).cast<String>();
  }

  bool get carregado => _mapa.isNotEmpty;
  double get regenPorSegundo => _regen;
  double get runaMax => _max;

  List<Carta> starterDeck() => _starterDeck.map((id) => _mapa[id]!).toList();
  Carta porId(String id) => _mapa[id]!;
  List<Carta> get todasCartas => _mapa.values.toList();
}
