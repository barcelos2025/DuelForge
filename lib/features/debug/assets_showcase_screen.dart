import 'package:flutter/material.dart';
import '../../ui/theme/df_theme.dart';
import '../../ui/theme/df_assets.dart';
import '../../ui/theme/df_assets_technical.dart';

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
