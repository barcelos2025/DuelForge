import 'package:flutter/foundation.dart';
import '../../battle/models/carta.dart';
import '../../battle/viewmodels/cards_repository.dart';
import '../../profile/services/profile_service.dart';

class DeckViewModel extends ChangeNotifier {
  final CardsRepository repositorio;
  final ProfileService profileService;

  List<Carta> _meuDeck = [];
  List<Carta> get meuDeck => _meuDeck;

  List<Carta> _colecao = [];
  List<Carta> get colecao => _colecao;

  DeckViewModel({required this.repositorio, required this.profileService});

  Future<void> carregar() async {
    if (!repositorio.carregado) {
      await repositorio.carregar();
    }
    
    _atualizarColecao();
    _carregarDeckDoPerfil();
    
    notifyListeners();
  }

  void _carregarDeckDoPerfil() {
    try {
      // Busca o deck ativo do perfil
      final deckAtivo = profileService.profile.decks.firstWhere((d) => d.isActive);
      
      // Hidrata as cartas usando o repositório
      _meuDeck = deckAtivo.cardIds
          .map((id) {
            try {
              return repositorio.porId(id);
            } catch (_) {
              return null;
            }
          })
          .whereType<Carta>() // Filtra nulos
          .toList();
          
    } catch (e) {
      // Se não houver deck ativo, usa o starter deck do repositório
      _meuDeck = List.from(repositorio.starterDeck());
    }
  }

  void _atualizarColecao() {
    _colecao = repositorio.todasCartas;
  }

  Future<void> adicionarAoDeck(Carta carta) async {
    if (_meuDeck.length >= 8) return; // Limite de 8 cartas
    if (_meuDeck.any((c) => c.id == carta.id)) return; // Já está no deck

    _meuDeck.add(carta);
    await _salvarDeck();
    notifyListeners();
  }

  Future<void> removerDoDeck(Carta carta) async {
    _meuDeck.removeWhere((c) => c.id == carta.id);
    await _salvarDeck();
    notifyListeners();
  }
  
  Future<void> _salvarDeck() async {
    final ids = _meuDeck.map((c) => c.id).toList();
    await profileService.saveDeck(ids);
  }
  
  bool estaNoDeck(Carta carta) {
    return _meuDeck.any((c) => c.id == carta.id);
  }

  // --- Multi-Deck Support ---

  List<dynamic> get decks => profileService.profile.decks; // dynamic to avoid importing PlayerDeck here if not needed, or import it. Let's use dynamic or import.
  // Better to import PlayerDeck in DeckViewModel if not already.
  // Assuming PlayerDeck is available via profile_service import or we add import.
  // Let's check imports. profile_service.dart imports player_deck.dart.
  // So we can use PlayerDeck if we import '../models/player_deck.dart'.
  // But to be safe and quick, I'll use the list from profileService directly.
  
  String get activeDeckId {
    try {
      return profileService.profile.decks.firstWhere((d) => d.isActive).id;
    } catch (_) {
      return '';
    }
  }

  Future<void> criarNovoDeck(String nome) async {
    await profileService.createDeck(nome);
    notifyListeners();
  }

  Future<void> selecionarDeck(String deckId) async {
    await profileService.setActiveDeck(deckId);
    // Recarrega o deck ativo na view
    _carregarDeckDoPerfil();
    notifyListeners();
  }

  Future<void> excluirDeck(String deckId) async {
    await profileService.deleteDeck(deckId);
    notifyListeners();
  }

  Future<void> renomearDeck(String deckId, String novoNome) async {
    await profileService.renameDeck(deckId, novoNome);
    notifyListeners();
  }
}
