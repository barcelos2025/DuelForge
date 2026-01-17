import 'package:flutter/material.dart';
import '../../../../core/assets/asset_registry.dart';
import '../../../../battle/data/card_catalog.dart';
import '../../../../ui/theme/duel_colors.dart';
import '../anim/card_rect_registry.dart';
import 'glow_border.dart';

class DeckCardWidget extends StatefulWidget {
  final String? cardId;
  final bool isSelected;
  final VoidCallback onTap;
  final double width;
  final double height;
  final bool isStaticMode;
  final CardRectRegistry? registry;
  final String? registryKey;
  final bool isPlaceholder;

  const DeckCardWidget({
    super.key,
    required this.cardId,
    required this.isSelected,
    required this.onTap,
    this.width = 80,
    this.height = 100,
    this.isStaticMode = false,
    this.registry,
    this.registryKey,
    this.isPlaceholder = false,
  });

  @override
  State<DeckCardWidget> createState() => _DeckCardWidgetState();
}

class _DeckCardWidgetState extends State<DeckCardWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _registerRect());
  }

  @override
  void didUpdateWidget(covariant DeckCardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.registryKey != oldWidget.registryKey) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _registerRect());
    }
  }

  void _registerRect() {
    if (widget.registry != null && widget.registryKey != null && mounted) {
      final renderBox = context.findRenderObject() as RenderBox?;
      if (renderBox != null) {
        final position = renderBox.localToGlobal(Offset.zero);
        final rect = position & renderBox.size;
        widget.registry!.register(widget.registryKey!, rect);
      }
    }
  }

  Alignment _getCardAlignment(String cardId) {
    const centerAligned = [
      'df_card_catapult_v0',
      'df_card_fire_catapult_v01',
      'df_card_loki_trickery_v01',
      'df_card_whale_hunter_v01',
      'df_card_winged_demon_legendary_v01',
      'df_card_lightning_cloud_v01',
      'df_card_voodoo_doll_v01',
      'df_card_frost_gate_v01',
    ];

    const bottomAligned = [
      'df_card_thunder_hammer_v01',
    ];

    for (final name in centerAligned) {
      if (cardId.contains(name)) {
        return Alignment.center;
      }
    }

    for (final name in bottomAligned) {
      if (cardId.contains(name)) {
        return Alignment.bottomCenter;
      }
    }
    return Alignment.topCenter;
  }

  @override
  Widget build(BuildContext context) {
    // Resolve Rarity Color
    Color borderColor = Colors.white10;
    Color shadowColor = Colors.transparent;
    
    if (widget.cardId != null) {
      try {
        final def = cardCatalog.firstWhere((c) => c.cardId == widget.cardId);
        switch (def.rarity) {
          case CardRarity.common:
            borderColor = DuelColors.rarityCommon;
            break;
          case CardRarity.rare:
            borderColor = DuelColors.rarityRare;
            break;
          case CardRarity.epic:
            borderColor = DuelColors.rarityEpic;
            break;
          case CardRarity.legendary:
            borderColor = DuelColors.rarityLegendary;
            break;
        }
        shadowColor = borderColor.withOpacity(0.25);
      } catch (_) {}
    }

    if (widget.isPlaceholder) {
      return SizedBox(
        width: widget.width,
        height: widget.height,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black12,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: borderColor.withOpacity(0.5), // Dimmer for placeholder
              width: 2,
            ),
          ),
        ),
      );
    }

    Widget content = Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: Colors.black38,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderColor,
          width: 2,
        ),
        boxShadow: [
          // Rarity Glow
          if (widget.cardId != null)
            BoxShadow(
              color: shadowColor,
              blurRadius: 12,
              spreadRadius: 1,
            ),
          // Selection Glow (Extra layer if needed, but GlowBorder handles the main one)
          if (widget.isSelected)
             BoxShadow(
               color: Colors.cyanAccent.withOpacity(0.1),
               blurRadius: 4,
               spreadRadius: 0,
             ),
        ],
      ),
      child: widget.cardId != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                AssetRegistry.getCardAssetPath(widget.cardId!),
                fit: BoxFit.cover,
                alignment: _getCardAlignment(widget.cardId!),
                errorBuilder: (_, __, ___) => const Center(
                  child: Icon(Icons.error, size: 16, color: Colors.red),
                ),
              ),
            )
          : const Center(
              child: Icon(Icons.add, size: 24, color: Colors.white12),
            ),
    );

    if (widget.isStaticMode) {
      return GlowBorder(
        isSelected: widget.isSelected,
        child: content,
      );
    }

    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        transform: Matrix4.identity()
          ..translate(0.0, widget.isSelected ? -8.0 : 0.0)
          ..scale(widget.isSelected ? 1.06 : 1.0),
        child: GlowBorder(
          isSelected: widget.isSelected,
          child: content,
        ),
      ),
    );
  }
}
