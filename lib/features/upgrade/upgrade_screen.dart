import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../battle/data/card_catalog.dart';
import '../../battle/data/balance_rules.dart';
import '../profile/services/profile_service.dart';
import '../../core/assets/asset_registry.dart';

class UpgradeScreen extends StatelessWidget {
  const UpgradeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileService>();
    
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2C),
      appBar: AppBar(
        title: const Text('Evoluir Cartas'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black45,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.amber.withOpacity(0.5)),
            ),
            child: Row(
              children: [
                const Icon(Icons.monetization_on, color: Colors.amber, size: 16),
                const SizedBox(width: 4),
                Text(
                  '${profile.profile.coins}',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.amber),
                ),
              ],
            ),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: cardCatalog.length,
        itemBuilder: (context, index) {
          final def = cardCatalog[index];
          final level = profile.getCardLevel(def.cardId);
          final stats = BalanceRules.computeFinalStats(def.cardId, level);
          final nextStats = BalanceRules.computeFinalStats(def.cardId, level + 1);
          final cost = BalanceRules.computeUpgradeCost(def.cardId, level);
          final canUpgrade = profile.canUpgrade(def.cardId, cost);

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A3A),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white10),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4)),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Card Image
                  Container(
                    width: 80,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.black45,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        AssetRegistry.getCardAsset(def.cardId),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Center(
                          child: Icon(
                            def.type == CardType.feitico ? Icons.auto_fix_high : 
                            def.type == CardType.construcao ? Icons.home_work : Icons.person,
                            color: Colors.white24,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // Info & Stats
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                def.cardId.split('_').skip(2).join(' ').replaceAll('.jpg', '').replaceAll('.png', '').toUpperCase(),
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.cyan.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'LVL $level',
                                style: const TextStyle(color: Colors.cyanAccent, fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        
                        // Stats Grid
                        if (def.type != CardType.feitico)
                          _StatRow(label: 'HP', current: stats.hp, next: nextStats.hp, color: Colors.greenAccent),
                        _StatRow(label: 'DMG', current: stats.damage, next: nextStats.damage, color: Colors.redAccent),
                        if (stats.dps > 0)
                          _StatRow(label: 'DPS', current: stats.dps.toInt(), next: nextStats.dps.toInt(), color: Colors.orangeAccent),
                      ],
                    ),
                  ),
                  
                  // Upgrade Button
                  const SizedBox(width: 12),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: canUpgrade ? () {
                          profile.upgradeCard(def.cardId, cost);
                        } : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: canUpgrade ? const Color(0xFF4CAF50) : Colors.grey[800],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          elevation: canUpgrade ? 4 : 0,
                        ),
                        child: Column(
                          children: [
                            const Text('UPGRADE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.monetization_on, size: 12, color: canUpgrade ? Colors.amber : Colors.white38),
                                const SizedBox(width: 2),
                                Text('$cost', style: TextStyle(fontWeight: FontWeight.bold, color: canUpgrade ? Colors.amber : Colors.white38)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final num current;
  final num next;
  final Color color;

  const _StatRow({
    required this.label,
    required this.current,
    required this.next,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final diff = next - current;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 30,
            child: Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
          ),
          Text('$current', style: const TextStyle(color: Colors.white70, fontSize: 11)),
          const Icon(Icons.arrow_right, color: Colors.white24, size: 14),
          Text('$next', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
          if (diff > 0)
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Text(
                '(+${diff is int ? diff : diff.toStringAsFixed(1)})',
                style: const TextStyle(color: Colors.greenAccent, fontSize: 10),
              ),
            ),
        ],
      ),
    );
  }
}
