import 'package:flutter/foundation.dart';
import '../../battle/models/carta.dart';
import '../../battle/viewmodels/cards_repository.dart';

class DeckViewModel extends ChangeNotifier {
  final CardsRepository repositorio;

  List<Carta> _meuDeck = [];
  List<Carta> get meuDeck => _meuDeck;

  List<Carta> _colecao = [];
  List<Carta> get colecao => _colecao;

  DeckViewModel({required this.repositorio});

  Future<void> carregar() async {
    if (!repositorio.carregado) {
      await repositorio.carregar();
    }
    
    // Inicializa com o starter deck se estiver vazio
    if (_meuDeck.isEmpty) {
      _meuDeck = List.from(repositorio.starterDeck());
    }
    
    _atualizarColecao();
    notifyListeners();
  }

  void _atualizarColecao() {
    _colecao = repositorio.todasCartas;
  }

  void adicionarAoDeck(Carta carta) {
    if (_meuDeck.length >= 8) return; // Limite de 8 cartas
    if (_meuDeck.any((c) => c.id == carta.id)) return; // Já está no deck

    _meuDeck.add(carta);
    notifyListeners();
  }

  void removerDoDeck(Carta carta) {
    _meuDeck.removeWhere((c) => c.id == carta.id);
    notifyListeners();
  }
  
  bool estaNoDeck(Carta carta) {
    return _meuDeck.any((c) => c.id == carta.id);
  }
}
