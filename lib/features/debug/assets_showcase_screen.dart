import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../ui/theme/df_theme.dart';
import '../../ui/theme/df_assets.dart';
import '../../ui/theme/df_assets_technical.dart';
import 'package:flame/game.dart';
import '../../flame/scenes/exemplo_carta_scene.dart';
import '../../flame/arena/exemplo_arena_controller_game.dart';
import '../../flame/scenes/exemplo_torres_game.dart';
import '../../flame/arena/exemplo_arena_completa_game.dart';
import '../../flame/scenes/exemplo_teste_barras_hp_game.dart';
import '../rewards/domain/reward_event_bus.dart';
import '../rewards/domain/reward_models.dart';
import '../rewards/services/reward_sync_service.dart';

/// Tela de demonstração dos assets de UI do DuelForge
class AssetsShowcaseScreen extends StatelessWidget {
  const AssetsShowcaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DFTheme.background,
      appBar: AppBar(
        title: const Text('DuelForge UI Assets'),
        backgroundColor: DFTheme.surface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Flame Card Demo Button ---
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => Scaffold(
                        appBar: AppBar(title: const Text('Flame Card Demo')),
                        body: GameWidget(
                          game: ExemploCartaScene(),
                        ),
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.gamepad),
                label: const Text('ABRIR DEMO FLAME CARDS'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: DFTheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // --- Arena Controller Demo Button ---
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => Scaffold(
                        appBar: AppBar(title: const Text('Arena Controller Demo')),
                        body: GameWidget(
                          game: ExemploArenaControllerGame(),
                        ),
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.map),
                label: const Text('ABRIR DEMO ARENA CONTROLLER'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // --- Tower Demo Button ---
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => Scaffold(
                        appBar: AppBar(title: const Text('Tower Logic Demo')),
                        body: GameWidget(
                          game: ExemploTorresGame(),
                        ),
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.security),
                label: const Text('ABRIR DEMO TORRES'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade800,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // --- Arena Completa Demo Button ---
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => Scaffold(
                        appBar: AppBar(title: const Text('Arena Completa Demo')),
                        body: GameWidget(
                          game: ExemploArenaCompletaGame(),
                        ),
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.landscape),
                label: const Text('ABRIR DEMO ARENA COMPLETA'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade800,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // --- HP Bar Test Demo Button ---
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => Scaffold(
                        appBar: AppBar(title: const Text('HP Bar Test Demo')),
                        body: GameWidget(
                          game: ExemploTesteBarrasHpGame(),
                        ),
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.medical_services),
                label: const Text('TESTAR BARRAS DE HP'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade800,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // --- Test Reward Animation Button ---
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Simular recompensa
                  final batch = RewardBatch(
                    outboxIds: ['test-id'],
                    items: [
                      const RewardItem(
                        id: 'test-1',
                        type: RewardType.currency,
                        resourceId: 'gold',
                        amount: 500,
                      ),
                      const RewardItem(
                        id: 'test-2',
                        type: RewardType.currency,
                        resourceId: 'runes',
                        amount: 50,
                      ),
                      const RewardItem(
                        id: 'test-3',
                        type: RewardType.card_fragment,
                        resourceId: 'thor',
                        amount: 5,
                      ),
                    ],
                  );
                  RewardEventBus().emitReward(batch);
                },
                icon: const Icon(Icons.card_giftcard),
                label: const Text('TESTAR ANIMAÇÃO DE RECOMPENSA (LOCAL)'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple.shade800,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // --- Trigger Supabase Rewards Button ---
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Chama o RPC no Supabase
                  RewardSyncService(Supabase.instance.client).debugGrantRewards();
                },
                icon: const Icon(Icons.cloud_download),
                label: const Text('TRIGGER SUPABASE REWARDS (REAL)'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo.shade800,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ),
            const SizedBox(height: 24),

            _buildSection('Moedas e Ouro', [
              DFAssets.goldCoin,
              DFAssets.goldStack,
            ]),
            
            _buildSection('Cristais Rúnicos', [
              DFAssets.runeCrystalSmall,
              DFAssets.runeCrystalMedium,
              DFAssets.runeCrystalLarge,
            ]),
            
            _buildSection('Gemas Premium', [
              DFAssets.gemSingle,
              DFAssets.gemBag,
              DFAssets.gemStack,
            ]),
            
            _buildSection('Fragmentos de Carta', [
              DFAssets.shardsCommon,
              DFAssets.shardsRare,
              DFAssets.shardsEpic,
              DFAssets.shardsLegendary,
              DFAssets.shardsMaster,
            ]),
            
            _buildSection('Orbes de Energia', [
              DFAssets.runeOrbEmpty,
              DFAssets.runeOrbHalf,
              DFAssets.runeOrbFull,
            ]),
            
            _buildSection('Itens de Upgrade', [
              DFAssets.upgradeScroll,
              DFAssets.forgeHammer,
            ]),
            
            _buildSection('Poções', [
              DFAssets.potionHeal,
              DFAssets.potionRage,
              DFAssets.potionFrost,
            ]),

            _buildSection('Technical Assets (9-Slice)', [
              DFAssetsTechnical.panelBaseCorner,
              DFAssetsTechnical.panelBaseEdge,
              DFAssetsTechnical.panelBaseCenter,
              DFAssetsTechnical.panelCardCorner,
              DFAssetsTechnical.panelCardEdge,
              DFAssetsTechnical.panelCardCenter,
              DFAssetsTechnical.tooltipCorner,
            ]),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSection(String title, List<String> assets) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(
            title,
            style: DFTheme.titleMedium,
          ),
        ),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: assets.map((asset) => _buildAssetCard(asset)).toList(),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
  
  Widget _buildAssetCard(String assetPath) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: DFTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(
          assetPath,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return const Center(
              child: Icon(Icons.error, color: Colors.red),
            );
          },
        ),
      ),
    );
  }
}
