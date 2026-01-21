import 'package:flutter/material.dart';
import '../../../../ui/theme/duel_colors.dart';
import '../../../../ui/theme/duel_typography.dart';
import '../models/player_card_model.dart';

class CardWidget extends StatelessWidget {
  final PlayerCardModel card;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double width;
  final double height;

  const CardWidget({
    super.key,
    required this.card,
    this.isSelected = false,
    this.onTap,
    this.onLongPress,
    this.width = 100,
    this.height = 140,
  });

  Color _getRarityColor(String rarity) {
    switch (rarity.toLowerCase()) {
      case 'common': return DuelColors.rarityCommonMetal;
      case 'rare': return DuelColors.rarityRareMetal;
      case 'epic': return DuelColors.rarityEpicMetal;
      case 'legendary': return DuelColors.rarityLegendaryMetal;
      default: return DuelColors.rarityCommonMetal;
    }
  }

  @override
  Widget build(BuildContext context) {
    final rarityColor = _getRarityColor(card.rarity);
    final canUpgrade = card.canUpgrade;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: width,
        height: height,
        transform: isSelected ? (Matrix4.identity()..scale(1.05)) : Matrix4.identity(),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? DuelColors.primary : rarityColor,
            width: isSelected ? 3 : 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(color: DuelColors.primary.withOpacity(0.6), blurRadius: 12, spreadRadius: 2),
                ]
              : canUpgrade
                  ? [
                      BoxShadow(color: DuelColors.success.withOpacity(0.4), blurRadius: 8, spreadRadius: 1),
                    ]
                  : [],
          color: Colors.black87,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 1. Background Image
              card.isObtained
                  ? Image.asset(
                      card.assetPath,
                      fit: BoxFit.cover,
                    )
                  : ColorFiltered(
                      colorFilter: const ColorFilter.mode(Colors.black, BlendMode.saturation),
                      child: Image.asset(
                        card.assetPath,
                        fit: BoxFit.cover,
                        opacity: const AlwaysStoppedAnimation(0.5),
                      ),
                    ),

              // 2. Gradient Overlay (Bottom)
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: height * 0.4,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black.withOpacity(0.9)],
                    ),
                  ),
                ),
              ),

              // 3. Elixir Cost (Top Left)
              Positioned(
                top: 4,
                left: 4,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.purple.shade900,
                    border: Border.all(color: Colors.purpleAccent),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 4),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      card.elixirCost.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        fontFamily: 'Cinzel',
                      ),
                    ),
                  ),
                ),
              ),

              // 4. Level Badge (Bottom Left)
              if (card.isObtained)
                Positioned(
                  bottom: 36,
                  left: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: rarityColor.withOpacity(0.5)),
                    ),
                    child: Text(
                      'Nv. ${card.level}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

              // 5. Name (Bottom Center)
              Positioned(
                bottom: 18,
                left: 4,
                right: 4,
                child: Text(
                  card.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontFamily: 'Cinzel',
                    fontWeight: FontWeight.bold,
                    shadows: [Shadow(color: Colors.black, blurRadius: 2)],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // 6. Progress Bar (Bottom)
              Positioned(
                bottom: 4,
                left: 4,
                right: 4,
                child: card.isObtained
                    ? Column(
                        children: [
                          // Progress Bar Background
                          Container(
                            height: 6,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.black45,
                              borderRadius: BorderRadius.circular(3),
                              border: Border.all(color: Colors.white10),
                            ),
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: (card.fragmentsOwned / card.fragmentsRequiredNext).clamp(0.0, 1.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: canUpgrade ? DuelColors.success : DuelColors.primary,
                                  borderRadius: BorderRadius.circular(3),
                                  boxShadow: canUpgrade
                                      ? [BoxShadow(color: DuelColors.success.withOpacity(0.8), blurRadius: 4)]
                                      : [],
                                ),
                              ),
                            ),
                          ),
                          // Text Overlay (Optional, can be too small)
                          // Text(
                          //   '${card.fragmentsOwned}/${card.fragmentsRequiredNext}',
                          //   style: TextStyle(fontSize: 8, color: Colors.white70),
                          // ),
                        ],
                      )
                    : Container(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        color: Colors.black54,
                        child: const Text(
                          'NÃO OBTIDA',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white54, fontSize: 8),
                        ),
                      ),
              ),
              
              // 7. Upgrade Indicator
              if (canUpgrade)
                Positioned(
                  top: 4,
                  right: 4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: DuelColors.success,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: DuelColors.success.withOpacity(0.6), blurRadius: 6),
                      ],
                    ),
                    child: const Icon(Icons.arrow_upward, color: Colors.white, size: 12),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
