
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../features/battle/viewmodels/battle_view_model.dart';
import '../../../../features/battle/models/carta.dart';
import '../../../../ui/theme/duel_colors.dart';

class HandCardsRow extends StatelessWidget {
  const HandCardsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<BattleViewModel>(
      builder: (context, vm, child) {
        final hand = vm.mao;
        final currentPower = vm.estado.runaAtual;
        final selected = vm.cartaSelecionada;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: hand.map((carta) {
            final canAfford = currentPower >= carta.custo;
            final isSelected = selected?.id == carta.id;

            final cardWidget = _CardSlot(
              carta: carta,
              canAfford: canAfford,
              isSelected: isSelected,
            );

            if (!canAfford) {
              // Se não pode pagar, apenas mostra o widget (talvez com feedback de erro no tap)
              return GestureDetector(
                onTap: () {
                  // Feedback visual/sonoro de erro
                },
                child: cardWidget,
              );
            }

            return Draggable<Carta>(
              data: carta,
              feedback: Transform.scale(
                scale: 1.1,
                child: Opacity(
                  opacity: 0.8,
                  child: cardWidget,
                ),
              ),
              childWhenDragging: Opacity(
                opacity: 0.3,
                child: cardWidget,
              ),
              onDragStarted: () {
                // Seleciona a carta ao iniciar o arrasto para que o Ghost apareça no jogo
                vm.selecionarCarta(carta);
              },
              onDraggableCanceled: (_, __) {
                // Se soltar fora de um alvo válido, cancela seleção
                vm.selecionarCarta(null);
              },
              onDragEnd: (details) {
                // O deploy real é tratado pelo DragTarget no BattleScreen
                // Se o deploy falhar (não aceito), o onDraggableCanceled cuida.
                // Se for aceito, o DragTarget cuida.
              },
              child: GestureDetector(
                onTap: () {
                  vm.selecionarCarta(carta);
                },
                child: cardWidget,
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class _CardSlot extends StatefulWidget {
  final Carta carta;
  final bool canAfford;
  final bool isSelected;

  const _CardSlot({
    required this.carta,
    required this.canAfford,
    required this.isSelected,
  });

  @override
  State<_CardSlot> createState() => _CardSlotState();
}

class _CardSlotState extends State<_CardSlot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Resolve Rarity Color
    Color borderColor = Colors.white10;
    Color shadowColor = Colors.transparent;
    
    // Debug Rarity
    // debugPrint('Card: ${widget.carta.nome}, Rarity: ${widget.carta.raridade}');

    final r = widget.carta.raridade.trim().toLowerCase();
    
    if (r.contains('com') || r.contains('common')) {
      borderColor = DuelColors.rarityCommonMetal;
    } else if (r.contains('rar') || r.contains('rare')) {
      borderColor = DuelColors.rarityRareMetal;
    } else if (r.contains('epi') || r.contains('epic')) {
      borderColor = DuelColors.rarityEpicMetal;
    } else if (r.contains('len') || r.contains('leg')) {
      borderColor = DuelColors.rarityLegendaryMetal;
    } else {
      borderColor = DuelColors.rarityCommonMetal; // Fallback
    }
    
    shadowColor = borderColor.withOpacity(0.25);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // Use a sine curve for smoother "breathing" effect
        final glowValue = Curves.easeInOut.transform(_controller.value); 
        
        return Container(
          width: 70,
          height: 90,
          // No margin change on selection
          decoration: BoxDecoration(
            color: const Color(0xFF2A2A3A),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              // Selected: Rarity Color (Width 3)
              // Affordable: Rarity Color (Width 2)
              // Not Affordable: Red/Dimmed (Width 2)
              color: widget.isSelected 
                  ? borderColor 
                  : (widget.canAfford ? borderColor : Colors.red.withOpacity(0.5)),
              width: widget.isSelected ? 3 : 2,
            ),
            boxShadow: [
              // Selection Glow (Animated)
              if (widget.isSelected)
                BoxShadow(
                  color: borderColor.withOpacity(0.6), 
                  blurRadius: 6 + (glowValue * 10), // 6 -> 16 (Smoother range)
                  spreadRadius: 1 + (glowValue * 3), // 1 -> 4
                )
              // Affordable Glow (Static)
              else if (widget.canAfford)
                BoxShadow(
                  color: shadowColor,
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
            ],
          ),
          child: child,
        );
      },
      child: Stack(
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Opacity(
              opacity: widget.canAfford ? 1.0 : 0.5,
              child: Image.asset(
                widget.carta.imagePath ?? '',
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.grey[800],
                  child: Center(
                    child: Text(
                      widget.carta.nome.substring(0, 2).toUpperCase(),
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ),
                ),
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
                '${widget.carta.custo}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),



          // Name
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 2),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black.withOpacity(0.8), Colors.transparent],
                ),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(6)),
              ),
              child: Text(
                widget.carta.nome,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 8),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
