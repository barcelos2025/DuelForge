import 'package:flutter/material.dart';
import '../../../../ui/theme/duel_colors.dart';
import '../viewmodels/deck_view_model.dart';

class DeckSelector extends StatelessWidget {
  final DeckViewModel viewModel;

  const DeckSelector({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final decks = viewModel.decks;
    final activeId = viewModel.activeDeckId;

    return Container(
      height: 35,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: decks.length + (decks.length < 5 ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == decks.length) {
            // Botão Adicionar
            return _AddDeckButton(
              onTap: () => _showCreateDeckDialog(context),
            );
          }

          final deck = decks[index];
          final isActive = deck.id == activeId;

          return _DeckTab(
            name: deck.name,
            isActive: isActive,
            onTap: () {
              if (isActive) {
                _showRenameDialog(context, deck);
              } else {
                viewModel.selecionarDeck(deck.id);
              }
            },
            onLongPress: () => _showDeleteDialog(context, deck),
          );
        },
      ),
    );
  }

  void _showRenameDialog(BuildContext context, dynamic deck) {
    final controller = TextEditingController(text: deck.name);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('Renomear Deck', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Nome do Deck',
            hintStyle: TextStyle(color: Colors.white54),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white30)),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                viewModel.renomearDeck(deck.id, controller.text);
                Navigator.pop(context);
              }
            },
            child: const Text('Salvar', style: TextStyle(color: DuelColors.cyanNeon)),
          ),
        ],
      ),
    );
  }

  void _showCreateDeckDialog(BuildContext context) {
    final controller = TextEditingController(text: 'Deck ${viewModel.decks.length + 1}');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('Novo Deck', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Nome do Deck',
            hintStyle: TextStyle(color: Colors.white54),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white30)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                viewModel.criarNovoDeck(controller.text);
                Navigator.pop(context);
              }
            },
            child: const Text('Criar', style: TextStyle(color: DuelColors.cyanNeon)),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, dynamic deck) {
    if (deck.isActive) return; // Não pode deletar ativo (já tratado no service, mas bom evitar UI)

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('Excluir Deck?', style: TextStyle(color: Colors.white)),
        content: Text('Deseja excluir "${deck.name}"?', style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () {
              viewModel.excluirDeck(deck.id);
              Navigator.pop(context);
            },
            child: const Text('Excluir', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}

class _DeckTab extends StatelessWidget {
  final String name;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _DeckTab({
    required this.name,
    required this.isActive,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    // Limita o nome a 10 caracteres
    final displayName = name.length > 10 ? '${name.substring(0, 10)}...' : name;
    
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? DuelColors.cyanNeon.withOpacity(0.2) : Colors.white.withOpacity(0.05),
          border: Border.all(
            color: isActive ? DuelColors.cyanNeon : Colors.white10,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(8),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: DuelColors.cyanNeon.withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 1,
                  )
                ]
              : [],
        ),
        child: Center(
          child: Text(
            displayName,
            style: TextStyle(
              color: isActive ? Colors.white : Colors.white60,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              fontSize: 12,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ),
    );
  }
}

class _AddDeckButton extends StatelessWidget {
  final VoidCallback onTap;

  const _AddDeckButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          border: Border.all(color: Colors.white24),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Icon(Icons.add, color: Colors.white70, size: 20),
        ),
      ),
    );
  }
}
