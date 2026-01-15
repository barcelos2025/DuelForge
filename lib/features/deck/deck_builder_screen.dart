import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../battle/data/card_catalog.dart';
import '../../features/profile/services/profile_service.dart';
import '../../core/assets/asset_registry.dart';

class DeckViewModel extends ChangeNotifier {
  final ProfileService profileService;
  
  List<String> currentDeck = [];
  List<CardDefinition> allCards = [];
  
  String? errorMessage;

  DeckViewModel(this.profileService) {
    _load();
  }

  void _load() {
    currentDeck = List.from(profileService.profile.currentDeck);
    allCards = cardCatalog;
    notifyListeners();
  }

  double get averageCost {
    if (currentDeck.isEmpty) return 0.0;
    final total = currentDeck.fold(0, (sum, id) => sum + _getCost(id));
    return total / currentDeck.length;
  }

  int _getCost(String id) {
    try {
      return allCards.firstWhere((c) => c.cardId == id).cost;
    } catch (_) {
      return 0;
    }
  }

  bool isInDeck(String cardId) {
    return currentDeck.contains(cardId);
  }

  void toggleCard(String cardId) {
    errorMessage = null;
    if (isInDeck(cardId)) {
      currentDeck.remove(cardId);
    } else {
      if (currentDeck.length >= 8) {
        errorMessage = "Deck cheio! Remova uma carta antes.";
      } else {
        currentDeck.add(cardId);
      }
    }
    notifyListeners();
  }

  Future<void> saveDeck() async {
    errorMessage = null;
    
    // Validation
    if (currentDeck.length != 8) {
      errorMessage = "O deck deve ter 8 cartas.";
      notifyListeners();
      return;
    }

    int spells = 0;
    int buildings = 0;
    
    for (var id in currentDeck) {
      final def = allCards.firstWhere((c) => c.cardId == id);
      if (def.type == CardType.feitico) spells++;
      if (def.type == CardType.construcao) buildings++;
    }

    if (spells < 1) {
      errorMessage = "Mínimo de 1 feitiço necessário.";
      notifyListeners();
      return;
    }

    if (buildings > 3) {
      errorMessage = "Máximo de 3 construções permitido.";
      notifyListeners();
      return;
    }

    await profileService.saveDeck(currentDeck);
    errorMessage = "Deck salvo com sucesso!";
    notifyListeners();
  }
}

class DeckBuilderScreen extends StatelessWidget {
  const DeckBuilderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profileService = Provider.of<ProfileService>(context, listen: false);

    return ChangeNotifierProvider(
      create: (_) => DeckViewModel(profileService),
      child: const _DeckBuilderContent(),
    );
  }
}

class _DeckBuilderContent extends StatelessWidget {
  const _DeckBuilderContent();

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<DeckViewModel>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2C),
      appBar: AppBar(
        title: const Text('Editar Deck'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Text(
                'Média: ${vm.averageCost.toStringAsFixed(1)}',
                style: const TextStyle(
                  color: Colors.cyanAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Current Deck Area
          Container(
            height: 140,
            padding: const EdgeInsets.all(8),
            color: Colors.black26,
            child: Column(
              children: [
                const Text('Seu Deck (8 cartas)', style: TextStyle(color: Colors.white54)),
                const SizedBox(height: 8),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (int i = 0; i < 8; i++)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: _DeckSlot(
                            cardId: i < vm.currentDeck.length ? vm.currentDeck[i] : null,
                            onTap: i < vm.currentDeck.length 
                                ? () => vm.toggleCard(vm.currentDeck[i]) 
                                : null,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Error / Success Message
          if (vm.errorMessage != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              color: vm.errorMessage!.contains('sucesso') ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
              child: Text(
                vm.errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: vm.errorMessage!.contains('sucesso') ? Colors.greenAccent : Colors.redAccent,
                ),
              ),
            ),

          // Collection Grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 0.75,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: vm.allCards.length,
              itemBuilder: (context, index) {
                final card = vm.allCards[index];
                final isSelected = vm.isInDeck(card.cardId);
                
                return GestureDetector(
                  onTap: () => vm.toggleCard(card.cardId),
                  child: Opacity(
                    opacity: isSelected ? 0.4 : 1.0,
                    child: Stack(
                      children: [
                        // Card Image
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.white24),
                            image: DecorationImage(
                              image: AssetImage('assets/images/cards/${card.cardId}'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        // Cost Badge
                        Positioned(
                          top: 4,
                          left: 4,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.purple,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '${card.cost}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                        // Selected Indicator
                        if (isSelected)
                          const Center(
                            child: Icon(Icons.check_circle, color: Colors.cyanAccent, size: 32),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Save Button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: vm.saveDeck,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.cyan,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('SALVAR DECK', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DeckSlot extends StatelessWidget {
  final String? cardId;
  final VoidCallback? onTap;

  const _DeckSlot({this.cardId, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40, // Small slot
        height: 56,
        decoration: BoxDecoration(
          color: Colors.black38,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.white12),
        ),
        child: cardId != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.asset(
                  'assets/images/cards/$cardId',
                  fit: BoxFit.cover,
                  errorBuilder: (_,__,___) => const Center(child: Icon(Icons.error, size: 12, color: Colors.red)),
                ),
              )
            : const Center(child: Icon(Icons.add, size: 16, color: Colors.white24)),
      ),
    );
  }
}
