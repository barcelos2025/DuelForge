import 'package:flutter/material.dart';
import '../../ui/theme/df_theme.dart';
import '../../ui/theme/df_assets.dart';

enum ChestState { locked, unlocking, ready, empty }
enum ChestRarity { common, rare, epic, legendary }

class ChestItemModel {
  final String id;
  final ChestRarity rarity;
  final ChestState state;
  final Duration? remainingTime;
  final Duration? totalTime;

  ChestItemModel({
    required this.id,
    this.rarity = ChestRarity.common,
    this.state = ChestState.empty,
    this.remainingTime,
    this.totalTime,
  });

  double get progress {
    if (state != ChestState.unlocking || remainingTime == null || totalTime == null) return 0.0;
    final total = totalTime!.inSeconds;
    final remaining = remainingTime!.inSeconds;
    return 1.0 - (remaining / total);
  }
}

class DFChestCarousel extends StatelessWidget {
  final List<ChestItemModel> slots;
  final Function(String id) onOpen;
  final Function(String id) onSpeedUp;
  final VoidCallback? onEmptySlotTap;

  const DFChestCarousel({
    super.key,
    required this.slots,
    required this.onOpen,
    required this.onSpeedUp,
    this.onEmptySlotTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 140, // Altura suficiente para o card + detalhes
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: slots.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final slot = slots[index];
          return _ChestSlotCard(
            model: slot,
            onTap: () {
              if (slot.state == ChestState.ready) {
                onOpen(slot.id);
              } else if (slot.state == ChestState.unlocking) {
                onSpeedUp(slot.id);
              } else if (slot.state == ChestState.empty) {
                onEmptySlotTap?.call();
              }
            },
          );
        },
      ),
    );
  }
}

class _ChestSlotCard extends StatelessWidget {
  final ChestItemModel model;
  final VoidCallback onTap;

  const _ChestSlotCard({required this.model, required this.onTap});

  Color get _rarityColor {
    switch (model.rarity) {
      case ChestRarity.common: return Colors.blueGrey;
      case ChestRarity.rare: return DFTheme.gold;
      case ChestRarity.epic: return DFTheme.purple;
      case ChestRarity.legendary: return DFTheme.cyan;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (model.state == ChestState.empty) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          width: 100,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity( 0.2),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity( 0.05), width: 2, style: BorderStyle.solid),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_circle_outline, color: Colors.white.withOpacity( 0.1), size: 32),
              const SizedBox(height: 8),
              Text(
                'Slot Vazio',
                style: DFTheme.labelBold.copyWith(color: Colors.white24, fontSize: 10),
              ),
            ],
          ),
        ),
      );
    }

    final isReady = model.state == ChestState.ready;
    final isUnlocking = model.state == ChestState.unlocking;
    final color = _rarityColor;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        decoration: BoxDecoration(
          color: DFTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isReady ? color : Colors.white.withOpacity( 0.1),
            width: isReady ? 2 : 1,
          ),
          boxShadow: isReady 
              ? [BoxShadow(color: color.withOpacity( 0.4), blurRadius: 12, spreadRadius: 1)] 
              : [],
        ),
        child: Stack(
          children: [
            // Fundo com brilho se pronto
            if (isReady)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        color.withOpacity( 0.1),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

            // Conteúdo
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Ícone do Baú
                  Expanded(
                    child: Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          if (isUnlocking)
                            SizedBox(
                              width: 60,
                              height: 60,
                              child: CircularProgressIndicator(
                                value: model.progress,
                                strokeWidth: 3,
                                backgroundColor: Colors.black26,
                                valueColor: AlwaysStoppedAnimation<Color>(DFTheme.cyan),
                              ),
                            ),
                          Image.asset(
                            _getChestImage(model.rarity),
                            width: 50,
                            height: 50,
                            fit: BoxFit.contain,
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 8),

                  // Status / Timer
                  if (isReady)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'ABRIR',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.black),
                      ),
                    )
                  else if (isUnlocking)
                    Column(
                      children: [
                        Text(
                          _formatDuration(model.remainingTime!),
                          style: DFTheme.labelBold.copyWith(color: DFTheme.cyan, fontSize: 12),
                        ),
                        const SizedBox(height: 2),
                        const Text('Desbloqueando', style: TextStyle(fontSize: 9, color: Colors.white54)),
                      ],
                    )
                  else
                    Column(
                      children: [
                        Text(
                          _formatDuration(model.totalTime ?? const Duration(hours: 3)),
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white70),
                        ),
                        const SizedBox(height: 2),
                        const Text('Bloqueado', style: TextStyle(fontSize: 9, color: Colors.white38)),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getChestImage(ChestRarity rarity) {
    switch (rarity) {
      case ChestRarity.common: return DFAssets.chestWooden;
      case ChestRarity.rare: return DFAssets.chestGold; // Usando Gold como Rare por enquanto
      case ChestRarity.epic: return DFAssets.chestGold; // Placeholder
      case ChestRarity.legendary: return DFAssets.chestGold; // Placeholder
    }
  }

  String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    if (h > 0) return '${h}h ${m}m';
    return '${m}m';
  }
}
