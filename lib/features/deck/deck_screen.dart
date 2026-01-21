import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../features/profile/services/profile_service.dart';
import '../cards/presentation/widgets/card_action_panel.dart';

// Widgets
import 'presentation/widgets/deck_header.dart';
import 'presentation/widgets/deck_selector.dart';
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

  @override
  void initState() {
    super.initState();
    // Force reload deck from profile when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<DeckViewModel>();
      vm.notifyListeners(); // Force UI update with current deck
    });
  }

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
    // Removed snackbar notification - cards swap silently
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
            // 1. Dark Ice Background - Base Layer
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFF0A1628), // Dark navy blue (top)
                      const Color(0xFF05080F), // Almost black (bottom)
                    ],
                  ),
                ),
              ),
            ),
            
            // 2. Ice Texture Overlay (subtle)
            Positioned.fill(
              child: Opacity(
                opacity: 0.15,
                child: Image.asset(
                  'assets/ui/bg_deck_option_01_runic_frost_v01.png',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox(),
                ),
              ),
            ),
            
            // 3. Depth Gradient (creates atmosphere)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.topCenter,
                    radius: 1.5,
                    colors: [
                      const Color(0xFF1A3A5A).withOpacity(0.2), // Icy blue glow
                      Colors.transparent,
                      const Color(0xFF000000).withOpacity(0.3), // Dark vignette
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),
            ),
            
            // 4. Animated Snow Particles (subtle, blurred)
            Positioned.fill(
              child: _SnowParticles(),
            ),
            
            // Content
            SafeArea(
              child: Column(
                children: [
                  DeckHeader(
                    cardCount: vm.currentDeck.length,
                    averageCost: vm.averageCost,
                  ),
                  
                  DeckSelector(viewModel: vm),
                  
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

// Animated Snow Particles Widget
class _SnowParticles extends StatefulWidget {
  @override
  State<_SnowParticles> createState() => _SnowParticlesState();
}

class _SnowParticlesState extends State<_SnowParticles> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_SnowFlake> _snowflakes = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    // Create subtle snow particles (fewer for performance)
    for (int i = 0; i < 30; i++) {
      _snowflakes.add(_SnowFlake());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _SnowPainter(_snowflakes, _controller.value),
        );
      },
    );
  }
}

class _SnowFlake {
  double x = (DateTime.now().millisecondsSinceEpoch % 1000) / 1000.0;
  double y = (DateTime.now().microsecondsSinceEpoch % 1000) / 1000.0;
  double speed = 0.3 + (DateTime.now().millisecondsSinceEpoch % 100) / 200.0;
  double size = 1.5 + (DateTime.now().microsecondsSinceEpoch % 100) / 100.0;
  double opacity = 0.1 + (DateTime.now().millisecondsSinceEpoch % 50) / 200.0;
}

class _SnowPainter extends CustomPainter {
  final List<_SnowFlake> snowflakes;
  final double animationValue;

  _SnowPainter(this.snowflakes, this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0); // Blurred effect

    for (var flake in snowflakes) {
      final y = ((flake.y + animationValue * flake.speed) % 1.0) * size.height;
      final x = flake.x * size.width;
      
      paint.color = Colors.white.withOpacity(flake.opacity);
      canvas.drawCircle(
        Offset(x, y),
        flake.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_SnowPainter oldDelegate) => true;
}
