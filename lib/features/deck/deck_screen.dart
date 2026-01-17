import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../features/profile/services/profile_service.dart';
import '../cards/presentation/widgets/card_action_panel.dart';

// Widgets
import 'presentation/widgets/deck_header.dart';
import 'presentation/widgets/deck_slots.dart';
import 'presentation/widgets/card_collection_grid.dart';
import 'presentation/widgets/swap_confirm_dialog.dart';
import 'presentation/widgets/reserve_toolbar.dart';

// ViewModel & Domain
import 'presentation/viewmodels/deck_view_model.dart';
import 'domain/deck_types.dart';

// Animation
import 'presentation/anim/card_rect_registry.dart';
import 'presentation/anim/card_swap_animator.dart';

class DeckScreen extends StatelessWidget {
  const DeckScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profileService = Provider.of<ProfileService>(context, listen: false);

    return ChangeNotifierProvider(
      create: (_) => DeckViewModel(profileService),
      child: const _DeckBuilderContent(),
    );
  }
}

class _DeckBuilderContent extends StatefulWidget {
  const _DeckBuilderContent();

  @override
  State<_DeckBuilderContent> createState() => _DeckBuilderContentState();
}

class _DeckBuilderContentState extends State<_DeckBuilderContent> with TickerProviderStateMixin {
  final CardRectRegistry _registry = CardRectRegistry();
  bool _isSwapping = false;
  SelectedCardRef? _swappingSource;
  SelectedCardRef? _swappingTarget;

  void _handleCardTap(BuildContext context, DeckViewModel vm, String cardId, DeckSide side, int index) {
    if (_isSwapping) return;

    if (vm.selected == null) {
      vm.selectCard(cardId, side, index);
    } else if (vm.selected!.side == side) {
      vm.selectCard(cardId, side, index);
    } else {
      _showSwapDialog(context, vm, cardId, side, index);
    }
  }

  void _showSwapDialog(BuildContext context, DeckViewModel vm, String targetId, DeckSide targetSide, int targetIndex) {
    final selectedRef = vm.selected!;
    final sourceCard = vm.allCards.firstWhere((c) => c.cardId == selectedRef.cardId);
    final targetCard = vm.allCards.firstWhere((c) => c.cardId == targetId);

    showDialog(
      context: context,
      builder: (context) => SwapConfirmDialog(
        selectedCard: sourceCard,
        tappedCard: targetCard,
        onConfirm: () async {
          Navigator.pop(context);
          await _performSwapAnimation(vm, targetId, targetSide, targetIndex);
        },
        onCancel: () {
          Navigator.pop(context);
        },
      ),
    );
  }

  Future<void> _performSwapAnimation(DeckViewModel vm, String targetId, DeckSide targetSide, int targetIndex) async {
    // 1. Validate swap before animation
    if (!vm.canSwap(targetId, targetSide, targetIndex)) {
      return; // Error message is already set in VM
    }

    final sourceRef = vm.selected!;
    final sourceKey = _registry.getKey(
      sourceRef.side == DeckSide.game ? 'game' : 'reserve',
      sourceRef.index,
      sourceRef.cardId,
    );
    final targetKey = _registry.getKey(
      targetSide == DeckSide.game ? 'game' : 'reserve',
      targetIndex,
      targetId,
    );

    final sourceRect = _registry.getRect(sourceKey);
    final targetRect = _registry.getRect(targetKey);

    bool success = false;

    if (sourceRect != null && targetRect != null) {
      setState(() {
        _isSwapping = true;
        _swappingSource = sourceRef;
        _swappingTarget = SelectedCardRef(cardId: targetId, side: targetSide, index: targetIndex);
      });

      // 2. Perform Animation
      await CardSwapAnimator.animateSwap(
        context: context,
        vsync: this,
        fromA: sourceRect,
        toA: targetRect,
        fromB: targetRect,
        toB: sourceRect,
        cardIdA: sourceRef.cardId,
        cardIdB: targetId,
      );

      // 3. Perform Logic
      success = await vm.swapCards(targetId, targetSide, targetIndex);

      if (mounted) {
        setState(() {
          _isSwapping = false;
          _swappingSource = null;
          _swappingTarget = null;
        });
      }
    } else {
      // Fallback if rects not found
      success = await vm.swapCards(targetId, targetSide, targetIndex);
    }

    if (mounted && success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Cartas trocadas!', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.cyan.withOpacity(0.8),
          duration: const Duration(milliseconds: 1500),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showCardOptions(BuildContext context, DeckViewModel vm, String cardId) {
    final cardDef = vm.allCards.firstWhere((c) => c.cardId == cardId);
    final isInDeck = vm.isInDeck(cardId);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => CardActionPanel(
        card: cardDef,
        isInDeck: isInDeck,
        onToggleDeck: () => vm.toggleCard(cardId),
        onDismiss: () => Navigator.pop(context),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<DeckViewModel>(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (vm.errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Center(
                child: Text(
                  vm.errorMessage!,
                  style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ),
      body: AbsorbPointer(
        absorbing: _isSwapping,
        child: Stack(
          children: [
            // Background
            Positioned.fill(
              child: Image.asset(
                'assets/ui/bg_deck_option_01_runic_frost_v01.png',
                fit: BoxFit.cover,
              ),
            ),
            
            // Content
            SafeArea(
              child: Column(
                children: [
                  DeckHeader(
                    cardCount: vm.currentDeck.length,
                    averageCost: vm.averageCost,
                  ),
                  
                  DeckSlots(
                    currentDeck: vm.currentDeck,
                    selectedRef: vm.selected,
                    onCardTap: (id, index) => _handleCardTap(context, vm, id, DeckSide.game, index),
                    registry: _registry,
                    isSwapping: _isSwapping,
                    swappingSource: _swappingSource,
                    swappingTarget: _swappingTarget,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  Container(
                    height: 2,
                    margin: const EdgeInsets.symmetric(horizontal: 32),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.cyan.withOpacity(0.5),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                  
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: ReserveToolbar(),
                  ),

                  const SizedBox(height: 8),

                  Expanded(
                    child: CardCollectionGrid(
                      allCards: vm.filteredSortedReserveCards,
                      currentDeck: vm.currentDeck,
                      selectedRef: vm.selected,
                      onCardTap: (id, index) => _handleCardTap(context, vm, id, DeckSide.reserve, index),
                      registry: _registry,
                      isSwapping: _isSwapping,
                      swappingSource: _swappingSource,
                      swappingTarget: _swappingTarget,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
